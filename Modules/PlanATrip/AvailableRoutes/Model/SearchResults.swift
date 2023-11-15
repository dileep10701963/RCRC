//
//  SearchResults.swift
//  RCRC
//
//  Created by Errol on 30/09/20.
//

import Foundation

struct SearchResults: Decodable {
    var locations: [Location?]
    var systemMessages: [SystemMessage?]
    var googleLocations: [PlacesOfInterestResult]?
}

// MARK: - Location
struct Location: Decodable {
    let productClasses: [Int]?
    let disassembledName: String?
    let id: String?
    let coord: [Double]?
    let parent: SearchLocationParent?
    let properties: LocationProperties?
    let isGlobalID: Bool?
    let type: String?
    let name: String?
    let matchQuality: Int?

    enum CodingKeys: String, CodingKey {
        case productClasses, disassembledName, id, coord, parent, properties
        case isGlobalID = "isGlobalId"
        case type, name, matchQuality
    }
}

// MARK: - Parent
struct SearchLocationParent: Codable {
    let id: String?
    let name: String?
    let type: String?
}

// MARK: - Properties
struct LocationProperties: Codable {
    let stopID: String?

    enum CodingKeys: String, CodingKey {
        case stopID = "stopId"
    }
}
