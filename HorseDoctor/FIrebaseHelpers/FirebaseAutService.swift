//
//  FirebaseAuthService.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
 
    static let shared = FirebaseAuthService()

    private init() {}

    
    //MARK: - Login
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {

        print("<<<<Debug Login User")
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in

            if error == nil {
                FirebaseUserListener.shared.downloadCurrentUser(with: authDataResult!.user.uid)
            }
            
            completion(error)
        }
    }

    //MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void ) {
        
        print("<<<<Debug Register User")

        Auth.auth().createUser(withEmail: email, password: password, completion: { (authDataResult, error) in

            completion(error)

            if error == nil {

                //create user and save it
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, name: email, email: email, pushId: "", avatarLink: "", address: "", telephone: "", mobilePhone: "", isOnboardingCompleted: false, userType: UserType.Stable.rawValue, isOnline: false)
                                        
                    FirebaseUserListener.shared.saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
            }
        })
    }

    //MARK: - LogOut
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {

        do {
            print("<<<<Debug Log out")
            try Auth.auth().signOut()

            userDefaults.removeObject(forKey: AppConstants.CurrentUser.rawValue)
            userDefaults.synchronize()
            completion(nil)

        } catch let error as NSError {
            completion(error)
        }
    }


    
}
