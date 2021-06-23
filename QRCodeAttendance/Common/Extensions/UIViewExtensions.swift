//
//  UIViewExtensions.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-04.
//

import Foundation
import UIKit

enum AnimationEdge {
    case left
    case right
}

// MARK: - Hide
extension UIView {
    
    // MARK: - Constants
    
    static let fadeTransitionDuration: TimeInterval = 0.4
    
    /**
     Hides or shows a view animated.
     
     - parameter isHidden: Specifies if view should be hidden or shown.
     - parameter animated: Identifies if transition should be animated.
     */
    func setIsHidden(_ isHidden: Bool, animated: Bool) {
        guard isHidden != self.isHidden else {
            return
        }

        if animated {
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3
            layer.add(transition, forKey: "transition")
        }
        
        self.isHidden = isHidden
    }
}

// MARK: - Xibs
extension UIView {

    /**
     Loading view from .xib

     Depends on `StringExtensions.swift` to get class name
     */
    static func fromNib<T: UIView>() -> T? {
        let name = String.classNameAsString(T.self)

        guard let nibs = Bundle.main.loadNibNamed(name, owner: nil, options: nil), let nib = nibs[0] as? T else {
            print("nib named `\(name)` does not exist")
            return nil
        }

        return nib
    }

    /**
     Loading content from .xib

     How to setup custom view:
     - In .xib file - custom view class MUST be declared in `File's Owner / Identity inspector`
     - In .swift file - `loadContentFromNib()` MUST be called in methods like `init?(coder aDecoder: NSCoder)`, `init(frame: CGRect)`

     How to use custom view class in another .xib files:
     - Add view to .xib
     - Set custom class in `Identity inspector`

     Depends on `StringExtensions.swift` to get class name
     */
    @discardableResult
    func loadContentFromNib<T: UIView>() -> T? {
        let name = String.classInstanceNameAsString(self)

        guard let nibs = Bundle.main.loadNibNamed(name, owner: self, options: nil) else {
            print("nib named `\(name)` does not exist")
            return nil
        }

        guard let view = nibs[0] as? T else {
            print("view kind of `\(T.self)` does not exist")
            return nil
        }

        self.addSubview(view)
        view.pinViewToEdgesOf(parentView: self)

        return view
    }
}

// MARK: - Autolayouts
extension UIView {

    func pinViewToEdgesOf(parentView: UIView, with insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        pinViewToHorizontalEdgesOf(parentView: parentView, with: insets)
        pinViewToVerticalEdgesOf(parentView: parentView, with: insets)
    }

    func pinViewToHorizontalEdgesOf(parentView: UIView, with insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -insets.right).isActive = true
    }

    func pinViewToVerticalEdgesOf(parentView: UIView, with insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: parentView.topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: insets.bottom).isActive = true
    }
    
    // MARK: - Transitions
    
    /// Animates `UIView` with `kCATransitionFade`
    ///
    /// - Parameter duration: value to specify how long animation should last
    func fadeTransition(_ duration: CFTimeInterval = UIView.fadeTransitionDuration) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

// MARK: - Animations
extension UIView {
    
    /// Adds CATransition to view layer to animates its content change with
    /// a push from bottom animation.
    func addPushFromBottomTransition() {
        let transition = CATransition()
        transition.type = .push
        // This subtype is ok, somehow its naming is reversed,
        transition.subtype = .fromTop
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(transition, forKey: "transition")
    }
    
    /// Adds CATransition to view layour to animate content with sliding animation.
    ///
    /// - Parameters:
    ///   - edge: where to start animating.
    ///   - duration: how long will animation last.
    func slide(from edge: AnimationEdge, duration: TimeInterval = 0.35) {
        let transition = CATransition()
        transition.type = .push
        switch edge {
        case .left:
            transition.subtype = .fromLeft
        case .right:
            transition.subtype = .fromRight
        }
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.fillMode = .removed
        
        // Add the animation to the View's layer
        layer.add(transition, forKey: "slideTransition")
    }
}
