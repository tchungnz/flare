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
    
    func onSwipe() -> Bool {
        let imageString = UUID().uuidString
        if self.flareTitle.text != "" {
            saveFlareToDatabase(imageString)
            uploadImage(imageString)
            FIRAnalytics.logEvent(withName: "flare_sent", parameters: nil)
            return true
        } else {
            self.displayAlertMessage("Please enter a title")
            return false
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
        if selectedFriendsIds == nil {
            selectedFriendsIds = ["N/A"]
        }
        let newFlare = ["facebookID": facebook.uid! as String, "title": self.flareTitle.text!, "subtitle": user!.displayName! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp, "isPublic": self.isPublicFlare as Bool, "recipients": self.selectedFriendsIds!] as [String : Any]
        let flareUniqueRef = flareRef.childByAutoId()
        flareUniqueRef.setValue(newFlare)
        if self.isPublicFlare == false {
            FIRAnalytics.logEvent(withName: "friends_flare_sent", parameters: nil)
            self.saveNotificationsToDatabase(recipients: selectedFriendsIds!, flareRef: String(describing: flareUniqueRef))
        } else {
            FIRAnalytics.logEvent(withName: "public_flare_sent", parameters: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
    }
    


    
    func saveNotificationsToDatabase(recipients: [String], flareRef: String) {
        let notificationsRef = ref.child(byAppendingPath: "notifications").childByAutoId()
        let newNotification = ["friendsFacebookIds": recipients as Array, "flareId": flareRef as String] as [String : Any]
        notificationsRef.setValue(newNotification)
    }
    
}
