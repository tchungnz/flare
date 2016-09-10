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

extension CameraViewController: CLLocationManagerDelegate {
    
    func onSwipe() {
        
        // MARK: Upload image to storage
        
        var data = NSData()
        data = UIImageJPEGRepresentation(self.tempImageView.image!, 0.8)!
        
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        
        let imageString = NSUUID().UUIDString
        let imageRef = storageRef.child("images/flare\(imageString).jpg")
        
        let uploadTask = imageRef.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                puts("Error")
            }
            else {
                let downloadURL = metadata!.downloadURL
            }
        }
        
        // MARK: Save flare data to database
        
        
        var ref = FIRDatabase.database().reference()
        let flareRef = ref.childByAppendingPath("flares")
        let timestamp = FIRServerValue.timestamp()
        let user = FIRAuth.auth()?.currentUser
        print(user!.email)
        // Put a guard on the email code below:
        let flare1 = ["title": self.flareTitle.text!, "subtitle": user!.email! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp]
        let flare1Ref = flareRef.childByAutoId()
        flare1Ref.setValue(flare1)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
    }
    
    
    // MARK: How to get image out of storage
    //
    //                let islandRef = storageRef.child("images/flare\(imageString).jpg")
    //                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    //                islandRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
    //                    if (error != nil) {
    //                        print("Error!")
    //                    } else {
    //                        let islandImage: UIImage! = UIImage(data: data!)
    //                    }
    //                }
    
}