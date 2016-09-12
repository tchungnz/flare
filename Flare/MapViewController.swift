//
//  ViewController.swift
//  Flare
//
//  Created by Georgia Mills on 06/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profilePic: UIImageView!
    
    let locationManager = CLLocationManager()
    
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    var timeOneHourAgo : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSetUp()
        
        getFlaresFromDatabase() {
            (result: Array<Flare>) in
            self.plotFlares(result)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

