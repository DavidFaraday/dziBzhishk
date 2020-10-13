//
//  GlobalFunctions.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import Foundation
import UIKit
import AVFoundation


let userDefaults = UserDefaults.standard

func updateUserPushId(newPushId: String) {
    
    if var user = User.currentUser {
        user.pushId = newPushId
        
        FirebaseUserListener.shared.saveUserLocally(user)
        FirebaseUserListener.shared.saveUserToFireStore(user)
    }

    userDefaults.setValue(newPushId, forKey: AppConstants.pushId.rawValue)
}

func setUser(isOnline online: Bool) {
    
    if var currentUser = User.currentUser {
        if currentUser.isOnboardingCompleted {
            currentUser.isOnline = online
            
            FirebaseUserListener.shared.saveUserLocally(currentUser)
            FirebaseUserListener.shared.saveUserToFireStore(currentUser)
        }
    }
}


func removerCurrentUserFrom(userIds: [String]) -> [String] {
    
    var allIds = userIds
    for id in allIds {
     
        if id == User.currentId {
            allIds.remove(at: allIds.firstIndex(of: id)!)
        }
    }
    return allIds
    
}

func fileNameFrom(fileUrl: String) -> String {

    return ((fileUrl.components(separatedBy: "_").last!).components(separatedBy: "?").first!).components(separatedBy: ".").first!
}


func videoThumbnail(video: URL) -> UIImage {
    
    let asset = AVURLAsset(url: video, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail
}


func timeElapsed(_ date: Date) -> String {

    let seconds = Date().timeIntervalSince(date)

    var elapsed = ""

    if (seconds < 60) {
        elapsed = "Just now"
    } else if (seconds < 60 * 60) {
        let minutes = Int(seconds / 60)

        var minText = "min"
        if minutes > 1 {
            minText = "mins"
        }
        elapsed = "\(minutes) \(minText)"

    } else if (seconds < 24 * 60 * 60) {

        let hours = Int(seconds / (60 * 60))
        var hourText = "hour"
        if hours > 1 {
            hourText = "hours"
        }

        elapsed = "\(hours) \(hourText)"

    } else {

        elapsed = date.dayMonthYear()
    }

    return elapsed
}
