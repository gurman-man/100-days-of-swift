//
//  Photo.swift
//  Consolidation5_PhotoList
//
//  Created by mac on 14.05.2025.
//

import UIKit

struct Photo: Codable {
    var imageName: String
    var imageCaption: String
    
    init(imageName: String, imageCaption: String) {
        self.imageName = imageName
        self.imageCaption = imageCaption
    }
}
