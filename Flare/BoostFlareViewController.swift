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
        toggleLikeButtonImage()
        updateTimestamp()
        findAndSetBoostCount()
        findAndSetTimestamp()
    }
    
    func boostOrUnboostFlare() {
        let flareRef = self.ref.child(byAppendingPath: "flares/\((self.flareExport?.flareId!)!)")
        flareRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var flare = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var boosts : Dictionary<String, Bool>
                boosts = flare["boosts"] as? [String : Bool] ?? [:]
                var boostCount = flare["boostCount"] as? Int ?? 0
                
                if let _ = boosts[uid] {
                    boostCount -= 1
                    boosts.removeValue(forKey: uid)
                } else {
                    boostCount += 1
                    boosts[uid] = true
                }
                flare["boostCount"] = boostCount as AnyObject?
                flare["boosts"] = boosts as AnyObject?
                
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
    
    func toggleLikeButtonImage() {
        if self.liked {
            boostButton.setBackgroundImage(UIImage(named: "unliked"), for: .normal)
            self.liked = false
        } else {
            boostButton.setBackgroundImage(UIImage(named: "liked"), for: .normal)
            self.liked = true
        }
    }
    
    func updateTimestamp() {
        let flareRef = self.ref.child(byAppendingPath: "flares/\((self.flareExport?.flareId!)!)")
        flareRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var flare = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var boosts : Dictionary<String, Bool>
                boosts = flare["boosts"] as? [String : Bool] ?? [:]
                var timestamp = flare["timestamp"] as? Int
                if let _ = boosts[uid] {
                    timestamp! += 15*60000
                } else {
                    timestamp! -= 15*60000
                }
                flare["timestamp"] = timestamp as AnyObject?
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
    
    func findAndSetBoostCount() {
        findBoostCount(flareId: (self.flareExport?.flareId!)!) {
            (result: String) in
            self.setBoostCountLabel(boostCount: result)
        }
    }
    
    func setBoostCountLabel(boostCount: String) {
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
    
    func findAndSetTimestamp() {
        self.findMinutesRemaining(flareId: (self.flareExport?.flareId!)!) {
                (result: Int) in
                self.setTimestampLabel(minutesRemaining: result)
        }
    }
    
    func findMinutesRemaining(flareId: String, completion: @escaping (_ result: Int) -> ()) {
        let flareRef = self.ref.child(byAppendingPath: "flares/\(flareId)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let flare = snapshot.value as? NSDictionary
            let currentFlareTimestamp = flare?["timestamp"]! as! Int
            let currentTimeInMilliseconds = Int(Date().timeIntervalSince1970 * 1000)
            var minutesRemaining: Int
            if currentFlareTimestamp <= currentTimeInMilliseconds {
                minutesRemaining = self.flareTimeLimitInMinutes - (abs(currentTimeInMilliseconds - currentFlareTimestamp) / 60000)
            } else {
                minutesRemaining = self.flareTimeLimitInMinutes + (abs(currentFlareTimestamp - currentTimeInMilliseconds) / 60000)
            }
            if minutesRemaining < 0 {
                minutesRemaining = 0
            }
            completion(minutesRemaining)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setTimestampLabel(minutesRemaining: Int) {
        flareTimeRemainingCountdown.text = "\(minutesRemaining) mins remaining"
    }
    
}
