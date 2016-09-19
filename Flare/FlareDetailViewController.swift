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
import FirebaseDatabase
import CoreLocation


class FlareDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var flareTitleLabel: UILabel!
    @IBOutlet weak var flareSubtitleLabel: UILabel!
    @IBOutlet weak var flareImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var flareTimeRemainingCountdown: UILabel!
    @IBOutlet weak var flareDetailBar: UIView!
    @IBOutlet weak var cityMapperButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var distanceToFlare: UILabel!
    
    let navBar = UINavigationBar()
    var flareExport: Flare?
    var databaseRef: FIRDatabaseReference!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        setupTapToSendFlareGesture()
        setupLocationManager()
        setupScrollView()
        setupLabels()
        populateFlares()
    }
    
    func setupLabels() {
        flareTitleLabel.text = flareExport!.title!
        flareSubtitleLabel.text = flareExport!.subtitle!
    }
    
    func populateFlares() {
        retrieveFlareImage()
        distanceToFlare.text = ""
        findFlareRemainingTime()
    }
    
    func setupScrollView() {
        self.scrollView.contentSize = CGSize(width:1080, height: 1920)
    }
    
    func setupTapToSendFlareGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(FlareDetailViewController.toggle(_:)))
        view.userInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func retrieveFlareImage() {
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        let islandRef = storageRef.child("\(flareExport!.imageRef!)")
        islandRef.dataWithMaxSize(1 * 1920 * 1080) { (data, error) -> Void in
            if (error != nil) {
                print("Error!")
            } else {
                let islandImage: UIImage! = UIImage(data: data!)
                self.flareImage.image = islandImage
            }
        }
    }
    
    func findFlareRemainingTime() {
        let currentTimeInMilliseconds = NSDate().timeIntervalSince1970 * 1000
        let flarePostedTime = Double(flareExport!.timestamp!)
        let flareTimeRemaining = currentTimeInMilliseconds - flarePostedTime
        let flareTimeRemainingInMinutes = 30 - Int(flareTimeRemaining / 60 / 1000)
        flareTimeRemainingCountdown.text = String(flareTimeRemainingInMinutes)
    }
    

    @IBAction func CityMapperNavigation(sender: AnyObject) {
        if let url = NSURL(string: "https://citymapper.com/directions?endcoord=\(flareExport!.latitude!)%2C\(flareExport!.longitude!)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func toggle(sender: AnyObject) {
        print("screen tapped")
        if flareDetailBar.hidden == true {
            UIView.animateWithDuration(0.2, delay: 0, options: [], animations: {
                self.flareDetailBar.alpha = 1
                self.cityMapperButton.alpha = 1
                self.backButton.alpha = 1
                self.distanceToFlare.alpha = 1
                }, completion: { finished in
                    self.flareDetailBar.hidden = false
                    self.cityMapperButton.hidden = false
                    self.backButton.hidden = false
                    self.distanceToFlare.hidden = false
            })
        } else {
            UIView.animateWithDuration(0.2, delay: 0, options: [], animations: {
                self.flareDetailBar.alpha = 0
                self.cityMapperButton.alpha = 0
                self.backButton.alpha = 0
                self.distanceToFlare.alpha = 0
                }, completion: { finished in
                    self.flareDetailBar.hidden = true
                    self.backButton.hidden = true
                    self.cityMapperButton.hidden = true
                    self.distanceToFlare.hidden = true
            })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let userLatitude = Double(location!.coordinate.latitude)
        let userLongitude = Double(location!.coordinate.longitude)
        self.locationManager.stopUpdatingLocation()
        cityMapperCall(userLatitude, longitude: userLongitude)
    }
    
    func cityMapperCall(latitude: Double, longitude: Double) {
        let path = "https://developer.citymapper.com/api/1/traveltime/?startcoord=\(latitude)%2C\(longitude)&endcoord=\(flareExport!.latitude!)%2C\(flareExport!.longitude!)&time_type=arrival&key=6984b374d454cc120949773ebf04442c"
        let citymap = RestApiManager()
        citymap.makeHTTPGetRequest(path, flareDetail: self, onCompletion: { _, _ in })
    }
    
    func setDistance(distance: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.distanceToFlare.text = distance
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }


}
