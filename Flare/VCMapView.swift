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
        
        let pinImage = UIImage(named: "flarePin")
        annotationView!.image = pinImage
        
        return annotationView
    }
}