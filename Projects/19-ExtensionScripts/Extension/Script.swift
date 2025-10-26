//
//  Script.swift
//  Extension
//
//  Created by mac on 21.06.2025.
//

import Foundation

// Codable дозволяє легко зберігати цю структуру у UserDefaults
struct Script: Codable {
    var name: String
    var code: String
}
