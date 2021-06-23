//
//  LoginLinkAccountsViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-21.
//

import UIKit
import FirebaseAuth
import Moya

extension SegueIdentifier {
    static let unwindFromLinkAccount = SegueIdentifier(rawValue: "UnwindFromLinkAccount")
}

class LoginLinkAccountsViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var linkButton: UIButton!
    
    var email: String!
    var authCredential: AuthCredential!
    
    private var provider: MoyaProvider<AttendanceAPI>!
    private var networkManager: LoginNetworkManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
        networkManager = LoginNetworkManager(provider: provider)
        // swiftlint:disable line_length
        guard let email = email else {
            return
        }
        descriptionLabel.text = "It seems like there already is an account linked with this email: \(email) \nPlease provide the password linked with this email to link your social account and sign in"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func linkButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: email, password: passwordTextField.text ?? "") { [weak self] (authResult, error) in
            guard let self = self else { return }
            if let error = error {
                self.handleError(error)
            } else if let result = authResult {
                result.user.link(with: self.authCredential) { (_, error) in
                    if let error = error {
                        self.handleError(error)
                    } else {
                        self.networkManager.getUser(withId: result.user.uid) { (result) in
                            switch result {
                            case .success(let userResponse):
                                UserService.shared.currentUser = userResponse
                                self.performSegue(identifier: .unwindFromLinkAccount, sender: nil)
                            case .failure(let error):
                                self.handleError(error)
                                self.dismiss(animated: true) { [weak self] in
                                    self?.handleError(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
