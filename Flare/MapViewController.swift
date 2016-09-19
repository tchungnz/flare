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
    @IBOutlet weak var toggleMapButton: UISwitch!
    @IBOutlet weak var toggleMapLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    var timeHalfHourAgo : Double?
    var uid : String?
    var facebook = Facebook()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetUp()
        getPublic()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func toggleMapButton(sender: UISwitch) {
        if toggleMapButton.on {
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


