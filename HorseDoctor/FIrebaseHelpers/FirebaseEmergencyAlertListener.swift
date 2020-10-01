//
//  FirebaseEmergencyAlertListener.swift
//  HorseDoctor
//
//  Created by David Kababyan on 23/09/2020.
//

import Foundation
import Firebase

class FirebaseEmergencyAlertListener {
    
    static let shared = FirebaseEmergencyAlertListener()
    
    private init() {}

    /// Starts listening for emergency from FIrebase that belong to current user, returns array of emergency
    ///
    /// - Parameters:
    ///   - callback: All up to date recents of current user.
    func listenForEmergencyAlerts(for userType: UserType, completion: @escaping (_ allRecents: [EmergencyAlert]) -> Void) {

        let query = userType == .Stable ? FirebaseReference(.Emergency).whereField(AppConstants.stableId.rawValue, isEqualTo: User.currentId) : FirebaseReference(.Emergency)
        
        query.addSnapshotListener() { (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("no document for recent chats")
                return
            }

            var allEmergencies = documents.compactMap { (queryDocumentSnapshot) -> EmergencyAlert? in

                return try? queryDocumentSnapshot.data(as: EmergencyAlert.self)
            }


            allEmergencies.sort(by: { $0.date! > $1.date! })
            completion(allEmergencies)
        }
    }

    
    //MARK: - Add Update Delete
    /// Saves Specific Emergency Object to firebase
    ///
    /// - Parameters:
    ///   - emergency: The `EmergencyAlert`  Object.
    func save(emergency: EmergencyAlert) {

        do {
            let _ = try FirebaseReference(.Emergency).document(emergency.id).setData(from: emergency)
        }
        catch {
            print(error.localizedDescription, "saving emergency....")
        }
    }

    /// Updates specific EmergencyObject with given responded Value
    /// - Parameters:
    ///   - emergency: The `emergency` emergency to update.
    ///   - isResponded: The `isResponded` value.

    private func update(_ emergency: EmergencyAlert, isResponded: Bool) {

        var emergency = emergency

        emergency.isResponded = isResponded
        emergency.respondedDate = Date()

        self.save(emergency: emergency)
    }


    /// Deletes Specific Emergency Object from firebase
    ///
    /// - Parameters:
    ///   - emergency: The `Emergency`  Object.
    func delete(emergency: EmergencyAlert) {
        FirebaseReference(.Emergency).document(emergency.id).delete()
    }
}
