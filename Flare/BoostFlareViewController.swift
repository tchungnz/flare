//
//  BoostFlareViewController.swift
//  Flare
//
//  Created by Tim Chung on 28/10/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import FirebaseCore
import Firebase

extension FlareDetailViewController {
    
    @IBAction func clickBoostButton(_ sender: AnyObject) {
        boostOrUnboostFlare()
        updateTimestamp(flareId: (self.flareExport?.flareId!)!)
        findAndSetBoostCount()
        findAndSetTimestamp()
        
        if self.liked {
            boostButton.setBackgroundImage(UIImage(named: "unliked"), for: .normal)
            self.liked = false
        } else {
            boostButton.setBackgroundImage(UIImage(named: "liked"), for: .normal)
            self.liked = true
        }
    }
    
    
    func findAndSetBoostCount() {
        findBoostCount(flareId: (self.flareExport?.flareId!)!) {
            (result: String) in
            self.setBoostCount(boostCount: result)
        }
    }
    
    func setBoostCount(boostCount: String) {
        if boostCount == "1" {
            boostCountLabel.text = "\(boostCount) boost"
        } else {
            boostCountLabel.text = "\(boostCount) boosts"
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
    
    func findAndBoostTimestamp(flareId: String, completion: @escaping (_ result: Int) -> ()) {
        let minuteIncrease = 15
        let flareRef = self.ref.child(byAppendingPath: "flares/\(flareId)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let flare = snapshot.value as? NSDictionary
            var timestamp = flare?["timestamp"]! as! Int
            timestamp += (minuteIncrease * 60000)
            completion(timestamp)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func updateTimestamp(flareId: String) {
        let flareRef = self.ref.child(byAppendingPath: "flares/\((self.flareExport?.flareId!)!)")
        
        flareRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var flare = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var boosts : Dictionary<String, Bool>
                boosts = flare["boosts"] as? [String : Bool] ?? [:]
                var timestamp = flare["timestamp"] as? Int
                
                if let _ = boosts[uid] {
                    timestamp! -= 15*60000
                } else {
                    timestamp! += 15*60000
                }
                flare["timestamp"] = timestamp as AnyObject?
                
                // Set value and report transaction success
                currentData.value = flare
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

        
    }


    func boostOrUnboostFlare() {
        
        let flareRef = self.ref.child(byAppendingPath: "flares/\((self.flareExport?.flareId!)!)")
        
        flareRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var flare = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var boosts : Dictionary<String, Bool>
                boosts = flare["boosts"] as? [String : Bool] ?? [:]
                var boostCount = flare["boostCount"] as? Int ?? 0
        
                if let _ = boosts[uid] {
                    // Unstar the post and remove self from stars
                    boostCount -= 1
                    boosts.removeValue(forKey: uid)
                } else {
                    // Star the post and add self to stars
                    boostCount += 1
                    boosts[uid] = true
                }
                flare["boostCount"] = boostCount as AnyObject?
                flare["boosts"] = boosts as AnyObject?
                
                // Set value and report transaction success
                currentData.value = flare
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    

    func findMinutesRemaining(flareId: String, completion: @escaping (_ result: Int) -> ()) {
        let flareRef = self.ref.child(byAppendingPath: "flares/\(flareId)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let flare = snapshot.value as? NSDictionary
            let currentFlareTimestamp = flare?["timestamp"]! as! Int
            let currentTimeInMilliseconds = Int(Date().timeIntervalSince1970 * 1000)
            var minutesRemaining = abs(currentTimeInMilliseconds - currentFlareTimestamp) / 60000
            completion(minutesRemaining)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }

    func setTimestampLabel(minutesRemaining: Int) {
        flareTimeRemainingCountdown.text = "\(minutesRemaining) mins remaining"
    }
    
    
    func findAndSetTimestamp() {
        findMinutesRemaining(flareId: (self.flareExport?.flareId!)!) {
            (result: Int) in
            self.setTimestampLabel(minutesRemaining: result)
        }
    }
    
    
//    func findFlareRemainingTime() {
//        let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000
//        let flarePostedTime = Double(flareExport!.timestamp!)
//        let flareTimeRemaining = currentTimeInMilliseconds - flarePostedTime
//        let flareTimeRemainingInMinutes = 120 - Int(flareTimeRemaining / 60 / 1000)
//        if flareTimeRemainingInMinutes < 0 {
//            flareTimeRemainingCountdown.text = "0"
//        } else if flareTimeRemainingInMinutes > 120 {
//            flareTimeRemainingCountdown.text = "120"
//        } else {
//            flareTimeRemainingCountdown.text = String(flareTimeRemainingInMinutes)
//        }
//    }
//    
    
    
}
