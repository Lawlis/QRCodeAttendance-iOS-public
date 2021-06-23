//
//  MoreViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-11.
//

import UIKit
import MBProgressHUD
import Foundation
import Moya

extension SegueIdentifier {
    static let showCreateLecture = SegueIdentifier(rawValue: "ShowCreateLecture")
    static let showLectureInfo = SegueIdentifier(rawValue: "ShowLectureInfo")
}

final class LecturesViewController: UIViewController, LecturesNetworkable {
    
    // MARK: - UI Components
    
    @IBOutlet weak var tableView: UITableView!
        
    // MARK: - Dependencies
    
    private let currentUser = UserService.shared.currentUser
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    // MARK: - State
    
    private lazy var dataSource: LecturesDataSource = LecturesDataSource(tableView: tableView)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLectures()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let targetVC = navController.topViewController as? EditLectureViewController,
           let lecture = sender as? Lecture {
            targetVC.lecture = lecture
        }
        
        if let lectureInfoViewController = segue.destination as? LectureInfoViewController,
           let lecture = sender as? Lecture {
            lectureInfoViewController.lecture = lecture
        }
    }
    
    @IBAction func unwindFromEditOrCreateLecture(segue: UIStoryboardSegue) {
        segue.source.dismiss(animated: true, completion: nil)
        view.makeToast("Lecture succesfully created/edited")
        updateLectures()
    }
    
    func updateLectures() {
        guard let user = currentUser else { return }
        dataSource.attendance = user.attendance
        MBProgressHUD.showAdded(to: view, animated: true)
        if user.role.isLecturer {
            getLedLectures(byLectorId: user.id) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let lectures):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.dataSource.courses = lectures
                    self.dataSource.updateTableView()
                case .failure(let error):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.handleError(error)
                    print("Failed to get lectures")
                }
            }
        } else {
            let group = DispatchGroup()
            
            group.enter()
            getUser(id: user.id) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    group.leave()
                    self.dataSource.attendance = user.attendance
                case .failure(let error):
                    group.leave()
                    self.handleError(error)
                }
            }
            
            group.enter()
            getAttendableLectures(byUserId: user.id) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let lectures):
                    group.leave()
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.dataSource.courses = lectures
                case .failure(let error):
                    group.leave()
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.handleError(error)
                    print("Failed to get lectures")
                }
            }
            
            group.notify(queue: .main) {
                self.dataSource.updateTableView()
            }
        }
    }
    
    // MARK: - Setup
    
    private func configureUI() {
        title = "my_courses".localized
        guard let user = currentUser else { return }
        if user.role.isLecturer {
            let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
            navigationItem.rightBarButtonItem = addBarButton
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = dataSource
    }
    
    // MARK: - UI Actions
        
    @objc
    private func addButtonPressed() {
        performSegue(identifier: .showCreateLecture, sender: nil)
    }
    
    @objc
    private func filterButtonPressed() {
        let alert = UIAlertController(title: "Select attendance type", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "My lectures", style: .default, handler: { (_) in
            print("User click Approve button")
        }))
        
        alert.addAction(UIAlertAction(title: "Assigned lectures", style: .default, handler: { (_) in
            print("User click Edit button")
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        alert.popoverPresentationController?.sourceView = self.view
        
        present(alert, animated: true, completion: nil)
    }
}

extension LecturesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource.itemIdentifier(for: indexPath)?.cellHeight ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let attendance = dataSource.attendance,
           let user = currentUser,
           !user.role.isLecturer,
           attendance.totalEvents > 0 {
            performSegue(identifier: .showLectureInfo, sender: dataSource.courses[indexPath.row - 1])
        } else {
            performSegue(identifier: .showLectureInfo, sender: dataSource.courses[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            self.confirmDelete(id: self.dataSource.courses[indexPath.row].id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.updateLectures()
                    self.alert(message: "Successfully deleted course: \(self.dataSource.courses[indexPath.row].name)")
                case .failure(let error):
                    self.alert(message: error.localizedDescription)
                }
            }
            completion(true)
        }
        deleteItem.image = UIImage(systemName: "trash")

        let editItem = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.performSegue(identifier: .showCreateLecture, sender: self.dataSource.courses[indexPath.row])
            completion(true)
        }
        editItem.backgroundColor = .systemOrange

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])

        return swipeActions
    }
}

// MARK: - Networking

extension LecturesViewController {
    func getAttendableLectures(byUserId id: String, completion: @escaping (Result<[Lecture], Error>) -> Void) {
        request(target: .getAttendableLectures(userId: id), completion: completion)
    }
    
    func getLedLectures(byLectorId id: String, completion: @escaping (Result<[Lecture], Error>) -> Void) {
        request(target: .getLedLectures(userId: id), completion: completion)
    }
    
    func confirmDelete(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        showAlert(title: "Confirm delete",
                  message: "Are you sure you want to delete this lecture?",
                  preferredStyle: .alert,
                  actions: [UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.deleteLecture(id: id, completion: completion)
                  }), .cancel],
                  completion: nil)
    }
    
    func getLecture(id: Int, completion: @escaping (Result<Lecture, Error>) -> Void) {
        request(target: .getLecture(id: id), completion: completion)
    }
    
    func deleteLecture(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        emptyResponseRequest(target: .deleteLecture(id: id), completion: completion)
    }
    
    func getUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        request(target: .getUser(id: id), completion: completion)
    }
}

extension LecturesViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        updateLectures()
    }
}
