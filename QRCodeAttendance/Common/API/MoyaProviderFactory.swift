//
//  MoyaProviderFactory.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Foundation
import Moya
import FirebaseAuth

protocol FirebaseAuthorizableTargetType: TargetType {}

class MoyaProviderFactory {
    private init() {}

    static func make<T: TargetType>(_: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>(/* your params */)
    }
    
    static func makeAuthorizable<T: FirebaseAuthorizableTargetType>(_: T.Type, firebaseAuth: Auth = Auth.auth()) -> MoyaProvider<T> {
        let requestClosure = { (endpoint: Endpoint, closure: @escaping MoyaProvider.RequestResultClosure) in
            do {
                var urlRequest = try endpoint.urlRequest()
                if let cu = firebaseAuth.currentUser {
                    cu.getIDTokenForcingRefresh(true) { (token, _) in
                        if let token = token {
                            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                            closure(.success(urlRequest))
                        } else {
                            closure(.failure(.underlying(NSError(domain: "Custom error", code: -1000, userInfo: nil), nil)))
                        }
                    }
                } else {
                    closure(.failure(.underlying(NSError(domain: "No Firebase User found", code: -1001, userInfo: nil), nil)))
                }
            } catch MoyaError.requestMapping(let url) {
                closure(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error) {
                closure(.failure(MoyaError.parameterEncoding(error)))
            } catch {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
        return MoyaProvider<T>(requestClosure: requestClosure, plugins: [NetworkLoggerPlugin()])
    }
}
