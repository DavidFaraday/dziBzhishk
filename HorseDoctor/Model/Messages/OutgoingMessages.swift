//
//  OutgoingMessages.swift
//  HorseDoctor
//
//  Created by David Kababyan on 21/09/2020.
//

import Foundation
import UIKit
import Gallery
import FirebaseFirestoreSwift

class OutgoingMessage {
    
    //MARK: - Send Message
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {

        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.name

        message.date = Date()
        message.senderInitials = String(currentUser.name.first!)
        message.status = AppConstants.sent.rawValue


        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }

        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        
        PushNotificationService.shared.sendPushNotificationTo(userIds: removerCurrentUserFrom(userIds: memberIds), body: message.message, chatRoomId: chatId)
        FirebaseRecentListener.shared.updateRecents(with: chatId, with: message.message)
    }


    class func sendMessage(message: LocalMessage, memberIds: [String]) {

        RealmManager.shared.saveToRealm(message)

        for memberId in memberIds {
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
}


func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {

    message.message = text
    message.type = AppConstants.text.rawValue

    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
}


func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String]) {

    message.message = "Picture message"
    message.type = AppConstants.picture.rawValue

    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_" + fileName + ".jpg"

    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)

    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageURL) in

        if imageURL != nil {
            message.pictureUrl = imageURL ?? ""

            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
        }
    }
}


func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String]) {

    message.message = "Video message"
    message.type = AppConstants.video.rawValue

    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_" + fileName + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_" + fileName + ".mov"


    let editor = VideoEditor()
    editor.process(video: video) { (processedVideo, videoURL) in

        if let tempPath = videoURL {

            let thumbnail = videoThumbnail(video: tempPath)
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)

            //upload thumbnail and video
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory, isThumbnail: true) { (imageLink) in

                if imageLink != nil {

                    let videoData = NSData(contentsOfFile: tempPath.path)

                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")

                    FileStorage.uploadVideo(video: videoData!, directory: videoDirectory) { (videoLink) in

                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""


                        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
                    }
                }
            } //End of Uploads


        } else {
            print("path is nil")
        }
    }
}


func sendLocationMessage(message: LocalMessage, memberIds: [String]) {

    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.type = AppConstants.location.rawValue
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0


    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
}


func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float = 0.0, memberIds: [String]) {

    message.message = "Audio message"
    message.type = AppConstants.audio.rawValue

    let fileDirectory = "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_" + audioFileName + ".m4a"

    FileStorage.uploadAudio(audioFileName: audioFileName, directory: fileDirectory) { (audioUrl) in

        if audioUrl != nil {
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)

            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
        }
    }

}
