//
//  Petitions.swift
//  Project7
//
//  Created by mac on 12.02.2025.
//

import Foundation

// Структура для всього JSON((формат для передачі даних) масив ПЕТИЦІЙ)
struct Petitions: Codable {
    var results: [Petition]
}
 
