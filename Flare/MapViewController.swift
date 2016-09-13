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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSetUp()
        
        getFlaresFromDatabase() {
            (result: Array<Flare>) in
            self.plotFlares(result)
        }
        
        // TESTING FACEBOOK DETAILS
        
        let params = ["fields": "friends"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.startWithCompletionHandler { [weak self] connection, result, error in
            if error != nil {
                print(error.description)
                return
            }else{
//                let fbResult = result as! Dictionary<String, AnyObject>
                let json: JSON = JSON(result)
                print("*********JSON********")
                print(json)
                print(json["data"])
                print(json["data"].arrayValue)

                for item in json["data"].arrayValue {
                print(item["id"].stringValue)
                }
                }
            }

        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                let providerID = profile.providerID
                print("*********providerid")
                print(providerID)
                let uid = profile.uid;  // Provider-specific UID
                print("*********uid")
                print(uid)
            }
        } else {
            // No user is signed in.
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

