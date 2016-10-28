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
        findAndSetBoostCount()
        
    }
    
    
    func findAndSetBoostCount() {
        findBoostCount(flareId: (self.flareExport?.flareId!)!) {
            (result: String) in
            self.setBoostCount(boostCount: result)
        }
    }
    
    func setBoostCount(boostCount: String) {
        if boostCountLabel.text == "0 boosts" {
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


    func boostOrUnboostFlare() {
        
        let flareRef = self.ref.child(byAppendingPath: "flares/\((self.flareExport?.flareId!)!)")
        
        flareRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var flare = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                var boosts : Dictionary<String, Bool>
                boosts = flare["stars"] as? [String : Bool] ?? [:]
                var boostCount = flare["boostCount"] as? Int ?? 0
        
                if let _ = flare["boosts"]?[uid] {
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
}
