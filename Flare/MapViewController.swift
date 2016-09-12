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
import FBSDKCoreKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profilePic: UIImageView!
    
    let locationManager = CLLocationManager()
    
    var flareArray = [Flare]()
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    var timeOneHourAgo : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSetUp()
        
        getFlaresFromDatabase()
        
        
        
        // MARK: Retrieves flares from database
        
        
//        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
//        var timeOneHourAgo = (currentTimeInMilliseconds - 3600000)
//        
//        databaseRef = FIRDatabase.database().reference().child("flares")
//        databaseRef.queryOrderedByChild("timestamp").queryStartingAtValue(timeOneHourAgo).observeEventType(.Value, withBlock: { (snapshot) in
//    
//            
//            var newItems = [Flare]()
//            for item in snapshot.children {
//                let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
//                newItems.insert(newFlare, atIndex: 0)
//            }
//            
//            self.flareArray = newItems
//            self.mapView.delegate = self
//            self.mapView.addAnnotations(self.flareArray)
//            
//        })
//        { (error) in
//                print(error.localizedDescription)
//        }
//    }
    
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

