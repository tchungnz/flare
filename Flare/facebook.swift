//
//  facebook.swift
//  Flare
//
//  Created by Thomas Williams on 14/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON
import Firebase
import FirebaseDatabase

class Facebook: NSObject{
    
    var uid : String?

    // Pass the parameter of the item of data you want from Facebook e.g. "id", "name"
    func getFacebookFriends(_ requestedData: String?, completion: @escaping (_ result: Array<String>) -> ())  {
        let params = ["fields": "friends"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest?.start { [weak self] connection, result, error in
            var tempArray = [String]()
            if error != nil {
                print(error.debugDescription)
                return
            } else {
                let json:JSON = JSON(result)
                for item in json["friends"]["data"].arrayValue {
                    tempArray.insert(item[requestedData!].stringValue, at: 0)
                }
            }
            completion(tempArray)
        }
    }
    
    func getFacebookFriendsIdName(completion: @escaping (_ result: NSDictionary) -> ())  {
        let params = ["fields": "friends"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest?.start { [weak self] connection, result, error in
            var tempDictionary = Dictionary<String, String>()
            if error != nil {
                print(error.debugDescription)
                return
            } else {
                let json:JSON = JSON(result)
                for item in json["friends"]["data"].arrayValue {
                    tempDictionary[item["id"].stringValue] = item["name"].stringValue
                }
            }
            let nsDict = tempDictionary as! NSDictionary
            completion(nsDict)
        }
    }
    
    func getFacebookID() {
        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                self.uid = profile.uid
            }
        }
    }
}
