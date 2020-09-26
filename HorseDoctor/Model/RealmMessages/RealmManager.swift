//
//  RealmManager.swift
//  HorseDoctor
//
//  Created by David Kababyan on 21/09/2020.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()

    private init() {}

    func saveToRealm<T: Object>(_ object: T) {

        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            print("Error saving realm object \(error.localizedDescription)")
        }
    }

    func deleteFromRealm<T: Object>(_ object: T) {

        do {
            try realm.write {
                print("delete real,")
                realm.delete(object)
            }
        } catch {
            print("Error deleting real object \(error.localizedDescription)")
        }
    }

}
