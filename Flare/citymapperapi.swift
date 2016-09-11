//
//  citymapperapi.swift
//  Flare
//
//  Created by Jess Astbury on 11/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
//    let baseURL = "http://api.randomuser.me/"
//    
//    func getRandomUser(onCompletion: (JSON) -> Void) {
//        let route = baseURL
//        makeHTTPGetRequest(route, onCompletion: { json, err in
//            onCompletion(json as JSON)
//        })
//    }
    
    // MARK: Perform a GET Request
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                print("****************")
                print(json)
                onCompletion(json, error)
            } else {
                print("****************")
                print()
                onCompletion(nil, error)
            }
        })
        task.resume()
}

}