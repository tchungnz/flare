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
    @IBOutlet weak var sendFlareButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var retakePhotoButton: UIButton!
    @IBOutlet weak var sendFlareImageButton: UIImageView!
    
    let locationManager = CLLocationManager()
    
//    @IBOutlet weak var Camera: UIButton!
//    @IBOutlet weak var ImageDisplay: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.retakePhotoButton.hidden = true
        self.takePhotoButton.hidden = false
        self.sendFlareImageButton.hidden = true
//        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CameraViewController.swipeUp(_:)))
//        recognizer.direction = .Up
//        self.view .addGestureRecognizer(recognizer)
        
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
        self.takePhotoButton.hidden = false
        self.sendFlareImageButton.hidden = true
        self.retakePhotoButton.hidden = true
        didPressTakeAnother()
        
    }
    @IBAction func takePhotoAction(sender: UIButton) {
        self.takePhotoButton.hidden = true
        self.sendFlareImageButton.hidden = false
        self.retakePhotoButton.hidden = false
        didPressTakePhoto()
    }
    
    
    @IBOutlet weak var flareTitle: UITextField!
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + 0,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        if recognizer.state == UIGestureRecognizerState.Ended {
            // 1
            let velocity = recognizer.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (0),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5
            UIView.animateWithDuration(Double(slideFactor * 2),
                                       delay: 0,
            // 6
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {recognizer.view!.center = finalPoint },
                completion: nil)
        }
            // Need to work out completions callbacks to remove the timer below.
            let seconds = 0.8
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                // MARK: Upload image to storage
                var data = NSData()
                data = UIImageJPEGRepresentation(self.tempImageView.image!, 0.8)!
                
                let storage = FIRStorage.storage()
                let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
                
                let imageString = NSUUID().UUIDString
                let imageRef = storageRef.child("images/flare\(imageString).jpg")
                
                let uploadTask = imageRef.putData(data, metadata: nil) { metadata, error in
                    if (error != nil) {
                        puts("Error")
                    }
                    else {
                        let downloadURL = metadata!.downloadURL
                    }
                }
                
                
                // MARK: How to get image out of storage
//
//                let islandRef = storageRef.child("images/flare\(imageString).jpg")
//                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//                islandRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
//                    if (error != nil) {
//                        print("Error!")
//                    } else {
//                        let islandImage: UIImage! = UIImage(data: data!)
//                    }
//                }
                
                // MARK: Save flare data to database
                
                
                var ref = FIRDatabase.database().reference()
                let flareRef = ref.childByAppendingPath("flares")
                let timestamp = FIRServerValue.timestamp()
                let user = FIRAuth.auth()?.currentUser
                print(user!.email)
                // Put a guard on the email code below:
                let flare1 = ["title": self.flareTitle.text!, "subtitle": user!.email! as String, "imageRef": "images/flare\(imageString).jpg", "latitude": self.flareLatitude! as String, "longitude": self.flareLongitude! as String, "timestamp": timestamp]
                let flare1Ref = flareRef.childByAutoId()
                flare1Ref.setValue(flare1)
                
                self.performSegueWithIdentifier("returnMap", sender: self)
            })
        }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.flareLatitude = String(location!.coordinate.latitude)
        self.flareLongitude = String(location!.coordinate.longitude)
        
    }
    
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//    }
    
    // Old Apple Camera
    
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

}
