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

class Facebook: NSObject{

    // Pass the parameter of the item of data you want from Faceook e.g. "id", "name"
    func getFacebookFriends(requestedData: String?, completion: (result: Array<String>) -> ())  {
        let params = ["fields": "friends"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.startWithCompletionHandler { [weak self] connection, result, error in
            var tempArray = [String]()
            if error != nil {
                print(error.description)
                return
            } else {
                let json:JSON = JSON(result)
                for item in json["friends"]["data"].arrayValue {
                    tempArray.insert(item[requestedData!].stringValue, atIndex: 0)
                }
            }
            completion(result: tempArray)
        }
    }
}