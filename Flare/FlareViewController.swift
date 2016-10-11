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
    var facebook = Facebook()
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getFbIDsFromDatabase() {
//            (result: Array<Flare>) in
//            print(result)
//        }
        
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
            displayAlertMessage("You can only have one active flare")
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
    
    @IBAction func togglePrivateAction(_ sender: UISwitch) {
        if togglePrivateButton.isOn {
            isPublicFlare = false
            togglePrivateLabel.text = "Friends"
        } else {
            isPublicFlare = true
            togglePrivateLabel.text = "Public"
        }
    }
    
    func displayAlertMessage(_ message: String)
    {
        let myAlert = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func toggleButtons() {
        self.retakePhotoButton.isHidden = !self.retakePhotoButton.isHidden ? true : false
        self.takePhotoButton.isHidden = !self.takePhotoButton.isHidden ? true : false
        self.sendFlareImageButton.isHidden = !self.sendFlareImageButton.isHidden ? true : false
        backToMapButton.isHidden = backToMapButton.isHidden ? false : true
        self.togglePrivateLabel.isHidden = !self.togglePrivateLabel.isHidden ? true : false
        self.togglePrivateButton.isHidden = !self.togglePrivateButton.isHidden ? true : false
    }
    
    func setButtons() {
        self.retakePhotoButton.isHidden = true
        self.sendFlareImageButton.isHidden = true
        self.flareTitle.delegate = self;
        self.flareTitle.isHidden = true
        self.togglePrivateLabel.isHidden = true
        self.togglePrivateButton.isHidden = true
    }
}
