//
//  SwipeViewController.swift
//  Flare
//
//  Created by Jess Astbury on 10/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation

extension FlareViewController: CLLocationManagerDelegate {
    
    func onSwipe() {
        let imageString = NSUUID().UUIDString
        if self.flareTitle.text != "" {
            saveFlareToDatabase(imageString)
            uploadImage(imageString)
        } else {
            self.displayAlertMessage("Please enter a title")
            return
        }
    }
    
    func uploadImage(imageString: String) {
        var data = NSData()
        data = UIImageJPEGRepresentation(self.tempImageView.image!, 0.8)!
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        let imageRef = storageRef.child("images/flare\(imageString).jpg")
        let uploadTask = imageRef.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                puts("Error")
            } else {
                let downloadURL = metadata!.downloadURL
            }
        }
    }
    
    func getFacebookID() {
        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                self.uid = profile.uid;
            }
        }
    }
        
    func saveFlareToDatabase(imageString: String) {
        self.getFacebookID()
        let flareRef = ref.childByAppendingPath("flares")
        let timestamp = FIRServerValue.timestamp()
        let user = FIRAuth.auth()?.currentUser
        let flare1 = ["facebookID": self.uid! as String, "title": self.flareTitle.text!, "subtitle": user!.displayName! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp, "isPublic": self.isPublicFlare as Bool]
        let flare1Ref = flareRef.childByAutoId()
        flare1Ref.setValue(flare1)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
    }
    
    
    func getFbIDsFromDatabase(completion: (result: Array<Flare>) -> ()) {
        getTimeHalfHourAgo()
        var usersFlares = [Flare]()
        var facebookID = getFacebookID()
        var databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("facebookID").queryEqualToValue(self.uid).observeEventType(.Value, withBlock: { (snapshot) in
            
            for item in snapshot.children {
                    let flare = Flare(snapshot: item as! FIRDataSnapshot)
                        if Double(flare.timestamp!) >= self.timeHalfHourAgo! {
                            usersFlares.insert(flare, atIndex: 0)
                        }
                if usersFlares.count > self.maximumSentFlares {
                    self.letFlareSave = false
                } else {
                    self.letFlareSave = true
                    }
                }
            completion(result: usersFlares)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func getTimeHalfHourAgo() {
        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        self.timeHalfHourAgo = (currentTimeInMilliseconds - 1800000)
    }
    
}