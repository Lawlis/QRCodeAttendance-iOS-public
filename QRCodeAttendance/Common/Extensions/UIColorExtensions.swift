//
//  UIColorExtensions.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit.UIColor

public extension UIColor {
    
    static func named(_ name: String, compatibleWith traitCollection: UITraitCollection? = nil) -> UIColor? {
        return UIColor(named: name, in: .main, compatibleWith: traitCollection)
    }
    
    // MARK: - Accents
    
    // swiftlint:disable force_unwrapping

    static func primaryAccent() -> UIColor {
        return Self.named("PrimaryAccent")!
    }
    
    static func primaryText() -> UIColor {
        return Self.named("PrimaryText")!
    }
    
    // MARK: - Borders

    static func lightGrayBorder() -> UIColor {
        return Self.named("LightGrayBorder")!
    }
    
    // MARK: - Additional
    
    static func additional() -> UIColor {
        return Self.named("Additional")!
    }
}
