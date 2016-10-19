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
        setDefinedRegion()
    }
    
//    func defineRegion(flare: [Flare], completion: @escaping (_ result: MKCoordinateRegion) -> ()) {
//        var definedRegion: MKCoordinateRegion!
//        var definedCenter: CLLocationCoordinate2D?
//        if exitMapView != nil {
//            print("EXIT MAP VIEW IS NOT NIL")
//            definedRegion = exitMapView!
//        } else if notificationFlareId != nil {
//            print("NOTIFICATION ID IS NOT NIL")
//            print(notificationFlareId)
//            retrieveFlareAttributes(flareId: "-KUSgm-qUzCvBQDEA3Lz") {
//                (result: [Flare]) in
//                print("*******define region call back thingy********")
//                print(result[0].latitude)
//                print(result[0].longitude)
//                definedCenter = CLLocationCoordinate2D(latitude: result[0].latitude!, longitude: result[0].longitude!)
//                definedRegion = MKCoordinateRegion(center: definedCenter!, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
//            }
//        } else {
//            print("NORMAL OPEN")
//            definedCenter = CLLocationCoordinate2D(latitude: self.location!.coordinate.latitude, longitude: self.location!.coordinate.longitude)
//            definedRegion = MKCoordinateRegion(center: definedCenter!, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
//        }
//        completion(definedRegion)
//    }
    
    func setDefinedRegion() {
        if notificationFlareId != nil {
            retrieveFlareAttributes(flareId: notificationFlareId!) {
                (result: [Flare]) in
                var definedCenter = CLLocationCoordinate2D(latitude: result[0].longitude!, longitude: result[0].latitude!)
                var definedRegion = MKCoordinateRegion(center: definedCenter, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                self.setRegion(animated: true, region: definedRegion)
                self.toggleMapPublicFriends()
            }
        } else if exitMapView != nil {
            var definedRegion = exitMapView!
            setRegion(animated: false, region: definedRegion)
        } else {
            var definedCenter = CLLocationCoordinate2D(latitude: self.location!.coordinate.latitude, longitude: self.location!.coordinate.longitude)
            var definedRegion = MKCoordinateRegion(center: definedCenter, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
            self.setRegion(animated: true, region: definedRegion)
        }
    }
    
    func setRegion(animated: Bool, region: MKCoordinateRegion) {
        self.mapView.setRegion(region, animated: animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    
    func retrieveFlareAttributes(flareId: String, completion: @escaping (_ result: [Flare]) -> ())  {
        let newRef = ref.child("flares")
        newRef.queryOrderedByKey().queryEqual(toValue: flareId).observe(.value, with: { (snapshot) in
            var newFlares = [Flare]()
            for item in snapshot.children {
                let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                newFlares.insert(newFlare, at: 0)
                print("*******retrieveFlareAttributes********")
                print(newFlares[0].latitude)
                print(newFlares[0].longitude)
            }
            completion(newFlares)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
}
