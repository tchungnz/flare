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
        
    func saveFlareToDatabase(imageString: String) {
        let flareRef = ref.childByAppendingPath("flares")
        let timestamp = FIRServerValue.timestamp()
        
        let user = FIRAuth.auth()?.currentUser
        // Put a guard on the email code below:
        let flare1 = ["title": self.flareTitle.text!, "subtitle": user!.displayName! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp]
        let flare1Ref = flareRef.childByAutoId()
        flare1Ref.setValue(flare1)

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
    }
    
    func displayAlertMessage(message: String)
    {
        let myAlert = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
}