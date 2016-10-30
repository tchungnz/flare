//
//  OverlayViewController.swift
//  Flare
//
//  Created by Tim Chung on 30/10/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController {
    
    func plotBoosts(_ boostOverlays: [MKCircle]) {
        self.mapView.delegate = self
        self.mapView.removeOverlays(boostOverlays)
        //        self.mapView.addOverlays(boostOverlays)
        for item in boostOverlays {
            print("X")
            self.mapView.add(item)
        }
    }
    
    func createBoostArrayAndPlot(flares: [Flare]) {
        createBoostOverlayArray(flares: flares) {
            (result: [MKCircle]) in
            self.plotBoosts(result)
        }
    }
    
    func createBoostOverlayArray(flares: [Flare], completion: @escaping (_ result: [MKCircle]) -> ()) {
        var boostOverlays = [MKCircle]()
        for item in flares {
            if item.boostCount != nil && item.boostCount != 0 {
                for index in 1...(item.boostCount!) {
                    let radius: CLLocationDistance
                    if item.boostCount != nil {
                        radius = CLLocationDistance(index*150)
                    } else {
                        radius = CLLocationDistance(0)
                    }
                    let newBoostOverlay = MKCircle(center: item.coordinate, radius: radius)
                    boostOverlays.append(newBoostOverlay)
                }
            }
        }
        completion(boostOverlays)
    }
    
    @objc(mapView:viewForOverlay:) func mapView(_ mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self){
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.1)
            //            circleRenderer.strokeColor = UIColor.red
            //            circleRenderer.lineWidth = 0.5
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}
