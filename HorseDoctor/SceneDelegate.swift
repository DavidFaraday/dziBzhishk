//
//  SceneDelegate.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        autologin()
        resetBudge()

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
        resetBudge()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        setUser(isOnline: true)
        LocationManager.shared.startUpdating()
        resetBudge()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        LocationManager.shared.stopUpdating()
        resetBudge()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
        resetBudge()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        setUser(isOnline: false)
        LocationManager.shared.stopUpdating()
        resetBudge()
    }

    //MARK: - Autologin
    func autologin() {
        
        authListener = Auth.auth().addStateDidChangeListener { auth, user in
        
            Auth.auth().removeStateDidChangeListener(self.authListener!)

            if user != nil && userDefaults.object(forKey: AppConstants.CurrentUser.rawValue) != nil {

                if let currentUser = User.currentUser {
                    if currentUser.isOnboardingCompleted {
                        DispatchQueue.main.async {
                            self.goToApp()
                        }
                    }
                }
            }
        }
    }

    private func goToApp() {
    
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainApp") as! UITabBarController
        
        self.window?.rootViewController = mainView
    }

    private func resetBudge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
}

