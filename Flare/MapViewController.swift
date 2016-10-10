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
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDatabase
import CoreLocation
import FBSDKLoginKit
import SwiftyJSON

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var toggleMapButton: UISwitch!
    @IBOutlet weak var toggleMapLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    var timeHalfHourAgo : Double?
    var uid : String?
    var facebook = Facebook()
    var exitMapView: MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetUp()
        getPublic()
        FIRMessaging.messaging().subscribe(toTopic: "/topics/flares")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func toggleMapButton(_ sender: UISwitch) {
        if toggleMapButton.isOn {
            toggleMapLabel.text = "Friends"
            getFriends()
            
        } else {
            toggleMapLabel.text = "Public"
            getPublic()
        }
    }
    
    func getFriends() {
        facebook.getFacebookFriends("id") {
            (result: Array<String>) in
            self.getFriendsFlaresFromDatabase(result) {
                (result: Array<Flare>) in
                self.plotFlares(result)
            }
        }
    }
    
    func getPublic() {
        getPublicFlaresFromDatabase() {
            (result: Array<Flare>) in
            self.plotFlares(result)
        }
    }
    
}


