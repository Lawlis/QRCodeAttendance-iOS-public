//
//  UIApplicationExtensions.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit

extension UIApplication {

    /// The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

}
