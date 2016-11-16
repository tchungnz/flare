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
    
    var flareExport: Flare?
    var timeHalfHourAgo : Double?
    var uid : String?
    var facebook = Facebook()
    var exitMapView: MKCoordinateRegion?
    var ref = FIRDatabase.database().reference()
    var notificationFlareId: String?
    var location: CLLocation?
    var flareId: String?
    var friends: NSDictionary?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetUp()
        getFriends()
        getPublic()
        waitBeforeDatabaseQuery()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func didBecomeActive() {
        print("did become active")
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        getFriends()
        getPublic()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getFriends() {
        facebook.getFacebookFriends("id") {
            (result: [String]) in
            self.getFriendsFlaresFromDatabase(result) {
                (result: [Flare], friendsArray: [String]) in
                self.plotFlares(result)
            }
        }
    }
    
    func getPublic() {
        facebook.getFacebookFriends("id") {
            (result: [String]) in
            self.getPublicFlaresFromDatabase(result) {
                (result: [Flare], friendsArray: [String]) in
                self.plotFlares(result)
                self.createBoostArrayAndPlot(friendsArray: friendsArray)
            }
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
    
    
    @IBAction func cancelToMapViewController(segue:UIStoryboardSegue) {
    }
    
}


