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
    
    let locationManager = CLLocationManager()
    
    var flareArray = [Flare]()
    var databaseRef: FIRDatabaseReference!
    var flareExport: Flare?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
             
        // MARK: Retrieve flare from database
        
        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        print("**************CURRENTIME**************")
        print(currentTimeInMilliseconds)
        var timeOneHourAgo = (currentTimeInMilliseconds - 3600000)
        print("**************TIMEONEMINAGO**************")
        print(timeOneHourAgo)
        
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("timestamp").queryStartingAtValue(timeOneHourAgo).observeEventType(.Value, withBlock: { (snapshot) in
    
            
            var newItems = [Flare]()
            for item in snapshot.children {
                let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                newItems.insert(newFlare, atIndex: 0)
            }
            
            self.flareArray = newItems
            self.mapView.delegate = self
            self.mapView.addAnnotations(self.flareArray)
            
        })
        { (error) in
                print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    @IBAction func logOutAction(sender: UIButton) {
        let user = FIRAuth.auth()?.currentUser
        try! FIRAuth.auth()?.signOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let RootViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("rootView")
        self.presentViewController(RootViewController, animated: true, completion: nil)
//        self.performSegueWithIdentifier("rootViewSeque", sender: self)
    }
    
}

