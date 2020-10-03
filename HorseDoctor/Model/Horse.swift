//
//  Horse.swift
//  HorseDoctor
//
//  Created by David Kababyan on 02/10/2020.
//

import Foundation

struct Horse: Codable {

    var id: String = ""
    var stableId: String = ""
    var name: String
    var chipId: String
    var avatarLink: String
    var dateOfBirth: Date
    var neutered: Bool
    var socialSecurityNumber: String
    var vaccineIds: [String]
    var notes: String
    var isMale: Bool
}
