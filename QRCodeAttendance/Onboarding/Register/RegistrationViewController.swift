//
//  RegistrationViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-15.
//

import UIKit
import FirebaseAuth

extension SegueIdentifier {
    static let unwindFromRegistration = SegueIdentifier("UnwindFromRegistration")
}

class RegistrationViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nameTextField: TextInputView!
    @IBOutlet weak var surnameTextField: TextInputView!
    @IBOutlet weak var emailTextField: TextInputView!
    @IBOutlet weak var passwordTextField: TextInputView!
    @IBOutlet weak var registerButton: PrimaryButton!
    
    private lazy var registrationDataModel: RegistrationDataModel = {
        RegistrationDataModel(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        titleLabel.text = "register_title".localized
        subtitleLabel.text = "register_subtitle".localized
        registerButton.setTitle("register_title".localized, for: .normal)
        nameTextField
            .setPlaceholder("register_name_placeholder".localized)
            .setTextContentType(.name)
            .setImage(UIImage(systemName: "person")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)))
        surnameTextField
            .setPlaceholder("register_surname_placeholder".localized)
            .setTextContentType(.familyName)
            .setImage(UIImage(systemName: "person.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)))
        emailTextField
            .setPlaceholder("email_address_placeholder".localized)
            .setTextContentType(.emailAddress)
        passwordTextField
            .setPlaceholder("password_placeholder".localized)
            .setTextContentType(.password)
            .setImage(UIImage(systemName: "lock")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)))
            .setSecureInput(true)
            .onTextFieldReturn = { [weak self] in
                self?.registerButtonPressed()
            }
    }
    
    @IBAction private func registerButtonPressed() {
        view.endEditing(true)
        do {
            try registrationDataModel.register(withName: nameTextField.text,
                                               surname: surnameTextField.text,
                                               email: emailTextField.text,
                                               password: passwordTextField.text)
        } catch ValidationError.emptyEmailField {
            view.makeToast(ValidationError.emptyEmailField.localizedDescription)
            emailTextField.setState(.error)
        } catch ValidationError.emptyPasswordField {
            view.makeToast(ValidationError.emptyEmailField.localizedDescription)
            passwordTextField.setState(.error)
        } catch ValidationError.emptyEmailAndPassword {
            view.makeToast(ValidationError.emptyEmailField.localizedDescription)
            emailTextField.setState(.error)
            passwordTextField.setState(.error)
        } catch {
            // Unknown
        }
    }
}

extension RegistrationViewController: RegistrationDataModelDelegate {
    func registrationDataModelDidSignUpSuccessfully(_ dataModel: RegistrationDataModel) {
        self.view.makeToast("registration_success".localized)
        performSegue(identifier: .unwindFromRegistration, sender: nil)
    }
    
    func registrationDataModel(_ dataModel: RegistrationDataModel, failedWithError error: Error) {
        if let error = error as? AppError {
            switch error {
            case .noFirebaseUser:
                let error = AppError.noFirebaseUser
                view.makeToast(error.localizedDescription)
            case .noIDToken:
                let error = AppError.noIDToken
                view.makeToast(error.localizedDescription)
            case .emailAlreadyInUse:
                let error = AppError.emailAlreadyInUse
                view.makeToast(error.localizedDescription)
                emailTextField.setState(.error)
            }
        } else {
            self.handleError(error)
        }
    }
    
}
