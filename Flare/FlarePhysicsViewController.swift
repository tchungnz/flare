//
//  FlarePhysicsViewController.swift
//  Flare
//
//  Created by Tim Chung on 12/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import UIKit


extension FlareViewController {
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + 0,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        if recognizer.state == UIGestureRecognizerState.Ended {
            let velocity = recognizer.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 2000
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            let finalPoint = CGPoint(x:recognizer.view!.center.x + (0),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))

            UIView.animateWithDuration(Double(slideFactor * 2),
                                       delay: 0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {recognizer.view!.center = finalPoint },
                completion: nil
        )
            self.onSwipe()

        }
        let seconds = 0.8
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
       dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("returnMap", sender: self)
        })
    }

}