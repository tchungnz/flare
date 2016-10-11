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
import Alamofire

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
        
        
        // make http request to firebase
        
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "Accept": "AIzaSyBcuFKYiXaoiZ-BQvJS8XWhjRfz-vNofQs"
//        ]
//      
//        let parameters: Parameters = [
//            "notifications": [
//                "title": "Notification Title",
//                "text": "The Text of the notification."
//            ],
//            "project_id": "flare-1ef4b",
//        "to":"cL_9lsV06v8:APA91bETyeotWHeBBB_mxLU0O0AImJ2YrOc8hueRtucFB7hyvJhJH9bRYtaKDmJASX9ICNyxMdIn39xo_KBRRnox6eywde1ZSiLweb_OjRqFBIIw-al6Atmm1PHzr2w0HF2hE0zsf-TB"
//        ]
//        
//        print(parameters)
//        let urlstring = "https://fcm.googleapis.com/fcm/send"
//        
//        Alamofire.request("https://fcm.googleapis.com/fcm/send", headers: headers, method:).responseJSON { response in
//            debugPrint(response)
//        }
//        
//        Alamofire.request("https://fcm.googleapis.com/fcm/send", headers: headers, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        
        
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


