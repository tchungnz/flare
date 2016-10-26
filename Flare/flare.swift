//
//  flare.swift
//  Flare
//
//  Created by Tim Chung on 07/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import MapKit
import FirebaseDatabase

class Flare: MKPointAnnotation{

    var facebookID: String?
    var latitude: Double?
    var longitude: Double?
    var imageRef: String?
    var timestamp: Int?
    var isPublic: Bool?
    var flareId: String?
    
    init(snapshot: FIRDataSnapshot) {
        super.init()
        let snapshotValue = snapshot.value as? NSDictionary
        self.facebookID = (snapshotValue?["facebookID"] as? String?)!
        self.title = (snapshotValue?["title"] as? String?)!
        self.subtitle = (snapshotValue?["subtitle"] as? String?)!
        self.imageRef = (snapshotValue?["imageRef"] as? String?)!
        self.latitude = Double((snapshotValue?["latitude"] as? String?)!!)
        self.longitude = Double((snapshotValue?["longitude"] as? String?)!!)
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude! as
        CLLocationDegrees, longitude: self.longitude! as CLLocationDegrees)
        self.timestamp = (snapshotValue?["timestamp"] as? Int?)!
        self.isPublic = (snapshotValue?["isPublic"] as? Bool?)!
        self.flareId = snapshot.key
    }
    
}
