//
//  FirebaseUserListener.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import Foundation
import Firebase

class FirebaseUserListener {
 
    static let shared = FirebaseUserListener()

    private init() {}
    
    //MARK: - Fetching
    func downloadCurrentUser(with userId: String, completion: @escaping (_ isCompleted: Bool) -> Void ) {

        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in

            guard let document = querySnapshot else {
                #if DEBUG
                print("no document for StableUser")
                #endif
                completion(false)
                return
            }

            let result = Result {
                try? document.data(as: User.self)
            }

            switch result {
            case .success(let userObject):
                
                if let user = userObject {
                    self.saveUserLocally(user)
                    completion(true)
                }
            case .failure(let error):
                
                completion(false)
                #if DEBUG
                print("<<<<Debug Error decoding StableUser: \(error)")
                #endif
            }
        }
    }

    func downloadUser(with iDs: [String], completion: @escaping (_ users: [User]) -> Void ) {

        var count = 0
        var usersArray: [User] = []

        //go through each user and download it from firestore
        for userId in iDs {

            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in

                guard let document = querySnapshot else {
                    #if DEBUG
                    print("no document for user per id")
                    #endif
                    completion(usersArray)
                    return
                }

                let user = try? document.data(as: User.self)

                usersArray.append(user!)
                count += 1

                if count == iDs.count {
                    completion(usersArray)
                }
            }
        }
    }

    func downloadUserType(with type: UserType, completion: @escaping (_ users: [User]) -> Void ) {

        
        FirebaseReference(.User).whereField(AppConstants.userType.rawValue, isEqualTo: type.rawValue).addSnapshotListener { (querySnapshot, error) in

            var users:[User] = []

            guard let documents = querySnapshot?.documents else {
                #if DEBUG
                print("no document for all users")
                #endif
                return
            }

            let allUsers = documents.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                //don't add current users
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            users.sort(by: { $0.isOnline && !$1.isOnline })
            completion(users)
        }
    }

    func downloadDoctorsForPush(completion: @escaping (_ users: [User]) -> Void ) {

        FirebaseReference(.User).whereField(AppConstants.userType.rawValue, isEqualTo: UserType.Doctor.rawValue).getDocuments { (querySnapshot, error) in
            
            var users:[User] = []

            guard let documents = querySnapshot?.documents else {
                #if DEBUG
                print("no document for all users")
                #endif
                return
            }

            let allUsers = documents.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                //don't add current users
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            users.sort(by: { $0.isOnline && !$1.isOnline })
            completion(users)
        }
    }

    
    //MARK: - Saving user
    func saveUserToFireStore(_ user: User) {
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
            #if DEBUG
            print("<<<<Debug Saved FB user")
            #endif
        } catch {
            #if DEBUG
            print("<<<<Debug adding user, ", error.localizedDescription)
            #endif
        }
    }
    
    func saveUserToFireStore(_ user: User, completion: @escaping (_ didUpdateUser : Bool ) -> Void ) {
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
            completion(true)
            #if DEBUG
            print("<<<<Debug Saved FB user")
            #endif
        } catch {
            completion(false)
            #if DEBUG
            print("<<<<Debug adding user, ", error.localizedDescription)
            #endif
        }
    }


    func saveUserLocally(_ user: User) {
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            userDefaults.set(data, forKey: AppConstants.CurrentUser.rawValue)
            #if DEBUG
            print("<<<<Debug Saved local user")
            #endif
        } catch {
            #if DEBUG
            print("error saving user locally, ", error.localizedDescription)
            #endif
        }
    }

}
