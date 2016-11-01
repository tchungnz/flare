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
        let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000
        let flareTimeLimitInMinutes = 120
        let flareTimeLimitInMiliseconds = Double(flareTimeLimitInMinutes * 60000)
        self.timeHalfHourAgo = (currentTimeInMilliseconds - flareTimeLimitInMiliseconds)
    }

    func getPublicFlaresFromDatabase(_ friendsArray: [String], completion: @escaping (_ result: [Flare], _ friendsArray: [String]) -> ()) {
        getTimeHalfHourAgo()
        getFacebookID()
        let flareRef = ref.child("flares")
        flareRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: timeHalfHourAgo).observe(.value, with: { (snapshot) in
        var newItems = [Flare]()
        for item in snapshot.children {
            let data = (item as! FIRDataSnapshot).value! as! NSDictionary
            if (data["isPublic"] as! Bool) && !(friendsArray.contains(data["facebookID"] as! String) || data["facebookID"] as! String == self.uid!) {
                let flare = Flare(snapshot: item as! FIRDataSnapshot)
                flare.imageName = "publicPin"
                newItems.insert(flare, at: 0)
            }
        }
            completion(newItems, friendsArray)
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
    
    func getFriendsFlaresFromDatabase(_ friendsArray: [String], completion: @escaping (_ result: [Flare], _ friendsarray: [String]) -> ()) {
        getTimeHalfHourAgo()
        getFacebookID()
        let flareRef = ref.child("flares")
        flareRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: timeHalfHourAgo).observe(.value, with: { (snapshot) in
            var newItems = [Flare]()
            for item in snapshot.children {
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if (friendsArray.contains(data["facebookID"] as! String) || data["facebookID"] as! String == self.uid!) {
                    let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                    newFlare.imageName = "friendsPin"
                    newItems.insert(newFlare, at: 0)
                }
            }
            completion(newItems, friendsArray)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func findBoostCount(flareId: String, completion: @escaping (_ result: String) -> ())  {
        let flareRef = self.ref.child(byAppendingPath: "flares/\(flareId)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let flare = snapshot.value as? NSDictionary
            var count = flare?["boostCount"]
            var countString: String
            if count == nil {
                countString = "0"
            } else {
                countString = String(describing: count!)
            }
            completion(countString)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    

    func plotFlares(_ flares: [Flare]) {
        self.mapView.delegate = self
        let allAnnotations = self.mapView.annotations
        self.mapView.addAnnotations(flares)
    }

}
