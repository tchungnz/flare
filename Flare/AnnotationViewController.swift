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
    
    @objc(mapView:viewForAnnotation:) func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var av = self.mapView.view(for: self.mapView.userLocation)
        av?.isEnabled = false

        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let flare = annotation as! Flare
        
        let pinImage = UIImage(named: flare.imageName)
        annotationView!.image = pinImage
        let btn = UIButton(type: .detailDisclosure)
        annotationView!.rightCalloutAccessoryView = btn
        return annotationView
    }
    
    @objc(mapView:didSelectAnnotationView:) func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? Flare {
            self.flareExport = annotation
        }
    }
    
    func mapView(_ mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "flareDetail", sender: annotationView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flareDetail" {
            if let ivc = segue.destination as? FlareDetailViewController {
                ivc.flareExport = self.flareExport
                ivc.userLocation = self.location
            }
        }
    }
    
}
