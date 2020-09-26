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
    let horseId: String
    let stableId: String
    let stableName: String
    let title: String
    let type: String
    let description: String
    var mediaLink: String
    var isResponded: Bool
    var respondingDoctorId: String
    var respondingDoctorName: String
    var respondedDate: Date
    @ServerTimestamp var date = Date()
}
