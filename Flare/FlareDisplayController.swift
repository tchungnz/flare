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
    
    func getTimeOneHourAgo() {
        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        self.timeOneHourAgo = (currentTimeInMilliseconds - 3600000)
    }

    func getPublicFlaresFromDatabase(completion: (result: Array<Flare>) -> ()) {
        getTimeOneHourAgo()
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("timestamp").queryStartingAtValue(timeOneHourAgo).observeEventType(.Value, withBlock: { (snapshot) in
            
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
    
    
    func getFriendsFlaresFromDatabase(completion: (result: Array<Flare>) -> ()) {
        getTimeOneHourAgo()
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("timestamp").queryStartingAtValue(timeOneHourAgo).observeEventType(.Value, withBlock: { (snapshot) in
            
            var newItems = [Flare]()
            
            for item in snapshot.children {
                print("********friendsArray*****")
                print(self.friendsArray)
                if self.friendsArray!.contains(item.value!["facebookID"] as! String) {
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
    
    
    func getFacebookFriends() {
        let params = ["fields": "friends"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.startWithCompletionHandler { [weak self] connection, result, error in
        var tempArray = [String]()
        if error != nil {
            print(error.description)
            return
        } else {
            let json:JSON = JSON(result)
            for item in json["friends"]["data"].arrayValue {
                tempArray.insert(item["id"].stringValue, atIndex: 0)
            }
        }
            self!.friendsArray = tempArray
            print(self!.friendsArray)
    }
    }
    

    func plotFlares(flares: Array<Flare>) {
        self.mapView.delegate = self
        self.mapView.addAnnotations(flares)
    }

}