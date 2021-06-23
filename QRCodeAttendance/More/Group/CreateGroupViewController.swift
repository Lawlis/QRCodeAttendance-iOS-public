//
//  CreateGroupViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-29.
//

import UIKit
import Eureka
import Moya
import MBProgressHUD
import Toast

extension SegueIdentifier {
    static let unwindFromGroups = SegueIdentifier(rawValue: "UnwindFromGroups")
}

class CreateGroupViewController: FormViewController, Networkable {
    
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    private var users: [User.BaseInformation] = []
    
    private var assignedStudents: [User.BaseInformation] = []
    
    var group: Group.Inclusive? {
        didSet {
            guard let groupStudents = group?.assignedStudents else {
                return
            }
            assignedStudents = groupStudents
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(submitForm))
        MBProgressHUD.showAdded(to: self.view, animated: true)
        getAllUsers { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                MBProgressHUD.hide(for: self.view, animated: true)
                for user in users where user.group == nil {
                    self.users.append(User.BaseInformation(user: user))
                }
                self.buildForm()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc
    private func submitForm() {
        print(form.values())
        guard let title = form.values()["Title"] as? String else {
            fatalError()
        }
        if var group = self.group {
            group.name = title
            group.assignedStudents = assignedStudents
            editGroup(group: group) { result in
                switch result {
                case .success(_):
                    self.showAlert(title: "Success",
                                   message: "Group edited",
                                   preferredStyle: .alert,
                                   action: UIAlertAction(title: "ok", style: .default, handler: { [weak self] _ in
                                    self?.performSegue(identifier: .unwindFromGroups, sender: nil)
                                   }),
                                   completion: nil)
                case .failure(let error):
                    self.handleError(error)
                }
            }
        } else {
            let group = Group.Create(name: title, assignedStudents: assignedStudents)
            postCreateGroup(group: group) { (result) in
                switch result {
                case .success(_):
                    self.showAlert(title: "Success",
                                   message: "Group created",
                                   preferredStyle: .alert,
                                   action: .ok,
                                   completion: nil)
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func buildForm() {
        let section = Section("Faculty info")
        let assignedStudentsSection = Section("Assigned students")
        form +++ section
            <<< TextRow {
                $0.tag = "Title"
                $0.title = "Group title"
                $0.placeholder = "Title"
                $0.value = group?.name
                $0.add(rule: RuleRequired())
            }
            <<< SearchPushRow<User.BaseInformation> {
                $0.tag = "Students"
                $0.title = "Select students"
                $0.options = users.filter({ $0.role == .student && $0.group == nil })
                $0.add(rule: RuleRequired())
            }.onChange({ [unowned self] in
                guard let value = $0.value,
                      !assignedStudents.contains(value) else {
                    self.view.makeToast("User already in list")
                    return
                }
                self.updateAssignedStudents(section: assignedStudentsSection, withValue: value)
            })
        form +++ assignedStudentsSection
        for student in assignedStudents {
            assignedStudentsSection <<< LabelRow {
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
    
    private func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        request(target: .getAllUsers, completion: completion)
    }
    
    private func postCreateGroup(group: Group.Create, completion: @escaping (Result<Group, Error>) -> Void) {
        request(target: .postCreateGroup(group: group), completion: completion)
    }
    
    private func editGroup(group: Group.Inclusive, completion: @escaping (Result<Group, Error>) -> Void) {
        request(target: .editGroup(group: group), completion: completion)
    }
}
