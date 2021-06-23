//
//  NetworkManager.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Foundation
import Moya
import FirebaseAuth

protocol LoginNetworkable: Networkable {
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
}

class LoginNetworkManager: LoginNetworkable {
    var provider: MoyaProvider<AttendanceAPI>
    
    init(provider: MoyaProvider<AttendanceAPI>) {
        self.provider = provider
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                print("Failed firebase login with error: \(error)")
                completion(.failure(AppError.noFirebaseUser))
                return
            }
            
            guard let result = result else {
                print("Firebase login with no error but failed to unwrap result")
                completion(.failure(AppError.noFirebaseUser))
                return
            }
            
            self.getUser(withId: result.user.uid, completion: completion)
        }
    }
    
    func getUser(withId id: String, completion: @escaping (Result<User, Error>) -> Void) {
        request(target: .getUser(id: id), completion: completion)
    }
}
