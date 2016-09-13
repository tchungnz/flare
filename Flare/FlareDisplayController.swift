//
//  FlareDisplayController.swift
//  Flare
//
//  Created by Jess Astbury on 12/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import Firebase
import MapKit
import CoreLocation

extension MapViewController {
    
    func getTimeOneHourAgo() {
        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        self.timeOneHourAgo = (currentTimeInMilliseconds - 3600000)
    }

    func getFlaresFromDatabase(completion: (result: Array<Flare>) -> ()) {
        getTimeOneHourAgo()
        if isPublicView == true {
            databaseRef = FIRDatabase.database().reference().child("flares")
            databaseRef.queryOrderedByChild("isPublic?").queryOrderedByValue("False").observeEventType(.Value, withBlock: { (snapshot) in
            
        var newItems = [Flare]()
        for item in snapshot.children {
            let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
            newItems.insert(newFlare, atIndex: 0)
        }
            completion(result: newItems)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    }

    func plotFlares(flares: Array<Flare>) {
        self.mapView.delegate = self
        self.mapView.addAnnotations(flares)
    }
    
    //func getFlaresBasedOnPublicStatus(completion: (result: Array<Flare>) -> ()) {
      //  databaseRef = FIRDatabase.database().reference().child("flares")
        //databaseRef.queryOrderedByChild("isPublic?").queryOrderedByValue("False").observeEventType(.Value, //withBlock: { (snapshot) in
            
            
            
            
           // )
    //}

}