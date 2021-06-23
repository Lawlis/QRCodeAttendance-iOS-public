//
//  SceneDelegate.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit
import FirebaseAuth
import Moya

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        UITabBar.appearance().tintColor = .primaryAccent()
        UINavigationBar.appearance().tintColor = .primaryAccent()

        guard let windowScene = (scene as? UIWindowScene) else { return }

        self.window = UIWindow(windowScene: windowScene)
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard.tabBar
            guard let rootVC = storyboard.instantiate(TabBarViewController.self) else {
                print("ViewController not found")
                return
            }
            self.window?.rootViewController = rootVC
            
            let provider = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
            let loginNetworkManager = LoginNetworkManager(provider: provider)
            // swiftlint:disable:next force_unwrapping
            loginNetworkManager.getUser(withId: Auth.auth().currentUser!.uid, completion: { [unowned self] result in
                switch result {
                case .success(let user):
                    UserService.shared.currentUser = user
                    self.window?.makeKeyAndVisible()
                case .failure(let error):
                    print(error.localizedDescription)
                    showOnboarding()
                }
            })
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        let storyboard = UIStoryboard.onboarding
        guard let rootVC = storyboard.instantiate(LoginViewController.self) else {
            print("ViewController not found")
            return
        }
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
    }
    
    func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard animated, let window = self.window else {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            return
        }

        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}
