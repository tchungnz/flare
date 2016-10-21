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
        let imageString = UUID().uuidString
        if self.flareTitle.text != "" {
            saveFlareToDatabase(imageString)
            uploadImage(imageString)
        } else {
            self.displayAlertMessage("Please enter a title")
            return
        }
    }
    
    func uploadImage(_ imageString: String) {
        var data = Data()
        data = UIImageJPEGRepresentation(self.tempImageView.image!, 0.8)! as Data
        let storageRef = storage.reference(forURL: "gs://flare-1ef4b.appspot.com")
        let imageRef = storageRef.child("images/flare\(imageString).jpg")
        let uploadTask = imageRef.put(data as Data, metadata: nil) { metadata, error in
            if (error != nil) {
                puts("Error")
            } else {
                let downloadURL = metadata!.downloadURL
            }
        }
    }
    
    func saveFlareToDatabase(_ imageString: String) {
        facebook.getFacebookID()
        let flareRef = ref.child(byAppendingPath: "flares")
        let timestamp = FIRServerValue.timestamp()
        let user = FIRAuth.auth()?.currentUser
        let newFlare = ["facebookID": facebook.uid! as String, "title": self.flareTitle.text!, "subtitle": user!.displayName! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp, "isPublic": self.isPublicFlare as Bool] as [String : Any]
        let flareUniqueRef = flareRef.childByAutoId()
        flareUniqueRef.setValue(newFlare)
        if self.isPublicFlare == false {
         self.saveNotifications(flareRef: String(describing: flareUniqueRef))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
    }
    

    func activeFlareCheck() {
        getTimeHalfHourAgo()
        var usersFlares = [Flare]()
        facebook.getFacebookID()
        let databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrdered(byChild: "facebookID").queryEqual(toValue: facebook.uid).observe(.value, with: { (snapshot) in
            
            for item in snapshot.children {
                let flare = Flare(snapshot: item as! FIRDataSnapshot)
                if Double(flare.timestamp!) >= self.timeHalfHourAgo! {
                    usersFlares.insert(flare, at: 0)
                }
                if usersFlares.count >= self.maximumSentFlares {
                    self.letFlareSave = false
                } else {
                    self.letFlareSave = true
                }
            }
        })
    }
    
    func getTimeHalfHourAgo() {
        let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000
        self.timeHalfHourAgo = (currentTimeInMilliseconds - 1800000)
    }
    
    func saveNotifications(flareRef: String) {
        let facebook = Facebook()
        facebook.getFacebookFriends("id") {
            (result: [String]) in
            self.saveNotificationsToDatabase(friendsArray: result, flareRef: flareRef)
        }
    }
    
    func saveNotificationsToDatabase(friendsArray: [String], flareRef: String) {
        let notificationsRef = ref.child(byAppendingPath: "notifications").childByAutoId()
        let newNotification = ["friendsFacebookIds": friendsArray as Array, "flareId": flareRef as String] as [String : Any]
        notificationsRef.setValue(newNotification)
    }
    
}
