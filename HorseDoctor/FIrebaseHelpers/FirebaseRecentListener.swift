//
//  FirebaseRecentListener.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import Foundation
import Firebase

class FirebaseRecentListener {
    
    static let shared = FirebaseRecentListener()
    
    private init() {}

    /// Starts listening for recents from FIrebase for current user, returns recents
    ///
    /// - Parameters:
    ///   - callback: All up to date recents of current user.
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {

        FirebaseReference(.Recent).whereField(AppConstants.senderId.rawValue, isEqualTo: User.currentId).addSnapshotListener() { (querySnapshot, error) in

            var recentChats: [RecentChat] = []

            guard let documents = querySnapshot?.documents else {
                print("no document for recent chats")
                return
            }

            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in

                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }

            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }

            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
        }
    }
    
    /// Updates recentObjects of the chat with given last message
    ///
    /// - Parameters:
    ///   - chatRoomId: The `Id` of chatroom.
    ///   - lastMessage: The `lastMessage` sent.
    func updateRecents(with chatRoomId: String, with lastMessage: String) {

        FirebaseReference(.Recent).whereField(AppConstants.chatRoomId.rawValue, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }

            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }

            for recentChat in allRecents {
                self.update(recentChat, with: lastMessage)
            }
        }
    }
    

    /// Resets the counter of the recent object that belongs to current user in specific chatroom
    ///
    /// - Parameters:
    ///   - chatRoomId: The `Id` of chatroom where user is member.
    func resetRecentCounter(of chatRoomId: String) {

        FirebaseReference(.Recent).whereField(AppConstants.chatRoomId.rawValue, isEqualTo: chatRoomId).whereField(AppConstants.senderId.rawValue, isEqualTo: User.currentId).getDocuments { (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("no document for recent counter")
                return
            }

            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }

            if allRecents.count > 0 {
                self.clearUnreadCounter(of: allRecents.first!)
            }
        }
    }

    /// The function resents the counter of specific recent object
    ///
    /// - Parameters:
    ///   - recent: The `RecentChat` to reset counter for.

    func clearUnreadCounter(of recent: RecentChat) {

        var recent = recent
        recent.unreadCounter = 0

        self.saveRecent(recent)
    }
    
    /// Updates specific RecentObject with given last message, increments unread for other member
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent to update.
    ///   - lastMessage: The `lastMessage` sent.

    private func update(_ recent: RecentChat, with lastMessage: String) {

        var recent = recent

        if recent.senderId != User.currentId {
            recent.unreadCounter += 1
        }

        recent.lastMessage = lastMessage
        recent.date = Date()

        self.saveRecent(recent)
    }

    
    //MARK: - Add Update Delete
    /// Saves Specific Recent Object to firebase
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent Object.
    func saveRecent(_ recent: RecentChat) {

        do {
            let _ = try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print(error.localizedDescription, "adding recent....")
        }
    }


    /// Deletes Specific Recent Object from firebase
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent Object.
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
}
