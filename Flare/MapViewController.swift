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
    @IBOutlet weak var centreLocationButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    var timeHalfHourAgo : Double?
    var uid : String?
    var facebook = Facebook()
    var exitMapView: MKCoordinateRegion?
    var ref = FIRDatabase.database().reference()
    var notificationFlareId: String?
    var location: CLLocation?
    var flareId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetUp()
        publicOrFriendsOnLoad()
        waitBeforeDatabaseQuery()
    }
    
    func publicOrFriendsOnLoad() {
        if notificationFlareId == nil {
            getPublic()
        } else {
            getFriends()
            self.toggleMapButton.setOn(true, animated: true)
            self.toggleMapLabel.text = "Friends"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func toggleMapButton(_ sender: UISwitch) {
        FIRAnalytics.logEvent(withName: "toggle_map_public_friends", parameters: nil)
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
        let delay = seconds * Double(NSEC_PER_SEC)
        let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.saveFCMTokenToDatabase()
        })
    }
    
    func saveFCMTokenToDatabase() {
        facebook.getFacebookID()
        if let token = FIRInstanceID.instanceID().token() {
        let tokenRef = ref.child(byAppendingPath: "tokens")
        let facebookTokenIDs = ["tokenId": token]
        let tokenRef1 = tokenRef.child(facebook.uid!)
        tokenRef1.setValue(facebookTokenIDs)
        }
    }
    
    @IBAction func pressCentreLocationButton(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "centre_location", parameters: nil)
        self.notificationFlareId = nil
        self.exitMapView = nil
        mapSetUp()
    }
}


