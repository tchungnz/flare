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
import FBSDKLoginKit
import CoreLocation
import SwiftyJSON

extension MapViewController {
    
    func getTimeHalfHourAgo() {
        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        let flareTimeLimitInMinutes = 30
        let flareTimeLimitInMiliseconds = Double(flareTimeLimitInMinutes * 60000)
        self.timeHalfHourAgo = (currentTimeInMilliseconds - flareTimeLimitInMiliseconds)
    }

    func getPublicFlaresFromDatabase(completion: (result: Array<Flare>) -> ()) {
        getTimeHalfHourAgo()
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("timestamp").queryStartingAtValue(timeHalfHourAgo).observeEventType(.Value, withBlock: { (snapshot) in
        var newItems = [Flare]()
        for item in snapshot.children {
            if (item.value!["isPublic"] as! Bool) {
                let flare = Flare(snapshot: item as! FIRDataSnapshot)
                newItems.insert(flare, atIndex: 0)
            }
        }
            completion(result: newItems)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFacebookID() {
        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                self.uid = profile.uid;  // Provider-specific UID
            }
        }
    }
    
    func getFriendsFlaresFromDatabase(friendsArray: Array<String>, completion: (result: Array<Flare>) -> ()) {
        getTimeHalfHourAgo()
        getFacebookID()
        print(self.uid)
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("timestamp").queryStartingAtValue(timeHalfHourAgo).observeEventType(.Value, withBlock: { (snapshot) in
            var newItems = [Flare]()
            for item in snapshot.children {
                if (friendsArray.contains(item.value!["facebookID"] as! String) || item.value!["facebookID"] as! String == self.uid!) {
                    let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                    newItems.insert(newFlare, atIndex: 0)
                }
            }
            completion(result: newItems)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func plotFlares(flares: Array<Flare>) {
        self.mapView.delegate = self
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.mapView.addAnnotations(flares)
    }

}