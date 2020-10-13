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
    func loginUser(with email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in

            if error == nil && authDataResult!.user.isEmailVerified {
                FirebaseUserListener.shared.downloadCurrentUser(with: authDataResult!.user.uid) { (isSuccess) in
                    
                    completion(error, true)
                }

            } else {
                completion(error, false)
            }
        }
    }

    //MARK: - Register
    func registerUserWith(with email: String, password: String, type: UserType, completion: @escaping (_ error: Error?) -> Void ) {
        

        Auth.auth().createUser(withEmail: email, password: password, completion: { (authDataResult, error) in

            completion(error)

            if error == nil {
                
                authDataResult!.user.sendEmailVerification(completion: nil)
                
                //create user and save it
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, name: email, email: email, pushId: "", avatarLink: "", address: "", telephone: "", mobilePhone: "", isOnboardingCompleted: false, userType: type, isOnline: false, isAvailable: false, about: "")
                                        
                    FirebaseUserListener.shared.saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
            }
        })
    }
    
    //MARK: - Reset Password
    func resetPassword(for email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }

    //MARK: - Resend verification
    func resendVerificationEmail(to email: String, completion: @escaping (_ error: Error?) -> Void ) {

        Auth.auth().currentUser?.reload(completion: { (error) in

            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in

                completion(error)
            })
        })
    }


    //MARK: - LogOut
    func prepareForLogOut(completion: @escaping (_ redyToLogOut: Bool) -> Void) {
        
        guard var currentUser = User.currentUser else { return }
        
        currentUser.pushId = ""
        currentUser.isAvailable = false
        currentUser.isOnline = false
        
        FirebaseUserListener.shared.saveUserLocally(currentUser)
        FirebaseUserListener.shared.saveUserToFireStore(currentUser) { (didSave) in

            completion(didSave)
        }
    }
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {

        do {
            #if DEBUG
            print("<<<<Debug Log out")
            #endif
            try Auth.auth().signOut()

            userDefaults.removeObject(forKey: AppConstants.CurrentUser.rawValue)
            userDefaults.synchronize()
            completion(nil)

        } catch let error as NSError {
            completion(error)
        }
    }


    
}
