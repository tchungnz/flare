//
//  CityMapperAPI.swift
//  Flare
//
//  Created by Jess Astbury on 13/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    var distance : String?
    
    // MARK: Perform a GET Request
    func makeHTTPGetRequest(path: String, flareDetail: FlareDetailViewController, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, error)
                if let time = json["travel_time_minutes"].int {
                    self.distance = "\(time) mins away"
                    flareDetail.setDistance(self.distance!)
                }
            } else {
                onCompletion(nil, error)
            }
        })
        task.resume()
    }
    
}
