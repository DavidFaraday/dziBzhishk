//
//  IncomingMessage.swift
//  HorseDoctor
//
//  Created by David Kababyan on 21/09/2020.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messagesCollectionView: MessagesViewController
    
    
    init(collectionView_: MessagesViewController) {
        messagesCollectionView = collectionView_
    }
    
    
    //MARK: CreateMessage
    func createMessage(localMessage: LocalMessage) -> MKMessage? {

        let mkMessage = MKMessage(message: localMessage)

        if localMessage.type == AppConstants.picture.rawValue {

            let photoItem = PhotoMessage(path: localMessage.pictureUrl)

            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)

            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl, isMessage: true) { (image) in
                mkMessage.photoItem?.image = image
                self.messagesCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == AppConstants.video.rawValue {
    
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl, isMessage: true) { (image) in

                FileStorage.downloadVideo(videoUrl: localMessage.videoUrl) { (readyToPlay, fileName) in
                    
                    let videoURL = URL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
                    
                    let videoItem = VideoMessage(url: videoURL)

                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }

                mkMessage.videoItem?.image = image
                self.messagesCollectionView.messagesCollectionView.reloadData()
            }
        }

        if localMessage.type == AppConstants.location.rawValue {
            
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        if localMessage.type == AppConstants.audio.rawValue {

            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))

            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)

            FileStorage.downloadAudio(audioUrl: localMessage.audioUrl) { (fileName) in

                let audioURL = URL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))

                mkMessage.audioItem?.url = audioURL

            }
        }

        return mkMessage
    }

}
