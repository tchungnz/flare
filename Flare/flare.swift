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

class Flare: NSObject, MKAnnotation {

    var latitude: Double?
    var longitude: Double?
    var imageRef: String?
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(snapshot: FIRDataSnapshot) {
        self.title = snapshot.value!["title"] as! String
        self.subtitle = snapshot.value!["subtitle"] as! String
        self.imageRef = snapshot.value!["imageRef"] as! String
        self.latitude = Double(snapshot.value!["latitude"] as! String)
        self.longitude = Double(snapshot.value!["longitude"] as! String)
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude! as
        CLLocationDegrees, longitude: self.longitude! as CLLocationDegrees)
    }
    
}