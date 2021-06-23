//
//  EventsViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-03-30.
//

import UIKit
import MBProgressHUD
import Moya

extension SegueIdentifier {
    static let showCreateEvent = SegueIdentifier(rawValue: "ShowCreateEvent")
    static let showEvent = SegueIdentifier(rawValue: "ShowEvent")
    static let showScanCode = SegueIdentifier(rawValue: "ShowScanCode")
    static let unwindFromScannerToEvents = SegueIdentifier(rawValue: "UnwindFromScannerToEvents")
}

enum EventsSection: CaseIterable {
    case first
}

class EventsViewController: UIViewController, Networkable {
    
    // MARK: - UI Components

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
        
    // MARK: - Dependencies
    
    private let currentUser = UserService.shared.currentUser
    
    // MARK: - State
    
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    private lazy var dataSource: EventsDataSource = EventsDataSource(tableView: tableView)
        
    var isInitialLoad = true
    
    let calendar = Calendar.current

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Events"
        guard let user = currentUser else { return }
        if user.role.isLecturer {
            let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
            navigationItem.rightBarButtonItem = addBarButton
        }
        fromDatePicker.date = Date()
        toDatePicker.date = Date().endOfWeek
        
        dataSource.onCheckInTapped = { [weak self] event in
            guard let self = self,
                  let currentUser = self.currentUser else { return }
            let now = Date()
            if now > event.startDate && now < event.endDate {
                self.performSegue(identifier: .showScanCode, sender: (eventId: event.id,
                                                                      userId: currentUser.id,
                                                                      scanType: ScanType.eventQRCodeCheckIn))
            } else {
                self.alert(message: "You can't register to an event that hasn't started or has ended")
            }
        }
        
        dataSource.onCheckOutTapped = { [weak self] event in
            guard let self = self,
                  let currentUser = self.currentUser,
                  let validCheckOutDate = self.calendar.date(byAdding: .minute, value: -10, to: event.endDate) else { return }
            let now = Date()
            if now < validCheckOutDate {
                self.alert(message: "Check out will be available 10 minutes before end time")
            }
            if now > event.startDate && now < event.endDate {
                self.performSegue(identifier: .showScanCode, sender: (eventId: event.id,
                                                                      userId: currentUser.id,
                                                                      scanType: ScanType.eventQRCodeCheckOut))
            } else {
                self.alert(message: "You can't register to an event that hasn't started or has ended")
            }
        }
        
        dataSource.checkInColleagueTapped = { [weak self] event in
            guard let self = self,
                  let currentUser = self.currentUser else { return }
            let now = Date()
            if now > event.startDate && now < event.endDate {
                self.performSegue(identifier: .showScanCode,
                                  sender: (eventId: event.id,
                                           userId: currentUser.id,
                                           scanType: ScanType.scanAColleagueCheckIn))
            } else {
                self.alert(message: "You can't register to an event that hasn't started or has ended")
            }
        }
        
        dataSource.checkOutColleagueTapped = { [weak self] event in
            guard let self = self,
                  let currentUser = self.currentUser,
                  let validCheckOutDate = self.calendar.date(byAdding: .minute, value: -10, to: event.endDate) else { return }
            let now = Date()
            if now < validCheckOutDate {
                self.alert(message: "Check out will be available 10 minutes before end time")
            }
            if now > event.startDate && now < event.endDate {
                self.performSegue(identifier: .showScanCode,
                                  sender: (eventId: event.id,
                                           userId: currentUser.id,
                                           scanType: ScanType.scanAColleagueCheckOut))
            } else {
                self.alert(message: "You can't register to an event that hasn't started or has ended")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEvents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventDetailsViewController,
           let event = sender as? Event {
            destination.event = event
        }
        
        if let destination = segue.destination as? ScannerViewController,
           let sender = sender as? (eventId: Int, userId: String, scanType: ScanType) {
            destination.eventId = sender.eventId
            destination.userId = sender.userId
            destination.scanType = sender.scanType
        }
        
        if let destination = segue.destination as? EditEventsViewController,
           let sender = sender as? Event {
            destination.event = sender
        }
    }
    
    func updateEvents() {
        guard let user = currentUser else { return }
        if user.role.isLecturer {
            getLectorEventsByDateInterval(dateFrom: DateTools.requestDateFormatter.string(from: fromDatePicker.date.startOfDay),
                                          dateTo: DateTools.requestDateFormatter.string(from: toDatePicker.date.endOfDay),
                                          userId: user.id) { [weak self] (result) in
                switch result {
                case .success(let events):
                    self?.dataSource.events = events.sorted(by: { $0.startDate < $1.startDate })
                    self?.dataSource.updateTableView()
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        } else {
            getStudentEventsByDateInterval(dateFrom: DateTools.requestDateFormatter.string(from: fromDatePicker.date.startOfDay),
                                           dateTo: DateTools.requestDateFormatter.string(from: toDatePicker.date.endOfDay),
                                           userId: user.id) { [weak self] (result) in
                switch result {
                case .success(let events):
                    self?.dataSource.events = events.sorted(by: { $0.startDate < $1.startDate })
                    self?.dataSource.updateTableView()
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    @IBAction func unwindFromScannerToEvents(segue: UIStoryboardSegue) {
        navigationController?.popToViewController(self, animated: true)
        alert(message: "Attendance registered")
    }
    
    @IBAction func unwindFromEditEvents(segue: UIStoryboardSegue) {
        segue.source.dismiss(animated: true, completion: nil)
        alert(message: "Successfully created an event")
        updateEvents()
    }
    
    // MARK: - UI Actions
    
    @objc
    func addButtonPressed() {
        performSegue(identifier: .showCreateEvent, sender: nil)
    }
    
    @IBAction private func fromValueChanged() {
        if let user = currentUser {
            if user.role.isLecturer {
                getLectorEventsByDateInterval(dateFrom: DateTools.requestDateFormatter.string(from: fromDatePicker.date.startOfDay),
                                              dateTo: DateTools.requestDateFormatter.string(from: toDatePicker.date.endOfDay),
                                              userId: user.id) { [weak self] (result) in
                    switch result {
                    case .success(let events):
                        self?.dataSource.events = events.sorted(by: { $0.startDate < $1.startDate })
                        self?.dataSource.updateTableView()
                    case .failure(let error):
                        self?.handleError(error)
                    }
                }
            } else {
                getStudentEventsByDateInterval(dateFrom: DateTools.requestDateFormatter.string(from: fromDatePicker.date.startOfDay),
                                               dateTo: DateTools.requestDateFormatter.string(from: toDatePicker.date.endOfDay),
                                               userId: user.id) { [weak self] (result) in
                    switch result {
                    case .success(let events):
                        self?.dataSource.events = events.sorted(by: { $0.startDate < $1.startDate })
                        self?.dataSource.updateTableView()
                    case .failure(let error):
                        self?.handleError(error)
                    }
                }
            }
        }
    }
    
    @IBAction private func toValueChanged() {
        if let user = currentUser {
            if user.role.isLecturer {
                getLectorEventsByDateInterval(dateFrom: DateTools.requestDateFormatter.string(from: fromDatePicker.date.startOfDay),
                                              dateTo: DateTools.requestDateFormatter.string(from: toDatePicker.date.endOfDay),
                                              userId: user.id) { [weak self] (result) in
                    switch result {
                    case .success(let events):
                        self?.dataSource.events = events.sorted(by: { $0.startDate < $1.startDate })
                        self?.dataSource.updateTableView()
                    case .failure(let error):
                        self?.handleError(error)
                    }
                }
            } else {
                getStudentEventsByDateInterval(dateFrom: DateTools.requestDateFormatter.string(from: fromDatePicker.date.startOfDay),
                                               dateTo: DateTools.requestDateFormatter.string(from: toDatePicker.date.endOfDay),
                                               userId: user.id) { [weak self] (result) in
                    switch result {
                    case .success(let events):
                        self?.dataSource.events = events.sorted(by: { $0.startDate < $1.startDate })
                        self?.dataSource.updateTableView()
                    case .failure(let error):
                        self?.handleError(error)
                    }
                }
            }
        }
    }
}

extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource.itemIdentifier(for: indexPath)?.cellHeight ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let user = currentUser,
              user.role.isLecturer else {
            return
        }
        let event: Event = dataSource.events[indexPath.row]
        performSegue(identifier: .showEvent, sender: event)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            self.confirmDelete(id: self.dataSource.events[indexPath.row].id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.updateEvents()
                    self.alert(message: "Successfully deleted event: \(self.dataSource.events[indexPath.row].title)")
                case .failure(let error):
                    self.alert(message: error.localizedDescription)
                }
            }
            completion(true)
        }
        deleteItem.image = UIImage(systemName: "trash")

//        let editItem = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
//            guard let self = self else { return }
//            self.performSegue(identifier: .showCreateEvent, sender: self.dataSource.events[indexPath.row])
//            completion(true)
//        }
//        editItem.backgroundColor = .systemOrange

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])

        return swipeActions
    }
}

extension EventsViewController {
    private func getLectorEventsByDateInterval(dateFrom: String,
                                               dateTo: String,
                                               userId: String,
                                               completion: @escaping (Result<[Event], Error>) -> Void) {
        request(target: .getLectorEventsByDate(dateFrom: dateFrom, dateTo: dateTo, userId: userId), completion: completion)
    }
    
    private func getStudentEventsByDateInterval(dateFrom: String,
                                                dateTo: String,
                                                userId: String,
                                                completion: @escaping (Result<[Event], Error>) -> Void) {
        request(target: .getStudentEventsByDate(dateFrom: dateFrom, dateTo: dateTo, userId: userId), completion: completion)
    }
    
    func confirmDelete(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        showAlert(title: "Confirm delete",
                  message: "Are you sure you want to delete this event?",
                  preferredStyle: .alert,
                  actions: [UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.deleteEvent(id: id, completion: completion)
                  }), .cancel],
                  completion: nil)
    }
    
    func deleteEvent(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        emptyResponseRequest(target: .deleteEvent(eventId: id), completion: completion)
    }
}

// swiftlint:disable force_unwrapping
extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
         var components = DateComponents()
         components.day = 1
         components.second = -1
         return Calendar.current.date(byAdding: components, to: startOfDay)!
     }
    
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }

    var endOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                                         from: self)) else { return Date() }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)!
    }
}
