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
import JSQMessagesViewController


class FlareDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var flareTitleLabel: UILabel!
    @IBOutlet weak var flareSubtitleLabel: UILabel!
    @IBOutlet weak var flareImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var flareTimeRemainingCountdown: UILabel!
    @IBOutlet weak var flareDetailBar: UIView!
    @IBOutlet weak var cityMapperButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var reportFlare: UIButton!
    @IBOutlet weak var boostCountLabel: UILabel!
    @IBOutlet weak var boostButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBAction func chatButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowChannel", sender: sender)
    }
    
    let navBar = UINavigationBar()
    var flareExport: Flare?
    var databaseRef: FIRDatabaseReference!
    var exitMapView: MKCoordinateRegion?
    var ref = FIRDatabase.database().reference()
    var boostCount: Int = 0
    var liked = false
    var flareTimeLimitInMinutes: Int?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        setupTapToSendFlareGesture()
        setupLocationManager()
        setupScrollView()
        setupLabels()
        populateFlares()
        findAndSetBoostCount()
        findAndSetTimestamp()
        findAndSetButtonImage()
        FIRAnalytics.logEvent(withName: "flare_detail_view", parameters: nil)
    }
    
    func retrieveTimeDurationFromFirebase(completion: @escaping (_ result: Int) -> ())  {
        let durationRef = self.ref.child(byAppendingPath: "flareConstants").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let duration = value?["duration"] as! Int
            completion(duration)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func findAndSetButtonImage() {
        findIfBoosted(flareId: (self.flareExport?.flareId!)!) {
            (result: Bool) in
                self.setLikeButtonImage(ifBoosted: result)
        }
    }
    
    
    func setLikeButtonImage(ifBoosted: Bool) {
        if ifBoosted == true {
            boostButton.setBackgroundImage(UIImage(named: "liked"), for: .normal)
            self.liked = true
        }
    }
    
    func findIfBoosted(flareId: String, completion: @escaping (_ result: Bool) -> ())  {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let flareRef = self.ref.child(byAppendingPath: "flares/\(flareId)/boosts").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let boosts = snapshot.value as? NSDictionary
            var ifBoosted = boosts?[uid!]
            var ifBoostedBool: Bool
            
            if ifBoosted == nil {
                ifBoostedBool = false
            } else {
                ifBoostedBool = ifBoosted! as! Bool
            }
     
            completion(ifBoostedBool)
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setupLabels() {
        flareTitleLabel.text = flareExport!.title!
        flareSubtitleLabel.text = flareExport!.subtitle!
    }
    
    func populateFlares() {
        retrieveFlareImage()
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
    
    func sendReportToDatabase(focus: String) {
        let reportRef = self.ref.child(byAppendingPath: "reports")
        let user = FIRAuth.auth()?.currentUser
        let report = ["reporter": user!.email! as String, "flareID": (self.flareExport?.flareId!)! as String, "focus": focus as String ] as [String : Any]
        let reportUniqueRef = reportRef.childByAutoId()
        reportUniqueRef.setValue(report)
        FIRAnalytics.logEvent(withName: "flare_reported", parameters: nil)
    }
    
    func blockUser() {
        let userRef = self.ref.child(byAppendingPath: "users/\((FIRAuth.auth()?.currentUser?.uid)!)/blockedUsers")
        let blockedUsers = [(self.flareExport?.facebookID)! as String : true as Bool] as [ String : Any ]
        userRef.updateChildValues(blockedUsers)
    }
    
    
    @IBAction func reportFlareAction(_ sender: AnyObject) {
        var reportActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let reportFlareButtonAction = UIAlertAction(title: "Report Innapropriate Flare", style: UIAlertActionStyle.default) { (ACTION) in
            self.sendReportToDatabase(focus: "flare")
        }
        let reportUserButtonAction = UIAlertAction(title: "Block User", style: UIAlertActionStyle.default) { (ACTION) in
            self.blockUser()
        }
        let cancelReportButtonAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (ACTION) in
        }
        
        reportActionSheet.addAction(reportFlareButtonAction)
        reportActionSheet.addAction(reportUserButtonAction)
        reportActionSheet.addAction(cancelReportButtonAction)
        
        present(reportActionSheet, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func toggle(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "flare_detail_bar_toggle", parameters: nil)
        if flareDetailBar.isHidden == true {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.flareDetailBar.alpha = 1
                self.chatButton.alpha = 1
                self.backButton.alpha = 1
                self.boostButton.alpha = 1
                }, completion: { finished in
                    self.flareDetailBar.isHidden = false
                    self.chatButton.isHidden = false
                    self.backButton.isHidden = false
                    self.boostButton.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.flareDetailBar.alpha = 0
                self.chatButton.alpha = 0
                self.backButton.alpha = 0
                self.boostButton.alpha = 0
                }, completion: { finished in
                    self.flareDetailBar.isHidden = true
                    self.backButton.isHidden = true
                    self.chatButton.isHidden = true
                    self.boostButton.isHidden = true
            })
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
        return navigationController?.isNavigationBarHidden == true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "ShowChannel") {
            let navController = segue.destination as! UINavigationController
            let detailController = navController.topViewController as! ChatViewController
            detailController.flareExport = self.flareExport
        }
    }

    
    
    @IBAction func cancelToFlareDetailViewController(segue:UIStoryboardSegue) {
    }


}
