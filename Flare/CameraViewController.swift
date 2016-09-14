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

extension FlareViewController {

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func switchCameraViewFront() {
        cameraToggleState = 2
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
    
    func switchCameraViewBack() {
        cameraToggleState = 1
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

    
    func didPressTakePhoto() {
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    if self.self.cameraToggleState == 1 {
                        self.tempImageView.image = image
                    } else {
                        self.tempImageView.image = self.flipImage(image)
                    }
                    self.tempImageView.hidden = false
                    self.flareTitle.hidden = false
                    self.flareTitle.becomeFirstResponder()
                    self.flashBtn.hidden = true
                }
            })
        }
    }
    
    func flipImage(image: UIImage!) -> UIImage! {
        let imageSize:CGSize = image.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0);
        let ctx:CGContextRef = UIGraphicsGetCurrentContext()!;
        CGContextRotateCTM(ctx, CGFloat(M_PI/2.0));
        CGContextTranslateCTM(ctx, 0, -imageSize.width);
        CGContextScaleCTM(ctx, imageSize.height/imageSize.width, imageSize.width/imageSize.height);
        CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), image.CGImage);
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
    
    //Get the device (Front or Back)
    func getDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices();
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }


    
}