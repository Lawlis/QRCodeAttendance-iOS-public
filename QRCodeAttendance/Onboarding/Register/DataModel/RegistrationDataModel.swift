//
//  RegistrationDataModel.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-15.
//

import Foundation
import Moya

protocol RegistrationDataModelDelegate: AnyObject {
    func registrationDataModelDidSignUpSuccessfully(_ dataModel: RegistrationDataModel)
    func registrationDataModel(_ dataModel: RegistrationDataModel, failedWithError error: Error)
}

class RegistrationDataModel {
    
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    private let networkManager: RegisterNetworkManager
    private weak var delegate: RegistrationDataModelDelegate?
    
    init(delegate: RegistrationDataModelDelegate) {
        self.delegate = delegate
        self.networkManager = RegisterNetworkManager(provider: provider)
    }
    
    func register(withName name: String, surname: String, email: String, password: String) throws {
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
        
        networkManager.register(name: name, surname: surname, email: email, password: password) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let userResponse):
                print("success: \(userResponse)")
                UserService.shared.currentUser = userResponse
                self.delegate?.registrationDataModelDidSignUpSuccessfully(self)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.delegate?.registrationDataModel(self, failedWithError: error)
            }
        }
    }
}
