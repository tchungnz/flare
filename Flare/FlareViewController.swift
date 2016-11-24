//
//  CameraViewController.swift
//  Flare
//
//  Created by Mali McCalla on 08/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation

class FlareViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    let maximumSentFlares = 5
    let flareTimeLimitInMinutes = 240
    var activeFlareTime : Double?

    var captureSession : AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var flareLatitude : String?
    var flareLongitude : String?
    
    var uid : String?
    
    var backCamera: Bool = true
    var isPublicFlare: Bool = true
    var letFlareSave: Bool = true
    
    var toggleState: Bool?
    var flashOn: Bool?
    let storage = FIRStorage.storage()
    var ref = FIRDatabase.database().reference()
    var facebook = Facebook()
    var selectedFriends: [String]?
    var selectedFriendsIds: [String]?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var sendFlareButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var retakePhotoButton: UIButton!
    @IBOutlet weak var sendFlareImageButton: UIImageView!
    @IBOutlet weak var backToMapButton: UIButton!
    @IBOutlet weak var flareTitle: UITextField!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var cameraSwivelButton: UIButton!
    @IBOutlet weak var sendToFriendsButton: UIButton!
    @IBOutlet weak var sendToEveryoneButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFlareTime()
        setButtons()
        // Refactor to a separate class
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        cameraSession("back")
        enableKeyboardDisappear()
        activeFlareCheck()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
      
    var didTakePhoto = Bool()

    func didPressTakeAnother() {
        self.flashBtn.isHidden = false
        self.flareTitle.isHidden = true
        self.cameraSwivelButton.isHidden = false
        
        if didTakePhoto == false {
            tempImageView.isHidden = true
            didTakePhoto = false
        } else {
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
    }
    
    @IBAction func retakeAction(_ sender: UIButton) {
        toggleButtons()
        didPressTakeAnother()
    }
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        if letFlareSave == true {
            toggleButtons()
            if flashOn == true {
                toggleFlash()
                sleep(1)
            }
            didPressTakePhoto()
            if flashOn == true {
                toggleFlash()
            }
        } else {
            displayAlertMessage("You can only have five active flares")
            return;
        }
    }
    
    
    @IBAction func changeCameraIconAction(_ sender: AnyObject) {
        let flashBtn = sender as! UIButton
        if toggleState == true {
            toggleState = false
            flashBtn.setImage(UIImage(named:"flash.png"),for:UIControlState())
            flashOn = false
        } else {
            toggleState = true
            flashBtn.setImage(UIImage(named:"flash-off.png"),for:UIControlState())
            flashOn = true
        }
    }
    
    
    @IBAction func toggleCamerSwitchAction(_ sender: UIButton) {
        if backCamera == true {
            switchCameraViewFront()
            flashBtn.isHidden = true
        } else {
            switchCameraViewBack()
            flashBtn.isHidden = false
        }
    }
    
    @IBAction func clickSendToFriendsButton(_ sender: AnyObject) {
        sendToFriendsButton.backgroundColor = UIColor.orange
        sendToEveryoneButton.backgroundColor = UIColor.lightGray
        isPublicFlare = false
    }
    
    @IBAction func clickSendToEveryoneButton(_ sender: AnyObject) {
        sendToEveryoneButton.backgroundColor = UIColor.red
        sendToFriendsButton.backgroundColor = UIColor.lightGray
        isPublicFlare = true
    }
    
    
    func displayAlertMessage(_ message: String)
    {
        let myAlert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func toggleButtons() {
        self.retakePhotoButton.isHidden = !self.retakePhotoButton.isHidden ? true : false
        self.takePhotoButton.isHidden = !self.takePhotoButton.isHidden ? true : false
        self.sendFlareImageButton.isHidden = !self.sendFlareImageButton.isHidden ? true : false
        backToMapButton.isHidden = backToMapButton.isHidden ? false : true
         self.sendToFriendsButton.isHidden = self.sendToFriendsButton.isHidden ? false : true
         self.sendToEveryoneButton.isHidden = self.sendToEveryoneButton.isHidden ? false : true
    }
    
    func setButtons() {
        self.retakePhotoButton.isHidden = true
        self.sendFlareImageButton.isHidden = true
        self.flareTitle.delegate = self;
        self.flareTitle.isHidden = true
        self.sendToFriendsButton.isHidden = true
        self.sendToEveryoneButton.isHidden = true
        self.sendToFriendsButton.layer.cornerRadius = 7.5;
        self.sendToEveryoneButton.layer.cornerRadius = 7.5;

    }
    
    func enableKeyboardDisappear() {
        self.flareTitle.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))
    }
    
    func dismissKeyboard() {
        flareTitle.resignFirstResponder()
    }
    
    @IBAction func cancelToFlareViewController(segue:UIStoryboardSegue) {
        
    }
    
    func getFlareTime() {
        let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000
        let flareTimeLimitInMiliseconds = Double(flareTimeLimitInMinutes * 60000)
        self.activeFlareTime = (currentTimeInMilliseconds - flareTimeLimitInMiliseconds)
    }
    
    
    func activeFlareCheck() {
        var usersFlares = [Flare]()
        facebook.getFacebookID()
        let databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrdered(byChild: "facebookID").queryEqual(toValue: facebook.uid).observe(.value, with: { (snapshot) in
            
            for item in snapshot.children {
                let flare = Flare(snapshot: item as! FIRDataSnapshot)
                if Double(flare.timestamp!) >= self.activeFlareTime! {
                    usersFlares.insert(flare, at: 0)
                }
                if usersFlares.count >= self.maximumSentFlares {
                    self.letFlareSave = false
                } else {
                    self.letFlareSave = true
                }
            }
        })
    }
    
}
