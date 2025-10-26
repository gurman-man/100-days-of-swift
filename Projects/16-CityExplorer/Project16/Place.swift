//
//  Place.swift
//  Project16
//
//  Created by mac on 10.06.2025.
//

import UIKit
import MapKit

class Place: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var cityName: String?
    var urlType: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, cityName: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.cityName = cityName
    }
}
