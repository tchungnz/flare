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
    @IBOutlet weak var reportFlare: UIButton!
    
    let navBar = UINavigationBar()
    var flareExport: Flare?
    var databaseRef: FIRDatabaseReference!
    var exitMapView: MKCoordinateRegion?
    var ref = FIRDatabase.database().reference()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        setupTapToSendFlareGesture()
        setupLocationManager()
        setupScrollView()
        setupLabels()
        populateFlares()
        FIRAnalytics.logEvent(withName: "flare_detail_view", parameters: nil)
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
        view.isUserInteractionEnabled = true
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
        let storageRef = storage.reference(forURL: "gs://flare-1ef4b.appspot.com")
        let islandRef = storageRef.child("\(flareExport!.imageRef!)")
        islandRef.data(withMaxSize: 1 * 1920 * 1080) { (data, error) -> Void in
            if (error != nil) {
                print("Error!")
            } else {
                let islandImage: UIImage! = UIImage(data: data!)
                self.flareImage.image = islandImage
            }
        }
    }
    
    func findFlareRemainingTime() {
        let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000
        let flarePostedTime = Double(flareExport!.timestamp!)
        let flareTimeRemaining = currentTimeInMilliseconds - flarePostedTime
        let flareTimeRemainingInMinutes = 120 - Int(flareTimeRemaining / 60 / 1000)
        if flareTimeRemainingInMinutes < 0 {
            flareTimeRemainingCountdown.text = "0"
        } else if flareTimeRemainingInMinutes > 120 {
            flareTimeRemainingCountdown.text = "120"
        } else {
            flareTimeRemainingCountdown.text = String(flareTimeRemainingInMinutes)
        }
    }
    
    func sendReportToDatabase(focus: String) {
        let reportRef = self.ref.child(byAppendingPath: "reports")
        let user = FIRAuth.auth()?.currentUser
        let report = ["reporter": user!.email! as String, "flareID": (self.flareExport?.flareId!)! as String, "focus": focus as String ] as [String : Any]
        let reportUniqueRef = reportRef.childByAutoId()
        reportUniqueRef.setValue(report)
        FIRAnalytics.logEvent(withName: "flare_reported", parameters: nil)
    }
    
    
    @IBAction func reportFlareAction(_ sender: AnyObject) {
        var reportActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let reportFlareButtonAction = UIAlertAction(title: "Report Innapropriate Flare", style: UIAlertActionStyle.default) { (ACTION) in
            self.sendReportToDatabase(focus: "flare")
        }
        let reportUserButtonAction = UIAlertAction(title: "Report Innapropriate User", style: UIAlertActionStyle.default) { (ACTION) in
            self.sendReportToDatabase(focus: "user")
        }
        let cancelReportButtonAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (ACTION) in
        }
        
        reportActionSheet.addAction(reportFlareButtonAction)
        reportActionSheet.addAction(reportUserButtonAction)
        reportActionSheet.addAction(cancelReportButtonAction)
        
        present(reportActionSheet, animated: true, completion: nil)
    }

    @IBAction func CityMapperNavigation(_ sender: AnyObject) {
        if let url = URL(string: "https://citymapper.com/directions?endcoord=\(flareExport!.latitude!)%2C\(flareExport!.longitude!)") {
            UIApplication.shared.openURL(url as URL)
            FIRAnalytics.logEvent(withName: "directions_selected", parameters: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func toggle(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "flare_detail_bar_toggle", parameters: nil)
        if flareDetailBar.isHidden == true {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.flareDetailBar.alpha = 1
                self.cityMapperButton.alpha = 1
                self.backButton.alpha = 1
                self.distanceToFlare.alpha = 1
                }, completion: { finished in
                    self.flareDetailBar.isHidden = false
                    self.cityMapperButton.isHidden = false
                    self.backButton.isHidden = false
                    self.distanceToFlare.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.flareDetailBar.alpha = 0
                self.cityMapperButton.alpha = 0
                self.backButton.alpha = 0
                self.distanceToFlare.alpha = 0
                }, completion: { finished in
                    self.flareDetailBar.isHidden = true
                    self.backButton.isHidden = true
                    self.cityMapperButton.isHidden = true
                    self.distanceToFlare.isHidden = true
            })
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
        return navigationController?.isNavigationBarHidden == true
        }
    }
    
//    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
//        return UIStatusBarAnimation.slide
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let userLatitude = Double(location!.coordinate.latitude)
        let userLongitude = Double(location!.coordinate.longitude)
        self.locationManager.stopUpdatingLocation()
        cityMapperCall(userLatitude, longitude: userLongitude)
    }
    
    func cityMapperCall(_ latitude: Double, longitude: Double) {
        let path = "https://developer.citymapper.com/api/1/traveltime/?startcoord=\(latitude)%2C\(longitude)&endcoord=\(flareExport!.latitude!)%2C\(flareExport!.longitude!)&time_type=arrival&key=6984b374d454cc120949773ebf04442c"
        let citymap = RestApiManager()
        citymap.makeHTTPGetRequest(path, flareDetail: self, onCompletion: { _, _ in })
    }
    
    func setDistance(_ distance: String) {
        DispatchQueue.main.async {
            self.distanceToFlare.text = distance
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToMap" {
            if let ivc = segue.destination as? MapViewController {
                ivc.exitMapView = self.exitMapView
            }
        }
    }


}
