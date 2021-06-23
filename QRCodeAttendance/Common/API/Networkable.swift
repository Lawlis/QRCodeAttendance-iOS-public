//
//  Networkable.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-21.
//

import Foundation
import Moya

protocol Networkable {
    var provider: MoyaProvider<AttendanceAPI> { get }
    
    func request<T: Decodable>(target: AttendanceAPI, completion: @escaping (Result<T, Error>) -> Void)
    func emptyResponseRequest(target: AttendanceAPI, completion: @escaping (Result<Void, Error>) -> Void)
}

extension Networkable {
    func request<T: Decodable>(target: AttendanceAPI, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { (result) in
            switch result {
            case let .success(response):
                do {
                    print(response.data.prettyJson ?? "")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateTools.iso8601)
                    let results = try decoder.decode(T.self, from: response.data)
                    completion(.success(results))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func emptyResponseRequest(target: AttendanceAPI, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(target) { (result) in
            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
