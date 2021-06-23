//
//  ReplaceRootSegue.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit

class ReplaceRootSegue: UIStoryboardSegue {
    
    override func perform() {
        guard let window = source.window else {
            fatalError("Couldn't find window for segue source: \(source)")
        }
        // Set the new rootViewController of the window.
        // Calling "UIView.transition" below will animate the swap.
        window.rootViewController = destination

        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .transitionCrossDissolve

        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.5

        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
    }

}

// swiftlint:disable force_cast
extension UIViewController {
      var appDelegate: AppDelegate {
      return UIApplication.shared.delegate as! AppDelegate
  }
  
  var sceneDelegate: SceneDelegate? {
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let delegate = windowScene.delegate as? SceneDelegate else { return nil }
       return delegate
  }
}

extension UIViewController {
  var window: UIWindow? {
      if #available(iOS 13, *) {
          guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
                 return window
      }
      
      guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
      return window
  }
}
