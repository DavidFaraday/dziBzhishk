//
//  User.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    
    var id: String = ""
    var name: String
    var email: String
    var pushId: String
    var avatarLink: String
    var address: String
    var telephone: String
    var mobilePhone: String
    var isOnboardingCompleted: Bool
    var userType: UserType
    var isOnline: Bool
    var isAvailable: Bool?
    var about: String?

    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }

    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: AppConstants.CurrentUser.rawValue) {

                let decoder = JSONDecoder()
                do {
                    let object = try decoder.decode(User.self, from: dictionary)
                    return object
                } catch {
                    print("error decoding user from userDefaults. ", error.localizedDescription)
                }
            }
        }
        return nil
    }

    //for Equatable
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

}


func createDummyUsers() {

    let names = ["Alison Inayah", " Stamp Duggan", "Bate Alfie", "Anya Neale", "Gates Rachelle", "Juanita Thornton"]
    var ImageIndex = 1
    var UserIndex = 1

    for i in 0..<6 {

        let id = UUID().uuidString

        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        print("ImageIndex ", ImageIndex)
        FileStorage.uploadImage(UIImage(named: "user\(ImageIndex)")!, directory: fileDirectory) { (avatarLink) in

            
            let user = User(id: id, name: names[i], email: "owner\(UserIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "", address: "Address \(UserIndex)", telephone: "98765544", mobilePhone: "000999888", isOnboardingCompleted: false, userType: .Owner, isOnline: false, isAvailable: false, about: "")

            UserIndex += 1
            FirebaseUserListener.shared.saveUserToFireStore(user)
        }

        ImageIndex += 1
        if ImageIndex == 6 {
            ImageIndex = 1
        }
    }
}
