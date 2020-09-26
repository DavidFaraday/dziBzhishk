//
//  PushNotifications.swift
//  HorseDoctor
//
//  Created by David Kababyan on 26/09/2020.
//

import Foundation

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    private init() {}
    
    func sendPushNotificationTo(userIds: [String], body: String, chatRoomId: String) {
        
        FirebaseUserListener.shared.downloadUser(with: userIds) { (users) in
            
            for user in users {

                let title = User.currentUser?.name ?? "User"
                
                self.sendMessageToUser(to: user.pushId, title: title, body: body, chatRoomId: chatRoomId)
            }
        }
    }

    private func sendMessageToUser(to token: String, title: String, body: String, chatRoomId: String) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        
        let url = NSURL(string: urlString)!
        
        let paramString: [String : Any] = ["to" : token,
                                           "notification" :
                                            ["title" : title,
                                             "body" : body,
                                             "badge" : "1",
                                             "sound" : "default"
                                            ],
                                           "data" : ["chatRoomId" : chatRoomId,
                                                     "senderId" : User.currentId
                                                    ]
            //this is to pass extra info with message
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key= \(AppConstants.pushServerKey.rawValue)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
            
        task.resume()
    }
}
