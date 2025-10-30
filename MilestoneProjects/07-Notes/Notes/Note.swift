//
//  Note.swift
//  Notes
//
//  Created by mac on 02.07.2025.
//

import UIKit

struct Note: Codable {
    var text: String
    var date: Date
    var id: UUID = UUID()
    
    
    init(text: String, date: Date, id: UUID) {
        self.text = text
        self.date = date
        self.id = id
    }
}

