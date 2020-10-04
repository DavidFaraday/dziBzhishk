//
//  EmergencyAlert.swift
//  HorseDoctor
//
//  Created by David Kababyan on 23/09/2020.
//

import Foundation
import FirebaseFirestoreSwift

struct EmergencyAlert: Codable {
    
    let id: String
    var horseId: String
    var horseChipId: String
    var stableId: String
    var stableName: String
    var title: String
    var type: String
    var description: String
    var mediaLink: String
    var isResponded: Bool
    var respondingDoctorId: String
    var respondingDoctorName: String
    var respondedDate: Date
    @ServerTimestamp var date = Date()
}
