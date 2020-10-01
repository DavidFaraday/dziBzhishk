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
    func downloadCurrentUser(with userId: String) {

        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in

            guard let document = querySnapshot else {
                print("no document for StableUser")
                return
            }

            let result = Result {
                try? document.data(as: User.self)
            }

            switch result {
            case .success(let userObject):
                
                if let user = userObject {
                    self.saveUserLocally(user)
                }
            case .failure(let error):
                print("<<<<Debug Error decoding StableUser: \(error)")
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
                    print("no document for user per id")
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

            guard let documents = querySnapshot?.documents else {
                print("no document for all users")
                return
            }

            var allUsers = documents.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            allUsers.sort(by: { $0.isOnline && !$1.isOnline })
            completion(allUsers)
        }
    }


    
    //MARK: - Saving user
    func saveUserToFireStore(_ user: User) {
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
            print("<<<<Debug Saved FB user")
        } catch {
            print("<<<<Debug adding user, ", error.localizedDescription)
        }
    }

    func saveUserLocally(_ user: User) {
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            userDefaults.set(data, forKey: AppConstants.CurrentUser.rawValue)
            print("<<<<Debug Saved local user")

        } catch {
            print("error saving user locally, ", error.localizedDescription)
        }
    }

}
