//
//  CameraViewController.swift
//  Flare
//
//  Created by Tim Chung on 12/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Firebase

extension FlareViewController {
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }  
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func switchCameraViewFront() {
        backCamera = false
        cameraSession("front")
    }
    
    func switchCameraViewBack() {
        backCamera = true
        cameraSession("back")
    }
    
    func cameraSession(_ direction: String!) {
        captureSession = AVCaptureSession()
        output = AVCaptureStillImageOutput()
        let frontCamera = direction == "back" ? getDevice(.back) : getDevice(.front)
        do {
            input = try AVCaptureDeviceInput(device: frontCamera)
        } catch let error as NSError {
            print(error)
            input = nil
            error
        }
        if(captureSession?.canAddInput(input) == true){
            captureSession?.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if(captureSession?.canAddOutput(stillImageOutput) == true){
                captureSession?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer?.frame = cameraView.bounds
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }
    }

    
    func didPressTakePhoto() {
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    
                    let largeImage = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    let image = UIImage(data: UIImageJPEGRepresentation(largeImage, 0.25)!)!
                    if self.self.backCamera == true {
                        self.tempImageView.image = image
                        FIRAnalytics.logEvent(withName: "back_camera_flare", parameters: nil)
                    } else {
                        self.tempImageView.image = self.flipImage(image)
                        FIRAnalytics.logEvent(withName: "front_camera_flare", parameters: nil)
                    }
                    self.tempImageView.isHidden = false
                    self.flareTitle.isHidden = false
                    self.flareTitle.becomeFirstResponder()
                    self.flashBtn.isHidden = true
                    self.cameraSwivelButton.isHidden = true
                }
            })
        }
    }
    
    func flipImage(_ image: UIImage!) -> UIImage! {
        let imageSize:CGSize = image.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0);
        let ctx:CGContext = UIGraphicsGetCurrentContext()!;
        ctx.rotate(by: CGFloat(M_PI/2.0));
        ctx.translateBy(x: 0, y: -imageSize.width);
        ctx.scaleBy(x: imageSize.height/imageSize.width, y: imageSize.width/imageSize.height);
        ctx.draw(image.cgImage!, in: CGRect(x: 0.0, y: 0.0, width: imageSize.width, height: imageSize.height));
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return newImage
    }
    
   
    func getDevice(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }


    
}
