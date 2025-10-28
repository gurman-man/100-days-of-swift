//
//  Person.swift
//  Project10
//
//  Created by mac on 01.05.2025.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
