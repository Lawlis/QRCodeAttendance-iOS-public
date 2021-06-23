//
//  AppDelegate.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-02.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userService: UserService!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Convience extensions
extension AppDelegate {
    /// A user service that is used to store current user data.
    static var userService: UserService {
        return UIApplication.shared.appDelegate.userService
    }

}

// swiftlint:disable force_cast
extension UIApplication {

    /// Casts delegate property to AppDelegate type.
    var appDelegate: AppDelegate {
        return delegate as! AppDelegate
    }

    private static let firstLaunchKey = "AlreadyLaunched"

    static var isFirstLaunch: Bool {
        let alreadyLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !alreadyLaunched {
            setFirstLaunchFlag()
        }
        return !alreadyLaunched
    }

    private static func setFirstLaunchFlag() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
    }
}
