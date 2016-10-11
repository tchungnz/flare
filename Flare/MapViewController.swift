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
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetUp()
        getPublic()
        FIRMessaging.messaging().subscribe(toTopic: "/topics/flares")
        waitBeforeDatabaseQuery()
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
            (result: [String]) in
            self.getFriendsFlaresFromDatabase(result) {
                (result: [Flare]) in
                self.plotFlares(result)
            }
        }
    }
    
    func getPublic() {
        getPublicFlaresFromDatabase() {
            (result: [Flare]) in
            self.plotFlares(result)
        }
    }
    
    func waitBeforeDatabaseQuery() {
        let seconds = 3.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.saveFCMTokenToDatabase()
        })
    }
    
    
    func saveFCMTokenToDatabase() {
        facebook.getFacebookID()
        let token = FIRInstanceID.instanceID().token()
        let tokenRef = ref.child(byAppendingPath: "tokens")
        let facebookTokenIDs = ["tokenId": token! as String] as [String : Any]
        let tokenRef1 = tokenRef.child(facebook.uid!)
        tokenRef1.setValue(facebookTokenIDs)
    }
    
}


