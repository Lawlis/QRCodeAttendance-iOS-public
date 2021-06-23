//
//  LoginEmailViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-22.
//

import UIKit
import FirebaseAuth

class LoginEmailViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let email = UserDefaults.standard.string(forKey: "email") {
            textField.text = email
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let text = textField.text,
              text.isValidEmail() else {
            self.showAlert(title: "Error", message: "Please enter a valid email", preferredStyle: .alert, action: .ok, completion: nil)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: text, completion: { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.handleError(error)
            } else {
                UserDefaults.standard.setValue(text, forKey: "email")
                self.showAlert(title: "Email sent", message: "Check your email for a password reset link",
                               preferredStyle: .alert,
                               action: .ok,
                               completion: nil)
            }
        })
    }
}

// swiftlint:disable force_try
extension String {
    func isValidEmail() -> Bool {
        // swiftlint:disable line_length
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
