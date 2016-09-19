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

class FlareViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let maximumSentFlares: Int = 10

    var captureSession : AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var flareLatitude : String?
    var flareLongitude : String?
    
    var uid : String?
    var timeHalfHourAgo : Double?
    

    var backCamera: Bool = true
    var isPublicFlare: Bool = true
    var letFlareSave: Bool = true
    
    var toggleState: Bool?
    var flashOn: Bool?
    let storage = FIRStorage.storage()
    var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var sendFlareButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var retakePhotoButton: UIButton!
    @IBOutlet weak var sendFlareImageButton: UIImageView!
    @IBOutlet weak var backToMapButton: UIButton!
    @IBOutlet weak var flareTitle: UITextField!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var togglePrivateButton: UISwitch!
    @IBOutlet weak var togglePrivateLabel: UILabel!
    @IBOutlet weak var cameraSwivelButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFbIDsFromDatabase() {
            (result: Array<Flare>) in
            print(result)
        }
        
        setButtons()
        // Refactor to a separate class
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        cameraSession("back")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
      
    var didTakePhoto = Bool()

    func didPressTakeAnother() {
        self.flashBtn.hidden = false
        self.flareTitle.hidden = true
        self.cameraSwivelButton.hidden = false
        
        if didTakePhoto == false {
            tempImageView.hidden = true
            didTakePhoto = false
        } else {
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
    }
    
    @IBAction func retakeAction(sender: UIButton) {
        toggleButtons()
        didPressTakeAnother()
        
    }
    @IBAction func takePhotoAction(sender: UIButton) {
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
            displayAlertMessage("You can only have one active flare")
            return;
        }
    }
    
    
    @IBAction func changeCameraIconAction(sender: AnyObject) {
        var flashBtn = sender as! UIButton
        if toggleState == true {
            toggleState = false
            flashBtn.setImage(UIImage(named:"flash.png"),forState:UIControlState.Normal)
            flashOn = false
        } else {
            toggleState = true
            flashBtn.setImage(UIImage(named:"flash-off.png"),forState:UIControlState.Normal)
            flashOn = true
        }
    }
    
    
    @IBAction func toggleCamerSwitchAction(sender: UIButton) {
        if backCamera == true {
            switchCameraViewFront()
            flashBtn.hidden = true
        } else {
            switchCameraViewBack()
            flashBtn.hidden = false
        }
    }
    
    @IBAction func togglePrivateAction(sender: UISwitch) {
        if togglePrivateButton.on {
            isPublicFlare = false
            togglePrivateLabel.text = "Friends"
        } else {
            isPublicFlare = true
            togglePrivateLabel.text = "Public"
        }
    }
    
    func displayAlertMessage(message: String)
    {
        let myAlert = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func toggleButtons() {
        self.retakePhotoButton.hidden = !self.retakePhotoButton.hidden ? true : false
        self.takePhotoButton.hidden = !self.takePhotoButton.hidden ? true : false
        self.sendFlareImageButton.hidden = !self.sendFlareImageButton.hidden ? true : false
        backToMapButton.hidden = backToMapButton.hidden ? false : true
        self.togglePrivateLabel.hidden = !self.togglePrivateLabel.hidden ? true : false
        self.togglePrivateButton.hidden = !self.togglePrivateButton.hidden ? true : false
    }
    
    func setButtons() {
        self.retakePhotoButton.hidden = true
        self.sendFlareImageButton.hidden = true
        self.flareTitle.delegate = self;
        self.flareTitle.hidden = true
        self.togglePrivateLabel.hidden = true
        self.togglePrivateButton.hidden = true
    }
}
