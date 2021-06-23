//
//  TabBarViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-11.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    enum Screen: CaseIterable {
        case myCourses
        case events
        case myQR
        case more
        
        var title: String {
            switch self {
            case .myCourses:
                return "Courses".localized
            case .events:
                return "Events"
            case .myQR:
                return "My QR"
            case .more:
                return "More".localized
            }
        }
    }
    
    var screens = Screen.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.items?.forEach { (item) in
            item.image = item.image?.withRenderingMode(.alwaysTemplate)
        }
        guard let viewControllers = viewControllers else {
            return
        }
        for index in viewControllers.indices {
            guard screens.count > index else {
                return
            }
            viewControllers[index].title = screens[index].title
        }
        
        selectedIndex = 0
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }
}
