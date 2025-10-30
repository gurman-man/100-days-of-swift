//
//  Country.swift
//  CountryFacts
//
//  Created by mac on 07.06.2025.
//

import Foundation

struct Country: Codable {
    let name: Name
    let population: Int
    let area: Double
    let timezones: [String]
    let capital: [String]?
    let currencies: [String: Currency]?
    let languages: [String: String]?
    let car: Car?
    let idd: IDD?
    let flags: Flags
    
    struct Name: Codable {
        let common: String
        let official: String
    }
    
    struct Currency: Codable {
        let name: String
        let symbol: String?
    }
    
    struct Car: Codable {
        let side: String?
    }
    
    struct IDD: Codable {
        let root: String?
        let suffixes: [String]?
    }
    
    struct Flags: Codable {
        let png: String
    }
    
    
    var displayName: String { name.common }
    var displayOfficialName: String { name.official }
    
    var displayTimezones: String { timezones.joined(separator: ", ")}
    var displayCapital: String { capital?.joined(separator: ", ") ?? "N/A" }
    
    var displayCurrencies: String {
           currencies?.map { "\($0.value.name) (\($0.key))" }.joined(separator: ", ") ?? "N/A"
       }
    
    var displayLanguages: String {
           languages?.map { $0.value }.joined(separator: ", ") ?? "N/A"
       }
    
    var displayCallingCode: String {
        guard let root = idd?.root, let suffixes = idd?.suffixes else { return "N/A" }
        return suffixes.map { root + $0 }.joined(separator: ", ")
    }
    
    var displayDriveSide: String { car?.side ?? "N/A"}
}

