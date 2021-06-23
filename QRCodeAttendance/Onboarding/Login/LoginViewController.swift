//
//  LoginWithPhoneViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-02.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import Toast
import KeychainSwift

extension SegueIdentifier {
    static let showMainScreen = SegueIdentifier("ShowMainScreen")
    static let showLinkAccounts = SegueIdentifier("ShowLinkAccounts")
}

class LoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: TextInputView!
    @IBOutlet weak var passwordTextField: TextInputView!
    @IBOutlet weak var loginButton: PrimaryButton!
    @IBOutlet weak var continueWithLabel: UILabel!
    @IBOutlet weak var socialLoginStackView: UIStackView!
    
    private lazy var loginDataModel: LoginDataModel = {
        LoginDataModel(delegate: self)
    }()
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? LoginLinkAccountsViewController,
           let sender = sender as? (email: String, credential: AuthCredential) {
            viewController.email = sender.email
            viewController.authCredential = sender.credential
        }
    }
    
    func configureUI() {
        titleLabel.text = "Login".localized
        subtitleLabel.text = "login_subtitle".localized
        loginButton.setTitle("Log in".localized, for: .normal)
        
        if let email = keychain.get("email") {
            emailTextField.setText(email)
        }
        
        if let password = keychain.get("password") {
            passwordTextField.setText(password)
        }
        
        emailTextField.setPlaceholder("Email".localized)
            .setTextContentType(.emailAddress)
        passwordTextField.setPlaceholder("Password".localized)
            .setTextContentType(.password)
            .setSecureInput(true)
            .setImage(UIImage(systemName: "lock")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)))
            .onTextFieldReturn = {}
    }
    
    @IBAction func unwindFromRegistrationScreen(segue: UIStoryboardSegue) {
        segue.source.dismiss(animated: true) { [weak self] in
            self?.performSegue(identifier: .showMainScreen, sender: nil)
        }
    }
    
    @IBAction func unwindFromLinkAccountScreen(segue: UIStoryboardSegue) {
        segue.source.dismiss(animated: true) { [weak self] in
            self?.performSegue(identifier: .showMainScreen, sender: nil)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        view.endEditing(true)
        do {
            try loginDataModel.login(withEmail: emailTextField.text, password: passwordTextField.text)
        } catch ValidationError.emptyEmailField {
            emailTextField.setState(.error)
            self.view.makeToast(ValidationError.emptyEmailField.localizedDescription)
        } catch ValidationError.emptyPasswordField {
            passwordTextField.setState(.error)
            self.view.makeToast(ValidationError.emptyPasswordField.localizedDescription)
        } catch ValidationError.emptyEmailAndPassword {
            emailTextField.setState(.error)
            passwordTextField.setState(.error)
            self.view.makeToast(ValidationError.emptyEmailAndPassword.localizedDescription)
        } catch let error {
            MBProgressHUD.hide(for: self.view, animated: true)
            handleError(error)
        }
    }
}

extension LoginViewController: LoginDataModelDelegate {
    func loginDataModelDidLoginSuccessfully(_ dataModel: LoginDataModel) {
        MBProgressHUD.hide(for: self.view, animated: true)
        keychain.set(emailTextField.text, forKey: "email")
        keychain.set(passwordTextField.text, forKey: "password")
        performSegue(identifier: .showMainScreen, sender: nil)
    }
    
    func loginDataModelFailedLogin(_ dataModel: LoginDataModel, error: Error) {
        MBProgressHUD.hide(for: self.view, animated: true)
        handleError(error)
    }
    
    func loginDataModelStartedLoading(_ dataModel: LoginDataModel) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func loginDataModel(_ dataModel: LoginDataModel, didFindProviderWithEmail email: String, credential: AuthCredential) {
        performSegue(identifier: .showLinkAccounts, sender: (email, credential))
    }
}
