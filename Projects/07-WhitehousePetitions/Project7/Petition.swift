//
//  Petition.swift
//  Project7
//
//  Created by mac on 12.02.2025.
//

import Foundation

// Структура для однієї ПЕТИЦІЇ
struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
