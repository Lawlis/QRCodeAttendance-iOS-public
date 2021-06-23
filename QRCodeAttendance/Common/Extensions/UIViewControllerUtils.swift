//
//  UIViewControllerUtils.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-02.
//

import UIKit
import SafariServices

extension UIViewController {
    
    func performSegue(identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    /// Root view controller.
    ///
    /// UINavigationController returns `viewControllers.first`.
    /// Any other view controller first returns childViewControllers.first, then self.
    ///
    /// - Returns: Currently visible view controller.
    func rootViewController() -> UIViewController {
        if let navigationController = self as? UINavigationController,
            let visibleViewController = navigationController.viewControllers.first {
            return visibleViewController
        }
        return self
    }
    
    /// Will return previous ViewController in navigation stack
    func previousViewController() -> UIViewController? {
        if let stack = navigationController?.viewControllers {
            for index in (1..<stack.count).reversed() where stack[index] == self {
                return stack[index - 1]
            }
        }
        return nil
    }
}

extension UIViewController {

    /// Opens an url in an in-app browser.
    ///
    /// - Parameter url: An url to open.
    func open(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }

}

extension UIViewController {
    static func initFromNib() -> Self {
        func instanceFromNib<T: UIViewController>() -> T {
            return T(nibName: String(describing: self), bundle: nil)
        }
        return instanceFromNib()
    }
}
