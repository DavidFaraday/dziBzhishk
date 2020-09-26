//
//  MKMessage.swift
//  HorseDoctor
//
//  Created by David Kababyan on 21/09/2020.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mksender: MKSender
    var sender: SenderType { return mksender }
    var senderInitials: String

    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?
    
    var status: String
    var readDate: Date
    
    init(message: LocalMessage) {

        self.messageId = message.id

        self.mksender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)

        switch message.type {
        case AppConstants.text.rawValue:
            self.kind = MessageKind.text(message.message)

        case AppConstants.picture.rawValue:

            let photoItem = PhotoMessage(path: message.pictureUrl)

            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem

        case AppConstants.video.rawValue:
            let videoItem = VideoMessage(url: nil)

            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem

        case AppConstants.location.rawValue:
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem

        case AppConstants.audio.rawValue:
            let audioItem = AudioMessage(duration: 2)

            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem

        default:
            self.kind = MessageKind.text(message.message)
        }
        

        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mksender.senderId
    }
}
