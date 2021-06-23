//
//  RegistrationNetworkManager.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-15.
//

import Foundation
import Moya
import FirebaseAuth

protocol RegisterNetworkable: Networkable {
    func register(name: String, surname: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
}

class RegisterNetworkManager: RegisterNetworkable {
    var provider: MoyaProvider<AttendanceAPI>
    
    init(provider: MoyaProvider<AttendanceAPI>) {
        self.provider = provider
    }
    
    func register(name: String, surname: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (_, error) in
            guard let self = self else { return }
            if let error = error {
                if (error as NSError).code == 17007 {
                    completion(.failure(AppError.emailAlreadyInUse))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            self.createUser(withName: name, surname: surname, completion: completion)
        }
    }
    
    private func createUser(withName name: String, surname: String, completion: @escaping (Result<User, Error>) -> Void) {
        request(target: .createUser(name: name, surname: surname), completion: completion)
    }
}

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }

        return prettyPrintedString
    }
}
