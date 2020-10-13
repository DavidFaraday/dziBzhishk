//
//  FirebaseHorseListener.swift
//  HorseDoctor
//
//  Created by David Kababyan on 03/10/2020.
//

import Foundation

class FirebaseHorseListener {
 
    static let shared = FirebaseHorseListener()

    private init() {}
    
    //MARK: - Fetching
    func downloadHorse(with horseId: String, completion: @escaping (_ horse: Horse) -> Void ) {

        FirebaseReference(.Horses).document(horseId).getDocument { (querySnapshot, error) in

            guard let document = querySnapshot else {
                #if DEBUG
                print("no document for Horse")
                #endif
                return
            }

            let result = Result {
                try? document.data(as: Horse.self)
            }

            switch result {
            case .success(let horseObject):
                
                completion(horseObject!)
                
            case .failure(let error):
                #if DEBUG
                print("<<<<Debug Error decoding Horse: \(error)")
                #endif
            }
        }
    }

    func downloadHorses(with iDs: [String], completion: @escaping (_ horses: [Horse]) -> Void ) {

        var count = 0
        var horseArray: [Horse] = []

        //go through each horse and download it from firestore
        for id in iDs {

            FirebaseReference(.Horses).document(id).getDocument { (querySnapshot, error) in

                guard let document = querySnapshot else {
                    #if DEBUG
                    print("no document for horse per id")
                    #endif
                    completion(horseArray)
                    return
                }

                let user = try? document.data(as: Horse.self)

                horseArray.append(user!)
                count += 1

                if count == iDs.count {
                    completion(horseArray)
                }
            }
        }
    }

    func downloadHorses(for stableId: String, completion: @escaping (_ horses: [Horse]) -> Void ) {
        
        FirebaseReference(.Horses).whereField(AppConstants.stableId.rawValue, isEqualTo: stableId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                #if DEBUG
                print("no document for all users")
                #endif
                return
            }

            var allHorses = documents.compactMap { (queryDocumentSnapshot) -> Horse? in
                return try? queryDocumentSnapshot.data(as: Horse.self)
            }
            
            allHorses.sort(by: { $0.name > $1.name })
            completion(allHorses)
        }
    }

    
    //MARK: - Saving
    func saveHorse(_ horse: Horse) {
        do {
            let _ = try FirebaseReference(.Horses).document(horse.id).setData(from: horse)
            #if DEBUG
            print("<<<<Debug Saved FB horse")
            #endif
        } catch {
            #if DEBUG
            print("<<<<Debug adding horse, ", error.localizedDescription)
            #endif
        }
    }
    
    /// Deletes Specific Hors Object from firebase
    ///
    /// - Parameters:
    ///   - recent: The `Horse` Horse Object.
    func deleteHorse(_ horse: Horse) {
        FirebaseReference(.Horses).document(horse.id).delete()
    }


}
