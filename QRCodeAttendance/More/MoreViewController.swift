//
//  MoreViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-11.
//

import UIKit
import FirebaseAuth
import MobileCoreServices
import UniformTypeIdentifiers
import Moya

class MoreViewController: UIViewController, Networkable {
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    @IBOutlet weak var importStudentsBtn: SecondaryButton!
    @IBOutlet weak var createGroupBtn: SecondaryButton!
    @IBOutlet weak var createFacultyBtn: SecondaryButton!
    @IBOutlet weak var logoutBtn: SecondaryButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "more".localized
        if let user = UserService.shared.currentUser,
           !user.role.isLecturer {
            createGroupBtn.isHidden = true
            createFacultyBtn.isHidden = true
            importStudentsBtn.isHidden = true
        }
    }
    
    @IBAction func importPressed(_ sender: Any) {
        if #available(iOS 14.0, *) {
            let types = UTType.types(
                tag: "csv",
                tagClass: UTTagClass.filenameExtension,
                conformingTo: nil
            )
            let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: types)
            docPicker.delegate = self
            self.present(docPicker, animated: true, completion: nil)
        } else {
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserService.shared.currentUser = nil
            print("Did logout")
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func uploadStudents(fileURL: URL, completion: @escaping (Result<[String], Error>) -> Void) {
        request(target: .importStudents(fileURL: fileURL), completion: completion)
    }
}

extension MoreViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentURL = urls.first else {
            print("WTF NO URL")
            return
        }
        
        uploadStudents(fileURL: documentURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let studentList):
                for student in studentList {
                    Auth.auth().sendPasswordReset(withEmail: student, completion: { [weak self] error in
                        guard let self = self else { return }
                        if let error = error {
                            self.handleError(error)
                        }
                    })
                    
                    self.showAlert(title: "Success",
                                   message: "Students imported succesfully",
                                   preferredStyle: .alert,
                                   action: .ok,
                                   completion: nil)
                }
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
}
