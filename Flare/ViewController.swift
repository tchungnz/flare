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
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var flareArray = [Flare]()
    var databaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        
        // MARK: Create a flare
//        var ref = FIRDatabase.database().reference()
//        let flareRef = ref.childByAppendingPath("flares")
//        let timestamp = FIRServerValue.timestamp()
//        let flare1 = ["title": "Party at Tim' House", "subtitle": "@Tim", "coordinate": "latitude: 51.518691, longitude: -0.079007", "timestamp": timestamp]
//        let flare1Ref = flareRef.childByAutoId()
//        flare1Ref.setValue(flare1)
        
        // MARK: Retrieve flare from database
        
        
        databaseRef = FIRDatabase.database().reference().child("flares")
        
        databaseRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            var newItems = [Flare]()
            
            for item in snapshot.children {
                
                let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                newItems.insert(newFlare, atIndex: 0)
                print("********************")
                print(newItems)
            }
            
            self.flareArray = newItems
            
            })
        { (error) in
                print(error.localizedDescription)
        }
            print("*********FLAREARRAY***************")
            print(self.flareArray)
        
        
     
        // MARK: Plots flare on map
        
        
        
        
        
        
        mapView.delegate = self
//        let flares = [Flare(title: "Party at Jess' house", subtitle: "@jess", coordinate: CLLocationCoordinate2D(latitude: 51.518691, longitude: -0.079007)), Flare(title: "Party at Tim's house", subtitle: "@tim", coordinate: CLLocationCoordinate2D(latitude: 51.5255, longitude: -0.0882))]
//        mapView.addAnnotations(flares)
        
        
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
    
}

