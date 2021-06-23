//
//  EventDetailsViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-04-11.
//

import UIKit
import Moya
import MBProgressHUD

enum EventDetailsSection: CaseIterable {
    case attendableStudents
    case attendedStudents
}

extension SegueIdentifier {
    static let showStudentScanner = SegueIdentifier(rawValue: "ShowStudentScanner")
    static let showQR = SegueIdentifier(rawValue: "ShowQR")
}

class EventDetailsViewController: UIViewController, Networkable, UITableViewDelegate {
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataSource: EventDetailDataSource = EventDetailDataSource(tableView: tableView)
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)

    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTitleLabel.text = event.title
        dataSource.event = event
        dataSource.updateTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MBProgressHUD.showAdded(to: view, animated: true)
        getAttendedStudents(eventId: event.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dataSource.eventAttendees = users
                self.dataSource.updateTableView()
            case .failure(let erro):
                MBProgressHUD.hide(for: self.view, animated: true)
                self.view.makeToast(erro.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? QRCodeViewController {
            viewController.eventId = event.id
        }
        
        if let viewController = segue.destination as? ScannerViewController,
           let scanType = sender as? ScanType {
            viewController.eventId = event.id
            viewController.scanType = scanType
        }
    }
    
    @IBAction func unwindFromScanner(segue: UIStoryboardSegue) {
        self.navigationController?.popToViewController(self, animated: true)
        alert(message: "Student successfully checked in")
    }
    
    @IBAction func showQRPressed(_ sender: Any) {
        let now = Date()
        if now > event.startDate && now < event.endDate {
            performSegue(identifier: .showQR, sender: nil)
        } else {
            alert(message: "Event's QR code cannot be shown for events that haven't exceeded their start date or have ended!")
        }
    }
    
    @IBAction func scanAStundetPressed(_ sender: Any) {
        let now = Date()
        if now > event.startDate && now < event.endDate {
            performSegue(identifier: .showStudentScanner, sender: ScanType.studentQRCodeCheckIn)
        } else {
            alert(message: "You can't scan students for events that haven't exceeded their start date or have ended!")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource.itemIdentifier(for: indexPath)?.cellHeight ?? 0
    }
}

extension EventDetailsViewController {
    func getAttendedStudents(eventId: Int, completion: @escaping ((Result<[User.AttendedStudent], Error>) -> Void)) {
        request(target: .getAttendedStudents(eventId: eventId), completion: completion)
    }
}

extension UIViewController {
  func alert(message: String, title: String = "") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
