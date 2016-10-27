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
        
        if (self.mapView.userLocation is MKUserLocation) {
            let annotationView = MKAnnotationView(annotation: self.mapView.userLocation , reuseIdentifier: nil)
            annotationView.canShowCallout = false
        }
//
//        var annotationView = MKAnnotationView(annotation: self.mapView.userLocation, reuseIdentifier: "annotationIdentifier")
//        annotationView.canShowCallout = false
        
//        let annotationView = self.mapView.view(for: MKUserLocation() as! MKAnnotation)
//        annotationView?.canShowCallout = false
//        let userLocationView = MKAnnotationView(annotation: self.mapView.userLocation, reuseIdentifier: "AnnotationIdentifier")
//        userLocationView.canShowCallout = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        setDefinedRegion()
    }
    
    func setDefinedRegion() {
        if notificationFlareId != nil {
            retrieveFlareAttributes(flareId: notificationFlareId!) {
                (result: [Flare]) in
                let definedCenter = CLLocationCoordinate2D(latitude: result[0].latitude!, longitude: result[0].longitude!)
                let definedRegion = MKCoordinateRegion(center: definedCenter, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.setRegion(animated: true, region: definedRegion)
            }
        } else if exitMapView != nil {
            let definedRegion = exitMapView!
            setRegion(animated: false, region: definedRegion)
        } else {
            let definedCenter = CLLocationCoordinate2D(latitude: self.location!.coordinate.latitude, longitude: self.location!.coordinate.longitude)
            let definedRegion = MKCoordinateRegion(center: definedCenter, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
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
            }
            completion(newFlares)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
}
