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
                self.uid = profile.uid;  // Provider-specific UID
            }
        }
    }
        
    func saveFlareToDatabase(imageString: String) {
        self.getFacebookID()
        let flareRef = ref.childByAppendingPath("flares")
        let timestamp = FIRServerValue.timestamp()
        
        let user = FIRAuth.auth()?.currentUser
        // Put a guard on the email code below:
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
                if usersFlares.count > self.maximumSentFlares { // Change this in flareViewController
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

    // PLOTS 30 FLARES ON MAP - DELETE LATER
    
    func save30FlaresToDatabase() {
        var latitudeArray = ["51.57045215","51.49162991","51.49152096","51.53427636","51.55457128", "51.45587056", "51.44390983", "51.44103487", "51.54871447", "51.52127408", "51.49583983", "51.50164666", "51.47748164", "51.48603466", "51.47851309", "51.44287042", "51.57305906", "51.52755465", "51.50803373", "51.51882307", "51.53073643", "51.52119834", "51.47694273", "51.53406919", "51.46755552", "51.51026183", "51.44812337", "51.46969313", "51.49675351"]
        var longitudeArray = ["-0.08193588", "-0.10378149", "-0.12494991", "-0.19553319", "-0.10719456", "-0.14536961", "-0.15943138", "-0.154577", "-0.04652639", "-0.15164228", "-0.02440354", "-0.21588501", "-0.11671218", "-0.15777523", "-0.17120708", "-0.08856872", "-0.14952772", "-0.1230411", "-0.19113192", "-0.0800467", "-0.12103854", "-0.06918162", "-0.07115972", "-0.09289486", "-0.21747431", "-0.19022821", "-0.15235007", "-0.06310465", "-0.04259434"]
        self.getFacebookID()
        let flareRef = ref.childByAppendingPath("flares")
        let timestamp = FIRServerValue.timestamp()
        let user = FIRAuth.auth()?.currentUser
        // Put a guard on the email code below:
        
        var i = 0
        while i <= 29 {
            
            let flare1 = ["facebookID": self.uid! as String, "title": "test title", "subtitle": user!.displayName! as String, "imageRef": "test image", "latitude": latitudeArray[i] as String, "longitude": longitudeArray[i] as String, "timestamp": timestamp, "isPublic": true as Bool]
            let flare1Ref = flareRef.childByAutoId()
            flare1Ref.setValue(flare1)
            
            i += 1
            sleep(1)
        }
        
    }

    
    
    
}





