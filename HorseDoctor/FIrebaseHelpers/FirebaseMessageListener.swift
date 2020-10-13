//
//  FirebaseMessageListener.swift
//  HorseDoctor
//
//  Created by David Kababyan on 21/09/2020.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    
    static let shared = FirebaseMessageListener()
    
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    
    private init() {}
    
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(AppConstants.date.rawValue, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                
                if change.type == .added {
                    
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            
                            if message.senderId != User.currentId {
                                RealmManager.shared.saveToRealm(message)
                            }
                            
                        }
                    case .failure(let error):
                        #if DEBUG
                        print("Error decoding local message: \(error)")
                        #endif
                    }
                }
            }
        })
    }
    
    
    func checkForOldChats(_ documentId: String, collectionId: String) {
        
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                #if DEBUG
                print("no document for old chats")
                #endif
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: { $0.date < $1.date })
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
        }
    }
    
    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        
        updatedChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ (querySnapshot, error) in
            
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                
                if change.type == .modified {
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject {
                            completion(message)
                        }
                        
                    case .failure(let error):
                        #if DEBUG
                        print("Error decoding local message: \(error)")
                        #endif
                    }
                }
            }
        })
    }
    
    
    //MARK: - Add Update Delete
    /// Saves Specific Recent Object to firebase
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent Object.
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            let _ = try             FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }
        catch {
            print(error.localizedDescription, "adding message....")
        }
    }
    
    
    //MARK: - Update
    func updateMessageInFireStore(_ message: LocalMessage, memberIds: [String]) {
        
        let values = [AppConstants.status.rawValue : AppConstants.read.rawValue, AppConstants.readDate.rawValue : Date()] as [String : Any]
        
        for userId in memberIds {

            FirebaseReference(.Messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
        #if DEBUG
        print("updated both messages status to Read")
        #endif
    }
    
    
    func removeMessageListener() {
        if newChatListener != nil {
            newChatListener.remove()
        }
        
        if updatedChatListener != nil {
            updatedChatListener.remove()
        }
    }
}
