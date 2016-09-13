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

    var captureSession : AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var flareLatitude : String?
    var flareLongitude : String?
    
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

    
    let locationManager = CLLocationManager()
    
    func toggleButtons() {
        self.retakePhotoButton.hidden = !self.retakePhotoButton.hidden ? true : false
        self.takePhotoButton.hidden = !self.takePhotoButton.hidden ? true : false
        self.sendFlareImageButton.hidden = !self.sendFlareImageButton.hidden ? true : false
        backToMapButton.hidden = backToMapButton.hidden ? false : true
    }
    
    func setButtons() {
        self.retakePhotoButton.hidden = true
        self.takePhotoButton.hidden = false
        self.sendFlareImageButton.hidden = true
        backToMapButton.hidden = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtons()
        self.flareTitle.delegate = self;

        // Refactor to a separate class
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        captureSession = AVCaptureSession()
        output = AVCaptureStillImageOutput()
        //captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = getDevice(.Back)
        
        //var input = AVCaptureDeviceInput()
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error as NSError {
            print(error)
            input = nil
            error
        }
        
        // var error : NSError?
        
        if(captureSession?.canAddInput(input) == true){
            captureSession?.addInput(input)
            //output?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if(captureSession?.canAddOutput(stillImageOutput) == true){
                captureSession?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewLayer?.frame = cameraView.bounds
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
      
    var didTakePhoto = Bool()

    func didPressTakeAnother() {
        
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
        toggleButtons()
        toggleFlash()
        sleep(1)
        didPressTakePhoto()
        toggleFlash()
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
    
    @IBAction func switchCameraView(sender: AnyObject) {
        captureSession = AVCaptureSession()
        output = AVCaptureStillImageOutput()
        // captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let frontCamera = getDevice(.Front)
        
        //var input = AVCaptureDeviceInput()
        do {
            input = try AVCaptureDeviceInput(device: frontCamera)
        } catch let error as NSError {
            print(error)
            input = nil
            error
        }
        // var error : NSError?
        
        if(captureSession?.canAddInput(input) == true){
            captureSession?.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if(captureSession?.canAddOutput(stillImageOutput) == true){
                captureSession?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewLayer?.frame = cameraView.bounds
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }
        
    }
    
    @IBAction func switchCameraViewBack(sender: AnyObject) {
        captureSession = AVCaptureSession()
        output = AVCaptureStillImageOutput()
        // captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = getDevice(.Back)
        
        //var input = AVCaptureDeviceInput()
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error as NSError {
            print(error)
            input = nil
            error
        }
        // var error : NSError?
        
        if(captureSession?.canAddInput(input) == true){
            captureSession?.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if(captureSession?.canAddOutput(stillImageOutput) == true){
                captureSession?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewLayer?.frame = cameraView.bounds
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }
        
    }
    }
