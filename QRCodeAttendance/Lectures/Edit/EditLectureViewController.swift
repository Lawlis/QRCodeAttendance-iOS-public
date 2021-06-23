//
//  EditLectureViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-21.
//

import UIKit
import Eureka
import Moya
import MBProgressHUD
import Toast

extension SegueIdentifier {
    static let unwindFromEditLecture = SegueIdentifier(rawValue: "unwindFromEditLecture")
}

class EditLectureViewController: FormViewController, Networkable {
    
    let provider = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    var lecture: Lecture?
    
    private var users: [User.BaseInformation] = []
    private var faculties: [Faculty] = []
    private var groups: [Group.Inclusive] = []
    
    private var assignedStudents: [User.BaseInformation] = []
    private var assignedLectors: [User.BaseInformation] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if lecture != nil {
            title = "Edit lecture"
        } else {
            title = "Create lecture"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(submitForm))
        
        let group = DispatchGroup()
        MBProgressHUD.showAdded(to: view, animated: true)
        group.enter()
        getAllUsers { [weak self] (result) in
            switch result {
            case .success(let users):
                self?.users = users.map({ User.BaseInformation(user: $0) })
                group.leave()
            case .failure(let error):
                self?.handleError(error)
                group.leave()
            }
        }
        
        group.enter()
        getAllFaculties { [weak self] (result) in
            switch result {
            case .success(let faculties):
                self?.faculties = faculties
                group.leave()
            case .failure(let error):
                self?.handleError(error)
                group.leave()
            }
        }
        
        group.enter()
        getAllGroups { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let groups):
                self.groups = groups
                group.leave()
            case .failure(let error):
                self.handleError(error)
                group.leave()
            }
        }
        
        group.notify(queue: .main, execute: {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.buildForm()
        })
    }
    
    private func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        request(target: .getAllUsers, completion: completion)
    }
    
    private func getAllFaculties(completion: @escaping (Result<[Faculty], Error>) -> Void) {
        request(target: .getAllFaculties, completion: completion)
    }
    
    private func getAllGroups(completion: @escaping (Result<[Group.Inclusive], Error>) -> Void) {
        request(target: .getAllGroups, completion: completion)
    }
    
    private func postLecture(_ lecture: Lecture.Create, completion: @escaping (Result<Void, Error>) -> Void) {
        emptyResponseRequest(target: .postLecture(lecture: lecture), completion: completion)
    }
    
    private func editLecture(_ lecture: Lecture, completion: @escaping (Result<Void, Error>) -> Void) {
        emptyResponseRequest(target: .editLecture(lecture: lecture), completion: completion)
    }
    
    @objc
    private func submitForm() {
        guard form.validate().isEmpty else {
            return
        }
        guard let title = form.values()["Title"] as? String else {
            fatalError()
        }
        guard let faculty = form.values()["Faculty"] as? Faculty else {
            fatalError()
        }
        let lecture = Lecture.Create(name: title, assignedStudents: assignedStudents, assignedLectors: assignedLectors, faculty: faculty)
        
        if var editedLecture = self.lecture {
            editedLecture.name = title
            editedLecture.faculty = faculty
            editedLecture.assignedLectors = assignedLectors
            editedLecture.assignedStudents = assignedStudents
            editLecture(editedLecture) { [weak self] (result) in
                switch result {
                case .success(_):
                    self?.view.makeToast("Lecture succesfully edited")
                    self?.performSegue(identifier: .unwindFromEditLecture, sender: nil)
                case .failure(let error):
                    self?.view.makeToast(error.localizedDescription)
                }
            }
        } else {
            postLecture(lecture) { [weak self] (result) in
                switch result {
                case .success(_):
                    self?.view.makeToast("Lecture succesfully created")
                    self?.performSegue(identifier: .unwindFromEditLecture, sender: nil)
                case .failure(let error):
                    self?.view.makeToast(error.localizedDescription)
                }
            }
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func buildForm() {
        form.removeAll()
        let assignedStudentSection = Section("Assigned students")
        assignedStudentSection.tag = "Students"
        let assignedLectorsSection = Section("Assigned lectors")
        assignedLectorsSection.tag = "Lectors"
        let facultySection = Section("Faculty info")
        facultySection.tag = "Faculties"
        
        form +++ facultySection
            <<< TextRow {
                $0.tag = "Title"
                $0.title = "Lecture title"
                $0.placeholder = "Title"
                $0.value = lecture?.name
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate({ cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                }
            })
            <<< SearchPushRow<User.BaseInformation> {
                $0.tag = "Students"
                $0.title = "Select students"
                $0.options = users.filter({ $0.role == .student })
                $0.value = assignedStudents.first
                $0.validationOptions = .validatesOnDemand
            }.onChange({ [unowned self] in
                guard let value = $0.value,
                      !assignedStudents.contains(value) else {
                    return
                }
                self.updateAssignedStudents(section: assignedStudentSection, withValue: value)
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .systemRed
                }
            })
            <<< SearchPushRow<Group.Inclusive> {
                $0.tag = "group"
                $0.title = "Add students from group"
                $0.options = groups
            }.onChange({ [unowned self] in
                guard let assignedStudents = $0.value?.assignedStudents else {
                    return
                }
                
                for student in assignedStudents {
                    if !self.assignedStudents.contains(student) {
                        self.updateAssignedStudents(section: assignedStudentSection, withValue: student)
                    }
                }
            })
            <<< SearchPushRow<User.BaseInformation> {
                $0.tag = "Lectors"
                $0.title = "Select lectors"
                $0.value = assignedLectors.first
                $0.options = users.filter({ $0.role == .lecturer || $0.role == .admin })
                $0.validationOptions = .validatesOnDemand
            }.onChange({ [unowned self] in
                guard let value = $0.value,
                      !assignedLectors.contains(value) else {
                    return
                }
                self.updateAssignedLectors(section: assignedLectorsSection, withValue: value)
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .systemRed
                }
            })
            <<< PushRow<Faculty> {
                $0.tag = "Faculty"
                $0.title = "Faculty"
                $0.options = faculties
                $0.value = lecture?.faculty
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.displayValueFor = {
                    $0?.name
                }
            }.cellUpdate({ cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .systemRed
                }
            })
        
        form +++ assignedStudentSection
        form +++ assignedLectorsSection
        
        if let lecture = self.lecture {
            for student in lecture.assignedStudents {
                self.updateAssignedStudents(section: assignedStudentSection, withValue: student)
            }
            
            for lector in lecture.assignedLectors {
                self.updateAssignedLectors(section: assignedLectorsSection, withValue: lector)
            }
        }
    }
    
    private func updateAssignedStudents(section: Section, withValue value: User.BaseInformation) {
        self.assignedStudents.append(value)
        section.removeAll()
        for student in assignedStudents {
            section <<< LabelRow {
                $0.tag = student.id
                if let groupName = student.group?.name {
                    $0.title = groupName + " " + student.name + " " + student.surname
                } else {
                    $0.title = student.name + " " + student.surname
                }
                
                let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
                    print("Delete")
                    self.assignedStudents.removeAll { (user) -> Bool in
                        if user.id == student.id {
                            return true
                        }
                        return false
                    }
                    completionHandler?(true)
                }
                
                $0.trailingSwipe.actions = [deleteAction]
                $0.trailingSwipe.performsFirstActionWithFullSwipe = true
            }
        }
        section.reload()
    }
    
    private func updateMultipleStudents(section: Section, withValue value: User.BaseInformation)  {
        let lastIndex = assignedStudents.endIndex - 1
        self.assignedStudents.insert(value, at: lastIndex)
        section <<< LabelRow {
            $0.tag = value.id
            
        }
    }
    
    private func updateAssignedLectors(section: Section, withValue value: User.BaseInformation) {
        self.assignedLectors.append(value)
        section.removeAll()
        for lector in assignedLectors {
            section <<< LabelRow {
                $0.tag = lector.id
                if let groupName = lector.group?.name {
                    $0.title = groupName + lector.name + lector.surname
                } else {
                    $0.title = lector.name + " " + lector.surname
                }
                
                let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
                    print("Delete")
                    self.assignedLectors.removeAll { (user) -> Bool in
                        if user.id == lector.id {
                            return true
                        }
                        return false
                    }
                    completionHandler?(true)
                }
                
                $0.trailingSwipe.actions = [deleteAction]
                $0.trailingSwipe.performsFirstActionWithFullSwipe = true
            }
        }
        section.reload()
    }
}
