//
//  PointOfInterest.swift
//  EverPobre
//
//  Created by Eduardo on 01/11/2018.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//

import Foundation
import MapKit

class PointOfInterest: NSObject {
    let name: String
  //  let info: String
    let location: CLLocationCoordinate2D
    
    init(name: String,  location: CLLocationCoordinate2D) {
        self.name = name
        self.location = location
    }
}

extension PointOfInterest: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return location
        }
    }
    
    var title: String? {
        get {
            return name
        }
    }
    

    
}

