//
//  VCMapView.swift
//  Flare
//
//  Created by Tim Chung on 07/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)

            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "redFlareMapPin")
        annotationView!.image = pinImage
        let btn = UIButton(type: .DetailDisclosure)
        annotationView!.rightCalloutAccessoryView = btn
                
        return annotationView
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation as? Flare {
            self.flareExport = annotation
//            print("Your annotation title: \(annotation.imageRef)");
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            performSegueWithIdentifier("flareDetail", sender: annotationView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "flareDetail" {
                if let ivc = segue.destinationViewController as? FlareDetailViewController {
                    ivc.flareExport = self.flareExport
                }
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        if (segue.identifier == "fareDetail") {
//        
//        // Create a variable that you want to send
//        var newTestVariable = "some text"
//        
//        // Create a new variable to store the instance of PlayerTableViewController
//        let destinationVC = segue.destinationViewController as! FlareDetailViewController
//        destinationVC.testVariable = newTestVariable
//        }
}
