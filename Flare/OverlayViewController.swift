//
//  OverlayViewController.swift
//  Flare
//
//  Created by Tim Chung on 30/10/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import MapKit
import Firebase

extension MapViewController {
    
    func plotBoosts(_ boostOverlays: [MKCircle]) {
        self.mapView.delegate = self
        var overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        self.mapView.addOverlays(boostOverlays)
    }
    
    func createFriendsBoostArrayAndPlot(friendsArray: [String]) {
        getFriendsBoostCountsFromDatabase(friendsArray) {
            (result: [MKCircle]) in
            self.plotBoosts(result)
        }
    }
    

    func createPublicBoostArrayAndPlot(friendsArray: [String]) {
        getPublicBoostCountsFromDatabase(friendsArray) {
            (result: [MKCircle]) in
            self.plotBoosts(result)
        }
    }
    
    func getFriendsBoostCountsFromDatabase(_ friendsArray: [String], completion: @escaping (_ result: [MKCircle]) -> ()) {
        print("friends boostcounts running")
        getTimeHalfHourAgo()
        
        // Not efficient code, as firebase looks for any change to flares (both boostcount and boost attributes change so runs code 2x)
        
        let flareRef = self.ref.child("flares").queryOrdered(byChild: "timestamp").queryStarting(atValue: timeHalfHourAgo)
        flareRef.observe(.value, with: { (snapshot) in
            var boostOverlays = [MKCircle]()
            for item in snapshot.children {
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if (friendsArray.contains(data["facebookID"] as! String) || data["facebookID"] as! String == self.uid!) {
                let flare = (item as! FIRDataSnapshot).value! as! [String : AnyObject]
                let boostCount = flare["boostCount"] as? Int ?? 0
                let latitude = flare["latitude"] as! String
                let longitude = flare["longitude"] as! String
                if boostCount != 0 {
                    for index in 1...(boostCount) {
                        let radius: CLLocationDistance
                        radius = CLLocationDistance(index*75)
                        let newBoostOverlay = MKCircle(center: CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!), radius: radius)
                        boostOverlays.append(newBoostOverlay)
                    }
                }
            }
            }
            print("****number of circles to plot*****")
            print(boostOverlays.count)
            completion(boostOverlays)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getPublicBoostCountsFromDatabase(_ friendsArray: [String], completion: @escaping (_ result: [MKCircle]) -> ()) {
        print("public boostcounts running")
        getTimeHalfHourAgo()
        
        // Not efficient code, as firebase looks for any change to flares (both boostcount and boost attributes change so runs code 2x)
        
        let flareRef = self.ref.child("flares").queryOrdered(byChild: "timestamp").queryStarting(atValue: timeHalfHourAgo)
        flareRef.observe(.value, with: { (snapshot) in
            var boostOverlays = [MKCircle]()
            for item in snapshot.children {
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if (data["isPublic"] as! Bool) && !(friendsArray.contains(data["facebookID"] as! String) || data["facebookID"] as! String == self.uid!) {
                    let flare = (item as! FIRDataSnapshot).value! as! [String : AnyObject]
                    let boostCount = flare["boostCount"] as? Int ?? 0
                    let latitude = flare["latitude"] as! String
                    let longitude = flare["longitude"] as! String
                    if boostCount != 0 {
                        for index in 1...(boostCount) {
                            let radius: CLLocationDistance
                            radius = CLLocationDistance(index*75)
                            let newBoostOverlay = MKCircle(center: CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!), radius: radius)
                            boostOverlays.append(newBoostOverlay)
                        }
                    }
                }
            }
            print("****number of circles to plot*****")
            print(boostOverlays.count)
            completion(boostOverlays)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }

    
//    func createBoostOverlayArray(flares: [Flare], completion: @escaping (_ result: [MKCircle]) -> ()) {
//        var boostOverlays = [MKCircle]()
//        for item in flares {
//            if item.boostCount != nil && item.boostCount != 0 {
//                for index in 1...(item.boostCount!) {
//                    let radius: CLLocationDistance
//                    if item.boostCount != nil {
//                        radius = CLLocationDistance(index*75)
//                    } else {
//                        radius = CLLocationDistance(0)
//                    }
//                    let newBoostOverlay = MKCircle(center: item.coordinate, radius: radius)
//                    boostOverlays.append(newBoostOverlay)
//                }
//            }
//        }
//        completion(boostOverlays)
//    }
    
    @objc(mapView:viewForOverlay:) func mapView(_ mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self){
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.1)
            //            circleRenderer.strokeColor = UIColor.red
            //            circleRenderer.lineWidth = 0.5
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}
