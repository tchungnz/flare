//
//  CityMapperAPI.swift
//  Flare
//
//  Created by Jess Astbury on 14/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    var distance : String?
    
    // MARK: Perform a GET Request
    func makeHTTPGetRequest(_ path: String, flareDetail: FlareDetailViewController, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: URL(string: path)! as URL)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, error as NSError?)
                if let time = json["travel_time_minutes"].int {
                    self.distance = "\(time) mins away"
                    flareDetail.setDistance(self.distance!)
                }
            } else {
                onCompletion(nil, error as NSError?)
            }
        })
        task.resume()
    }
    
}
