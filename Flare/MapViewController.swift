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
    @IBOutlet weak var togglePublicLabel: UILabel!
    @IBOutlet weak var togglePublicView: UISwitch!
    
    let locationManager = CLLocationManager()
    
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    var timeOneHourAgo : Double?
    var isPublicView: Bool = false
    
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

    @IBAction func togglePublicViewAction(sender: UISwitch) {
        if togglePublicView.on {
            //Private view
            isPublicView = false
            togglePublicLabel.text = "Private"
        } else {
            //Public view
            isPublicView = true
            togglePublicLabel.text = "Public"
        }
    }
}

