//
//  EditEventsViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-04-04.
//

import UIKit
import Eureka
import Moya

enum Periodicity: String, CaseIterable, Codable {
    case NONE
    case DAY
    case WEEK
    case WEEK2
    case MONTH
}

extension SegueIdentifier {
    static let unwindFromEditEvents = SegueIdentifier(rawValue: "UnwindFromEditEvents")
}

class EditEventsViewController: FormViewController, Networkable {
    
    let provider = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    var event: Event?
    
    var ledLectures: [Lecture] = []
    
    var eventLecture: SmallLecture?
    var repeatFrequency: Periodicity = .NONE
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()
    
    private lazy var dateFormatterDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event != nil {
            title = "Edit lecture"
        } else {
            getLedLectures { [weak self] result in
                switch result {
                case .success(let lectures):
                    self?.ledLectures = lectures
                    self?.buildForm()
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(submitForm))
    }
    
    private func buildForm() {
        form +++ Section("Event info")
            <<< SearchPushRow<SmallLecture> {
                $0.tag = "Lecture"
                $0.title = "Select lecture"
                $0.options = ledLectures.map(SmallLecture.init)
                $0.add(rule: RuleRequired())
            }.onChange({ [unowned self] in
                guard let value = $0.value else {
                    return
                }
                self.eventLecture = $0.value
            })
            <<< TextRow {
                $0.tag = "Title"
                $0.title = "Event title"
                $0.placeholder = "Title"
                $0.add(rule: RuleRequired())
            }
            <<< DateInlineRow {
                $0.tag = "Start date"
                $0.title = "Start date"
                $0.add(rule: RuleRequired())
            }
            <<< TimeRow {
                $0.tag = "Start time"
                $0.title = "Start time"
                $0.add(rule: RuleRequired())
            }
            <<< TimeRow {
                $0.tag = "End time"
                $0.title = "End time"
                $0.add(rule: RuleRequired())
            }
            +++ Section("Recurrance info")
            <<< SwitchRow {
                $0.tag = "Switch Row"
                $0.title = "Recurring event?"
            }
            <<< DateInlineRow {
                $0.hidden = Condition.function(["Switch Row"], { (form) -> Bool in
                    return !((form.rowBy(tag: "Switch Row") as? SwitchRow)?.value ?? false)
                })
                $0.tag = "End Date"
                $0.title = "End date"
            }
            <<< PushRow<Periodicity> {
                $0.hidden = Condition.function(["Switch Row"], { (form) -> Bool in
                    return !((form.rowBy(tag: "Switch Row") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Repeats"
                $0.value = repeatFrequency
                $0.options = [Periodicity.DAY, Periodicity.WEEK, Periodicity.WEEK2, Periodicity.MONTH]
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.repeatFrequency = value
                    }
                }
            }
            +++ Section("Registration extensions")
            <<< SwitchRow {
                $0.tag = "Check out"
                $0.title = "Check out required?"
            }
            <<< SwitchRow {
                $0.tag = "Share"
                $0.title = "Group share enabled?"
            }
            <<< IntRow {
                $0.hidden = Condition.function(["Share"], { (form) -> Bool in
                    return !((form.rowBy(tag: "Share") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Action limit"
                $0.tag = "Action limit"
            }
    }
    
    // swiftlint:disable function_body_length
    @objc
    private func submitForm() {
        guard form.validate().isEmpty else {
            return
        }
        guard let lecture = form.values()["Lecture"] as? SmallLecture else {
            fatalError()
        }
        guard let title = form.values()["Title"] as? String else {
            fatalError()
        }
        guard let startDate = form.values()["Start date"] as? Date else {
            fatalError()
        }
        guard let eventStartTime = form.values()["Start time"] as? Date else {
            fatalError()
        }
        guard let eventEndTime = form.values()["End time"] as? Date else {
            fatalError()
        }
        
        let calendar = Calendar.current
        let eventStartHour = calendar.component(.hour, from: eventStartTime)
        let eventStartMinute = calendar.component(.minute, from: eventStartTime)
        
        let eventEndHour = calendar.component(.hour, from: eventEndTime)
        let eventEndMinute = calendar.component(.minute, from: eventEndTime)
        
        guard let actualStartDate = calendar.date(bySettingHour: eventStartHour, minute: eventStartMinute, second: 0, of: startDate) else {
            print("Failed to set start hour and start minute to event start date")
            return
        }
        
        let checkOutRequired = form.values()["Check out"] as? Bool
        let shareEnabled = form.values()["Share"] as? Bool
        let actionsLimit = form.values()["Action limit"] as? Int
        
        // swiftlint:disable force_unwrapping

        getLecture(id: lecture.databaseId) { [weak self] result in
            guard let self = self else { return }
            var actualEndDate: Date
            var event: Event.Create
            switch result {
            case .success(let lecture):
                if self.repeatFrequency == .NONE {
                    actualEndDate = calendar.date(bySettingHour: eventEndHour, minute: eventEndMinute, second: 0, of: startDate)!
                    guard let lector = lecture.assignedLectors.first else {
                        return
                    }
                    event = Event.Create(
                        title: title,
                        lecture: lecture,
                        startDate: self.dateFormatterDate.string(from: actualStartDate),
                        startTime: self.dateFormatter.string(from: actualStartDate),
                        endTime: self.dateFormatter.string(from: actualEndDate),
                        attendableStudents: lecture.assignedStudents,
                        lector: lector,
                        periodicity: self.repeatFrequency,
                        actionsLimit: actionsLimit ?? 0,
                        shareEnabled: shareEnabled ?? false,
                        checkOutRequired: checkOutRequired ?? false
                    )
                } else {
                    guard var actualEndDate = self.form.values()["End Date"] as? Date else {
                        return
                    }
                    guard let lector = lecture.assignedLectors.first else {
                        return
                    }
                    actualEndDate = calendar.date(bySettingHour: eventEndHour, minute: eventEndMinute, second: 0, of: actualEndDate)!
                    event = Event.Create(
                        title: title,
                        lecture: lecture,
                        startDate: self.dateFormatterDate.string(from: actualStartDate),
                        startTime: self.dateFormatter.string(from: actualStartDate),
                        endDate: self.dateFormatterDate.string(from: actualEndDate),
                        endTime: self.dateFormatter.string(from: actualEndDate),
                        attendableStudents: lecture.assignedStudents,
                        lector: lector,
                        periodicity: self.repeatFrequency,
                        actionsLimit: actionsLimit ?? 0,
                        shareEnabled: shareEnabled ?? false,
                        checkOutRequired: checkOutRequired ?? false
                    )
                }
                
                if self.event != nil {
                    self.putEvent(self.event) { [weak self] result in
                        switch result {
                        case .success:
                            print("success")
                            self?.performSegue(identifier: .unwindFromEditEvents, sender: nil)
                        case .failure(let error):
                            print(error)
                        }
                    }
                } else {
                    self.postEvent(event) { [weak self] (result) in
                        switch result {
                        case .success:
                            print("success")
                            self?.performSegue(identifier: .unwindFromEditEvents, sender: nil)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    // MARK: - Networking
    
    private func getLedLectures(completion: @escaping (Result<[Lecture], Error>) -> Void) {
        guard let user = UserService.shared.currentUser?.id else {
            print("Couldn't get current user, can't create form...")
            return
        }
        request(target: .getLedLectures(userId: user), completion: completion)
    }
    
    private func getLecture(id: Int, completion: @escaping(Result<Lecture, Error>) -> Void) {
        request(target: .getLecture(id: id), completion: completion)
    }
    
    private func postEvent(_ event: Event.Create, completion: @escaping (Result<Void, Error>) -> Void) {
        emptyResponseRequest(target: .postEvent(event: event), completion: completion)
    }
    
    private func putEvent(_ event: Event?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let event = event else { return }
        emptyResponseRequest(target: .editEvent(event: event), completion: completion)
    }
}
