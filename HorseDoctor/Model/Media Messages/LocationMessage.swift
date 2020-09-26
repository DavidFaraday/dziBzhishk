//
//  LocationMessage.swift
//  HorseDoctor
//
//  Created by David Kababyan on 21/09/2020.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {

        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}
