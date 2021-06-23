//
//  LoginDataModel.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-14.
//

import Foundation
import FirebaseAuth
import Moya

protocol LoginDataModelDelegate: AnyObject {
    func loginDataModelDidLoginSuccessfully(_ dataModel: LoginDataModel)
    func loginDataModelStartedLoading(_ dataModel: LoginDataModel)
    func loginDataModelFailedLogin(_ dataModel: LoginDataModel, error: Error)
    func loginDataModel(_ dataModel: LoginDataModel, didFindProviderWithEmail email: String, credential: AuthCredential)
}

class LoginDataModel {
    
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    private let networkManager: LoginNetworkManager
    private weak var delegate: LoginDataModelDelegate?
    
    init(delegate: LoginDataModelDelegate) {
        self.delegate = delegate
        self.networkManager = LoginNetworkManager(provider: provider)
    }
    
    func login(withEmail email: String, password: String) throws {
        guard !email.isEmpty,
              !password.isEmpty else {
            throw ValidationError.emptyEmailAndPassword
        }
        
        guard !email.isEmpty else {
            throw ValidationError.emptyEmailField
        }
        
        guard !password.isEmpty else {
            throw ValidationError.emptyPasswordField
        }
        
        delegate?.loginDataModelStartedLoading(self)
        
        networkManager.login(email: email, password: password) { (result) in
            switch result {
            case .success(let userResponse):
                print("success: \(userResponse)")
                UserService.shared.currentUser = userResponse
                self.delegate?.loginDataModelDidLoginSuccessfully(self)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.delegate?.loginDataModelFailedLogin(self, error: error)
            }
        }
    }
    
    func login(withCredential credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] (result, err) in
            guard let self = self else { return }
            if let error = err {
                if let errorCode = AuthErrorCode(rawValue: error._code),
                   errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                    guard let email: String = (error as NSError).userInfo["FIRAuthErrorUserInfoEmailKey"] as? String else {
                        fatalError()
                    }
                    // swiftlint:disable:next line_length
                    guard let credential: AuthCredential = (error as NSError).userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential else {
                        fatalError()
                    }
                    Auth.auth().fetchSignInMethods(forEmail: email) { (providers, error) in
                        guard let providers = providers else {
                            print("No providers for user with email: \(email)")
                            // swiftlint:disable:next force_unwrapping
                            self.delegate?.loginDataModelFailedLogin(self, error: error!)
                            return
                        }
                        if providers.contains("password") {
                            self.delegate?.loginDataModel(self, didFindProviderWithEmail: email, credential: credential)
                            return
                        }
                    }
                } else {
                    self.delegate?.loginDataModelFailedLogin(self, error: error)
                }
            } else if let result = result {
                self.networkManager.getUser(withId: result.user.uid) { (result) in
                    switch result {
                    case .success(let user):
                        UserService.shared.currentUser = user
                        self.delegate?.loginDataModelDidLoginSuccessfully(self)
                    case .failure(let error):
                        self.delegate?.loginDataModelFailedLogin(self, error: error)
                    }
                }
            }
        }
    }
}
