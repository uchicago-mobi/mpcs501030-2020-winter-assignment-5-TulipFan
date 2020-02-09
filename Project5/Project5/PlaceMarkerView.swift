//
//  PlaceMarkerView.swift
//  Project5
//
//  Created by YAJING FAN on 2/7/20.
//  Copyright © 2020 YAJING FAN. All rights reserved.
//

import Foundation
import MapKit

class PlaceMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            clusteringIdentifier = "Place"
            displayPriority = .defaultLow
            markerTintColor = .systemRed
            glyphImage = UIImage(systemName: "pin.fill")
        }
    }
}
