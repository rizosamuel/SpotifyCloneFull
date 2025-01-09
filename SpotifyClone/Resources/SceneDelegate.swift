//
//  SceneDelegate.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, FileIdentifier {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowsScene)
        window?.rootViewController = getFirstViewController()
        window?.makeKeyAndVisible()
    }
    
    private func getFirstViewController() -> UIViewController {
        if AuthManager.shared.isSignedIn {
            print("\n[\(fileName)] YOU ARE SUCCESSFULLY SIGNED IN")
            AuthManager.shared.refreshAccessToken(completion: nil)
            let isAppLock = UserDefaults.standard.bool(forKey: Constants.IS_APP_LOCK_KEY)
            return isAppLock ? BiometricsViewController() : TabBarController()
        } else {
            return UINavigationController(rootViewController: WelcomeViewController())
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("Inside url contexts", URLContexts.first?.url ?? "")
    }
}
