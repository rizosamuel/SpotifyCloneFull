//
//  AppDelegate.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, FileIdentifier {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("[\(fileName)] APP LAUNCH IS SUCCESSFULL")
        AuthManager.setupManager()
        APIManager.setupManager()
        BiometricsManager.setupManager()
        print("\n[\(fileName)] THE SIGN-IN URL FOR AUTHORIZATION:", AuthManager.shared.signInURL?.absoluteString ?? "")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("inside open delegate")
        return true
    }
}
