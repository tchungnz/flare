//
//  FlareDetailViewController.swift
//  Flare
//
//  Created by Tim Chung on 10/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import FirebaseDatabase

//typealias ServiceResponse = (JSON, NSError?) -> Void

class FlareDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var flareTitleLabel: UILabel!
    @IBOutlet weak var flareSubtitleLabel: UILabel!
    @IBOutlet weak var flareImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var flareTimeRemainingCountdown: UILabel!
    @IBOutlet weak var DistanceToFlare: UILabel!
    
    var flareExport: Flare?
    var databaseRef: FIRDatabaseReference!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width:1080, height: 1920)
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        // MARK: How to get image out of storage
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        let islandRef = storageRef.child("\(flareExport!.imageRef!)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.dataWithMaxSize(1 * 1920 * 1080) { (data, error) -> Void in
                if (error != nil) {
                    print("Error!")
                } else {
                    let islandImage: UIImage! = UIImage(data: data!)
                    self.flareImage.image = islandImage
                    }
                }
        
                flareTitleLabel.text = flareExport!.title!
                flareSubtitleLabel.text = flareExport!.subtitle!
        

        // Displaying the time left on a flare:
        print("**************Time************")
        print(flareExport!.timestamp!)
        var currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        var flarePostedTime = Double(flareExport!.timestamp!)
        var flareTimeRemaining = currentTimeInMilliseconds - flarePostedTime
        var flareTimeRemainingInMinutes = 60 - Int(flareTimeRemaining / 60 / 1000)
        flareTimeRemainingCountdown.text = String(flareTimeRemainingInMinutes)
    }


    @IBAction func CityMapperNavigation(sender: AnyObject) {
        if let url = NSURL(string: "https://citymapper.com/directions?endcoord=\(flareExport!.latitude!)%2C\(flareExport!.longitude!)") {
            UIApplication.sharedApplication().openURL(url)
            print(url)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let userLatitude = Double(location!.coordinate.latitude)
        let userLongitude = Double(location!.coordinate.longitude)
        self.locationManager.stopUpdatingLocation()
        cityMapperCall(userLatitude, longitude: userLongitude)
    }
    
    func cityMapperCall(latitude: Double, longitude: Double) {
        let path = "https://developer.citymapper.com/api/1/traveltime/?startcoord=\(latitude)%2C\(longitude)&endcoord=\(flareExport!.latitude!)%2C\(flareExport!.longitude!)&time_type=arrival&key=af0adea677e7825d1e38a0a435f12365"
        let citymap = RestApiManager()
        citymap.makeHTTPGetRequest(path, onCompletion: { _, _ in })
        DistanceToFlare.text = citymap.distance
        print("Tectonpgae**************")
        print(citymap.distance)
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }

}
