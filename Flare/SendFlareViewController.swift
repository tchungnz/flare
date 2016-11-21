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
            FIRAnalytics.logEvent(withName: "flare_sent", parameters: nil)
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
        if selectedFriendsIds == nil {
            selectedFriendsIds = ["N/A"]
        }
        let newFlare = ["facebookID": facebook.uid! as String, "title": self.flareTitle.text!, "subtitle": user!.displayName! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp, "isPublic": self.isPublicFlare as Bool, "recipients": self.selectedFriendsIds!] as [String : Any]
        let flareUniqueRef = flareRef.childByAutoId()
        flareUniqueRef.setValue(newFlare)
        if self.isPublicFlare == false {
            FIRAnalytics.logEvent(withName: "public_flare_sent", parameters: nil)
            self.saveNotificationsToDatabase(recipients: selectedFriendsIds!, flareRef: String(describing: flareUniqueRef))
        } else {
            FIRAnalytics.logEvent(withName: "friends_flare_sent", parameters: nil)
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
    
    func save30FlaresToDatabase() {
        var latitudeArray = ["51.57045215","51.49162991","51.49152096","51.53427636","51.55457128", "51.45587056", "51.44390983", "51.44103487", "51.54871447", "51.52127408", "51.49583983", "51.50164666", "51.47748164", "51.48603466", "51.47851309", "51.44287042", "51.57305906", "51.52755465", "51.50803373", "51.51882307", "51.53073643", "51.52119834", "51.47694273", "51.53406919", "51.46755552", "51.51026183", "51.44812337", "51.46969313", "51.49675351"]
        var longitudeArray = ["-0.08193588", "-0.10378149", "-0.12494991", "-0.19553319", "-0.10719456", "-0.14536961", "-0.15943138", "-0.154577", "-0.04652639", "-0.15164228", "-0.02440354", "-0.21588501", "-0.11671218", "-0.15777523", "-0.17120708", "-0.08856872", "-0.14952772", "-0.1230411", "-0.19113192", "-0.0800467", "-0.12103854", "-0.06918162", "-0.07115972", "-0.09289486", "-0.21747431", "-0.19022821", "-0.15235007", "-0.06310465", "-0.04259434"]
        let flareRef = ref.child(byAppendingPath: "scheduledFlares")
        let timestamp = FIRServerValue.timestamp()
        let user = FIRAuth.auth()?.currentUser
        // Put a guard on the email code below:
        
        var i = 0
        while i <= 29 {
            
            let flare1 = ["facebookID": "x", "title": "fake flare", "subtitle": "fake flare", "imageRef": "test image", "latitude": "x", "longitude": "y", "timestamp": timestamp, "isPublic": true as Bool] as [String : Any]
            let flare1Ref = flareRef.childByAutoId()
            flare1Ref.setValue(flare1)
            
            i += 1
            sleep(1)
        }
    }
    
}
