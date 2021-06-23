//
//  UIStoryboard.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-11.
//

import UIKit

extension UIStoryboard {
    
    static var onboarding: UIStoryboard {
        UIStoryboard(name: "Onboarding", bundle: nil)
    }
    
    static var more: UIStoryboard {
        UIStoryboard(name: "More", bundle: nil)
    }
    
    static var courses: UIStoryboard {
        UIStoryboard(name: "Courses", bundle: nil)
    }
    
    static var tabBar: UIStoryboard {
        UIStoryboard(name: "TabBar", bundle: nil)
    }
}

// Couple of convenience methods for easier view controller instantiation from
// storyboards.
extension UIStoryboard {
    
    /// Instantiates a view controller from storyboard based on its class name.
    ///
    /// - Parameter viewControllerType: The type of the view controller to instantiate.
    /// - Returns: A view controller, or nil if instantiation failed
    func instantiate<ViewController>(_ viewControllerType: ViewController.Type) -> ViewController? {
        let storyboardIdentifier = String(describing: viewControllerType)
        return instantiateViewController(with: storyboardIdentifier)
    }
    
    /// Instantiates a view controller from storybaord and casts it to provided generic type of ViewController.
    ///
    /// - Parameter identifier: An identifier used to instantiate a view controller from storyboard.
    /// - Returns: A view controller, or nil if instantiation failed.
    func instantiateViewController<ViewController>(with identifier: String) -> ViewController? {
        let aViewController = instantiateViewController(withIdentifier: identifier)
        return aViewController as? ViewController
    }
    
    /// Gives initial `UIViewController` from `UIStoryboard` or fatal error
    func initialViewController() -> UIViewController {
        guard let viewController = self.instantiateInitialViewController() else {
            fatalError("WARNING: failed to instantiate initialViewController for storyboard")
        }
        return viewController
    }
    
    /// Gives initial `UIViewController` from `UIStoryboard` or fatal error
    /// - Parameter type: Type of ViewController
    func initialViewController<T: UIViewController>(castAs type: T.Type) -> T {
        guard let viewController = self.instantiateInitialViewController() as? T else {
            fatalError("WARNING: failed to instantiate initialViewController for storyboard")
        }
        return viewController
    }
}
