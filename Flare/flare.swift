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

class Flare: MKPointAnnotation {

    var latitude: Double?
    var longitude: Double?
    
    init(snapshot: FIRDataSnapshot) {
        super.init()
        self.title = snapshot.value!["title"] as! String
        self.subtitle = snapshot.value!["subtitle"] as! String
        self.latitude = Double(snapshot.value!["latitude"] as! String)
        self.longitude = Double(snapshot.value!["longitude"] as! String)
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude! as
        CLLocationDegrees, longitude: self.longitude! as CLLocationDegrees)
    }
    
}