//
//  GoogleGeocodeResponse.swift
//  RCRC
//
//  Created by Ganesh Shinde on 24/09/20.
//

import Foundation

// MARK: - Address
struct GoogleGeocodeResponse: Decodable {
    var results: [GeocodeResult]?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case results, status
    }
}

 struct DistanceMatrix: Decodable {
    let rows: [Row]?
 }

 struct Row: Decodable {
    let elements: [Element]?
 }

 struct Element: Decodable {
    let distance: Distance?
 }

struct Distance: Codable {
    let text: String?
}

// MARK: - Result
struct GeocodeResult: Decodable {
    var addressComponents: [AddressComponent]?
    let formattedAddress: String?
    let placeID: String?
    let types: [String]?

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case placeID = "place_id"
        case types
    }
}

// MARK: - AddressComponent
struct AddressComponent: Decodable {
    let longName, shortName: String?
    let types: [String]?

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}
