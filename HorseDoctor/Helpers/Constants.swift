//
//  Constants.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import Foundation

enum EmergencyType: String, CaseIterable {
    
    case Orthopaedic, Gynaecology, Colic, Other
}


enum LoginType {
    case Login
    case Registration
}

enum SegueType: String {
    case loginToFinishRegSeg
    case profileToEditProfileSeg
    case emergencyToAddEmergencySeg
    case emergencyToEmergencyDetailSeg
}

enum UserType: String, Codable {
    case Stable
    case Doctor
    case Owner
}



enum AppConstants: String {
    case CurrentUser
    case storageReference = "gs://horsedoctor-8bf8b.appspot.com"
    case senderId
    case chatRoomId
    case memberIds
    case date
    case readDate
    case text
    case location
    case picture
    case video
    case audio
    case sent
    case status
    case read
    case pushServerKey = "AAAAap3YPJw:APA91bHNsCgMqUaTGx6X1_EjLnDHSlK88QfN370MholOXfCr7hk7_jIXVqESAncn1RvYbo1OyaT8rTqFXYuMLzVScWfRYtxoE5PR2sY1Z7uLLUPnhQ_D21eaFSFQdYAojuHhTQm0BG8u"
    case userType
    case id
    case stableId
}

public let kNUMBEROFMESSAGES = 12
