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
//    let title: String?
//    let subtitle: String?
//    let coordinate: CLLocationCoordinate2D
    var latitude: Double?
    var longitude: Double?
    
//    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
//        super.init()
//        self.title = snapshot.title
//        self.title = title
//        self.subtitle = subtitle
//        self.coordinate = coordinate
//    }
    
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