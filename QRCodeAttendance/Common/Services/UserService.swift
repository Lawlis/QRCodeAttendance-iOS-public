//
//  UserService.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Foundation
import FirebaseAuth

class UserService {
    
    // MARK: - Constants
    
    static let shared = UserService()
    
    private let storage = UserDefaults.standard
    
    let currentUserKey = "CurrentUser"
    
    // MARK: - States
    
    var currentUser: User? {
        get {
            storage.loadEntity(forKey: currentUserKey)
        }
        set {
            storage.storeEntity(newValue, forKey: currentUserKey)
        }
        
    }
    
    var hasUser: Bool {
        currentUser != nil
    }
    
    // MARK: - Init
    
    private init() {}
}
