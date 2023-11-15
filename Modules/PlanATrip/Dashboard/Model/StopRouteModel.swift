//
//  StopRouteModel.swift
//  RCRC
//
//  Created by Aashish Singh on 12/06/23.
//

import Foundation

struct StopRouteModel: Codable {
    let version: String?
    let transportations: [RouteTransportation]?
    let routeColorIdentifier: String?
}

// MARK: - RouteTransportation
struct RouteTransportation: Codable {
    let id, name, disassembledName, number: String?
    let description: String?
    let product: RouteProduct?
    let transportationOperator: RouteOperator?
    let destination: RouteDestination?
    let properties: RouteTransportationProperties?
    let coords: [[[Double]]]?
    let locationSequence: [LocationSequence]?

    enum CodingKeys: String, CodingKey {
        case id, name, disassembledName, number, description, product
        case transportationOperator = "operator"
        case destination, properties, coords, locationSequence
    }
}

// MARK: - Destination
struct RouteDestination: Codable {
    let id: String?
    let name: String?
}


// MARK: - LocationSequence
struct LocationSequence: Codable {
    let isGlobalID: Bool?
    let id, name, disassembledName: String?
    let coord: [Double]
    let parent: RouteParent?
    let productClasses: [Int]?
    let properties: LocationSequenceProperties?

    enum CodingKeys: String, CodingKey {
        case isGlobalID = "isGlobalId"
        case id, name, disassembledName, coord, parent, productClasses, properties
    }
}

// MARK: - Parent
struct RouteParent: Codable {
    let isGlobalID: Bool?
    let id, name: String?
    let parent: RouteDestination?
    let properties: ParentProperties?

    enum CodingKeys: String, CodingKey {
        case isGlobalID = "isGlobalId"
        case id, name, parent, properties
    }
}

// MARK: - ParentProperties
struct ParentProperties: Codable {
    let stopID: String?

    enum CodingKeys: String, CodingKey {
        case stopID = "stopId"
    }
}

// MARK: - LocationSequenceProperties
struct LocationSequenceProperties: Codable {
    let stopMeans, stopMajorMeans, publicStopPointNameWithPlace, publicStopPointName: String?
    let areaNiveauDiva, area, platform: String?

    enum CodingKeys: String, CodingKey {
        case stopMeans = "STOP_MEANS"
        case stopMajorMeans = "STOP_MAJOR_MEANS"
        case publicStopPointNameWithPlace = "PUBLIC_STOP_POINT_NAME_WITH_PLACE"
        case publicStopPointName = "PUBLIC_STOP_POINT_NAME"
        case areaNiveauDiva = "AREA_NIVEAU_DIVA"
        case area, platform
    }
}

// MARK: - Product
struct RouteProduct: Codable {
    let id, productClass: Int?
    let name: String?
    let iconID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case productClass = "class"
        case name
        case iconID = "iconId"
    }
}

// MARK: - TransportationProperties
struct RouteTransportationProperties: Codable {
    let tripCode: Int?
    let timetablePeriod: String?
    let validity: Validity?
    let lineDisplay: String?
}

// MARK: - Validity
struct Validity: Codable {
    let from, to: String?
}

// MARK: - Operator
struct RouteOperator: Codable {
    let code, id, name: String?
}
