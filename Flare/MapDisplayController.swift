//
//  MapDisplayController.swift
//  Flare
//
//  Created by Jess Astbury on 12/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Firebase

extension MapViewController {
    
    func mapSetUp() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        defineRegion() {
            (result: MKCoordinateRegion) in
            self.mapView.setRegion(result, animated: true)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func defineRegion(_ completion: @escaping (_ result: MKCoordinateRegion) -> ()) {
        var definedRegion: MKCoordinateRegion?
        var definedCenter: CLLocationCoordinate2D?
        if exitMapView != nil {
            print("EXIT MAP VIEW IS NOT NIL")
            definedRegion = exitMapView!
        } else if notificationFlareId != nil {
            print("NOTIFICATION ID IS NOT NIL")
            print(notificationFlareId)
            retrieveFlareAttributes(flareId: notificationFlareId!) {
                (result: Flare?) in
                print(result)
                definedCenter = CLLocationCoordinate2D(latitude: (result?.latitude!)!, longitude: (result?.longitude!)!)
                definedRegion = MKCoordinateRegion(center: definedCenter!, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            }
        } else {
            definedCenter = CLLocationCoordinate2D(latitude: (self.location?.coordinate.latitude)!, longitude: (self.location?.coordinate.longitude)!)
            definedRegion = MKCoordinateRegion(center: definedCenter!, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
            
        }
        completion(definedRegion!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    
    
    func retrieveFlareAttributes(flareId: String, completion: @escaping (_ result: Flare?) -> ())  {
        print("*******retrieveFlareAttributes********")
        let newRef = ref.child("flares")
        print("*******newRef********")
        newRef.queryOrderedByKey().queryEqual(toValue: flareId).observe(.value, with: { (snapshot) in
            var newFlare: Flare?
            for item in snapshot.children {
                print("******item in snapshot******")
                print(item)
                newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                print("******newFlare******")
                print(newFlare)
            }
            completion(newFlare)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
}
