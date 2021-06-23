//
//  GroupsTableViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-23.
//

import UIKit
import Moya

extension SegueIdentifier {
    static let showCreateGroup = SegueIdentifier(rawValue: "ShowCreateGroup")
}

class GroupsTableViewController: UITableViewController, Networkable {
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    private lazy var dataSource: GroupsDataSource = GroupsDataSource(tableView: tableView)
    
    let currentUser = UserService.shared.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Groups"
        tableView.dataSource = dataSource
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGroups()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let viewController = navController.topViewController as? CreateGroupViewController,
           let group = sender as? Group.Inclusive {
            viewController.group = group
        }
    }
    
    @IBAction func unwindFromGroupViewController(segue: UIStoryboardSegue) {
        updateGroups()
    }
    
    @objc
    private func addButtonPressed() {
        performSegue(identifier: .showCreateGroup, sender: nil)
    }
    
    private func getAllGroups(completion: @escaping (Result<[Group.Inclusive], Error>) -> Void) {
        request(target: .getAllGroups, completion: completion)
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            self.confirmDelete(id: self.dataSource.groups[indexPath.row].id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.updateGroups()
                    self.alert(message: "Successfully deleted group: \(self.dataSource.groups[indexPath.row].name)")
                case .failure(let error):
                    self.alert(message: error.localizedDescription)
                }
            }
            completion(true)
        }
        deleteItem.image = UIImage(systemName: "trash")

        let editItem = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.performSegue(identifier: .showCreateGroup, sender: self.dataSource.groups[indexPath.row])
            completion(true)
        }
        editItem.backgroundColor = .systemOrange

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])

        return swipeActions
    }
    
    func confirmDelete(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        showAlert(title: "Confirm delete",
                  message: "Are you sure you want to delete this group?",
                  preferredStyle: .alert,
                  actions: [UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.deleteLecture(id: id, completion: completion)
                  }), .cancel],
                  completion: nil)
    }
    
    func deleteLecture(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        emptyResponseRequest(target: .deleteGroup(id: id), completion: completion)
    }
    
    func updateGroups() {
        getAllGroups { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let groups):
                self.dataSource.groups = groups
                self.dataSource.updateTableView()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
}


