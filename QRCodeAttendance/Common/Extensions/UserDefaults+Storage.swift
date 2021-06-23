//
//  UserDefaults+Storage.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Foundation

extension UserDefaults {
    /**
     Stores an entity in user defaults.
     
     - parameter entity: An entity to store. May be nil to remove the entity.
     - parameter key: A key used to store the entity.
     */
    func storeEntity<T: Encodable>(_ entity: T?, forKey key: String) {
        if let entity = entity {
            do {
                let jsonObject = try JSONEncoder().encode(entity)
                set(jsonObject, forKey: key)
            } catch {
                print("Failed to save jsonObject")
            }
        } else {
            removeObject(forKey: key)
        }
        synchronize()
    }
    
    /**
     Loads a data entity from persistent storage.
     
     - returns: A data entity if it was successfully retreived from persistent storage,
     otherwise nil.
     */
    func loadEntity<T: Decodable>(forKey key: String) -> T? {
        guard let data = data(forKey: key) else {
            return nil
        }
        do {
            let entity = try JSONDecoder().decode(T.self, from: data)
            return entity
        } catch {
            print("WARNING: unable to decode JSON: \(String(describing: String(bytes: data, encoding: .utf8)))")
            return nil
        }
    }
}
