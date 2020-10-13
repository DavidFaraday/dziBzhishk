//
//  AppDelegate.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        requestPushNotificationPermission()
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0

        LocationManager.shared.startUpdating()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

      completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }


    //MARK: - PushNotifications
    private func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {_, _ in })

    }

}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
        
        let userInfo = response.notification.request.content.userInfo
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        // root view controller is tab bar controller
        // the selected tab is a navigation controller
        // then we push the new view controller to it
        if let tabBarController = rootViewController as? UITabBarController,
           let navController = tabBarController.selectedViewController as? UINavigationController {
            
            //check if its a chat notification
            if userInfo["chatRoomId"] != nil && userInfo["chatRoomId"] as! String != "" {
                
                if let chatView = navController.visibleViewController as? ChatViewController {
                    //we have chat room as current view
                    if chatView.chatId == userInfo["chatRoomId"] as? String {
                        return
                    }
                }
                
                
                //we have other view as current view
                let chatView = ChatViewController(chatId: userInfo["chatRoomId"] as! String, recipientId: userInfo["senderId"] as! String, recipientName: titleFromNotification(payload: userInfo))
                
                navController.pushViewController(chatView, animated: true)
            }
            
            
            //check if its a emergency notification
            if userInfo["emergencyId"] != nil && userInfo["emergencyId"] as! String != "" {

                let emergencyView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EmergencyDetailView") as! EmergencyDetailTableViewController
                emergencyView.emergencyId = userInfo["emergencyId"] as! String
                navController.pushViewController(emergencyView, animated: true)
            }

        }
    }

    //MARK: - Helpers
    private func titleFromNotification(payload: [AnyHashable : Any]) -> String {
        
        var title = "Unknown"
        
        if let aps = payload["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                title = alert["title"] as? String ?? "Unknown"
            }
        }
        
        return title

    }
    
}


extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateUserPushId(newPushId: fcmToken)
    }
}
