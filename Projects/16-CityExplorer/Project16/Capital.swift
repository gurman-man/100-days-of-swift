//
//  Capital.swift
//  Project16
//
//  Created by mac on 09.06.2025.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?                          // що показується над пінами на мапі
    var coordinate: CLLocationCoordinate2D      //  координати анотації
    var info: String                            // додаткова інформація
    
    init(title: String? = nil, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
