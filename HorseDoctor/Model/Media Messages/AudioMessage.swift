//
//  AudioMessage.swift
//  HorseDoctor
//
//  Created by David Kababyan on 21/09/2020.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {

    var url: URL
    var size: CGSize
    var duration: Float

    init(duration: Float) {

        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
}
