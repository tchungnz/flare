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

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var flareLatitude : String?
    var flareLongitude : String?
    
    @IBOutlet weak var cameraView: UIView!
    
    let locationManager = CLLocationManager()
    
//    @IBOutlet weak var Camera: UIButton!
//    @IBOutlet weak var ImageDisplay: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CameraViewController.swipeUp(_:)))
        recognizer.direction = .Up
        self.view .addGestureRecognizer(recognizer)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        self.flareTitle.delegate = self;

        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        var input = AVCaptureDeviceInput()
        do {
         input = try AVCaptureDeviceInput(device: backCamera)
        } catch {
            error
        }
        
        if error == nil && (captureSession?.canAddInput(input))! {
            
            captureSession?.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if ((captureSession?.canAddOutput(stillImageOutput)) != nil) {
                
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
                
            }
        }
    }
    

    
//    @IBAction func CameraAction(sender: UIButton) {
//        
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        
//        
//        picker.sourceType = .Camera
//        
//        presentViewController(picker, animated: true, completion: nil)
//        
//    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        ImageDisplay.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismissViewControllerAnimated(true, completion: nil)
//    }
    @IBOutlet weak var tempImageView: UIImageView!
    func didPressTakePhoto() {
        
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    self.tempImageView.image = image
                    self.tempImageView.hidden = false
                }
            })
        }
    }
    
    var didTakePhoto = Bool()
    
    func didPressTakeAnother() {
        
        if didTakePhoto == true {
            
            tempImageView.hidden = true
            didTakePhoto = false
            
        } else {
            
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
        
    }
    
    @IBAction func retakeAction(sender: UIButton) {
        didPressTakeAnother()
    }
    @IBAction func takePhotoAction(sender: UIButton) {
        didPressTakePhoto()
    }
    
    @IBOutlet weak var flareTitle: UITextField!
    
    
    func swipeUp(recognizer : UISwipeGestureRecognizer) {
        
        // MARK: Upload image to storage
        var data = NSData()
        data = UIImageJPEGRepresentation(self.tempImageView.image!, 0.8)!
        
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        
        let imageRef = storageRef.child("images/flare\(NSUUID().UUIDString).jpg")
        
        let uploadTask = imageRef.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                puts("Error")
            }
            else {
                let downloadURL = metadata!.downloadURL
            }
        }
        
        // MARK: Save flare data to database
        
        var ref = FIRDatabase.database().reference()
        let flareRef = ref.childByAppendingPath("flares")
        let timestamp = FIRServerValue.timestamp()
        let user = FIRAuth.auth()?.currentUser
        print(user!.email)
        let flare1 = ["title": self.flareTitle.text!, "subtitle": "test@test.com", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp]
        let flare1Ref = flareRef.childByAutoId()
        flare1Ref.setValue(flare1)

        self.performSegueWithIdentifier("returnMap", sender: self)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
        
    }
    
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//    }
}
