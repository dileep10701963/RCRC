//
//  PlacesOfInterestModel.swift
//  RCRC
//
//  Created by Errol on 25/06/21.
//

import Foundation

struct PlacesOfInterestModel: Decodable {
    let nextPageToken: String?
    let results: [PlacesOfInterestResult]?
    let status: PlacesOfInterestStatus
    enum CodingKeys: String, CodingKey {
        case results, status
        case nextPageToken = "next_page_token"
    }
}

enum PlacesOfInterestStatus: String, Decodable {
    case ok = "OK"
    case noResults = "ZERO_RESULTS"
    case error = "UNKNOWN_ERROR"
}

enum PlacesOfInterestBusinessStatus: String, Decodable {
    case operational = "OPERATIONAL"
    case closedTemporarily = "CLOSED_TEMPORARILY"
    case closed = "CLOSED_PERMANENTLY"
}

struct PlacesOfInterestLocation: Decodable {
    let lat: Double
    let lng: Double
}

struct PlacesOfInterestGeometry: Decodable {
    let location: PlacesOfInterestLocation
}

struct PlacesOfInterestResult: Decodable {
    let businessStatus: PlacesOfInterestBusinessStatus?
    let icon: URL?
    var geometry: PlacesOfInterestGeometry?
    let name: String
    let vicinity: String?
    let placeID: String?

    enum CodingKeys: String, CodingKey {
        case businessStatus, icon, geometry, name, vicinity
        case placeID = "place_id"
    }
}
