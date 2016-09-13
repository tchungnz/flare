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
import FBSDKLoginKit
import SwiftyJSON

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profilePic: UIImageView!
    
    let locationManager = CLLocationManager()
    
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    var timeOneHourAgo : Double?
    var friendsArray : Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSetUp()
        
        getFacebookFriends()
        
        getFriendsFlaresFromDatabase() {
            (result: Array<Flare>) in
            self.plotFlares(result)
        }

//        getPublicFlaresFromDatabase() {
//            (result: Array<Flare>) in
//            self.plotFlares(result)
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

