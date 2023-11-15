//
//  LiveBusStatusModel.swift
//  RCRC
//
//  Created by Aashish Singh on 18/05/23.
//

import Foundation

struct LiveBusStatusModel: Codable {
    let motCode: Int?
    let dayOfOperation: String?
    let x, y: String?
    let productIdentifier: String?
    let id: String?
    let realtimeAvailable: Int?
    let currentStop, directionText: String?
    let delay: Int?
    let welcomeOperator: String?
    let timestamp: String?
    let journeyIdentifier, vehicleIdentifier, lineText: String?
    let isAtStop: Bool?
    let distance: Int?
    let nextStop: String?
    let timestampPrevious: String?
    let xPrevious, yPrevious: String?

    enum CodingKeys: String, CodingKey {
        case motCode = "MOTCode"
        case dayOfOperation = "DayOfOperation"
        case x = "X"
        case y = "Y"
        case productIdentifier = "ProductIdentifier"
        case id = "ID"
        case realtimeAvailable = "RealtimeAvailable"
        case currentStop = "CurrentStop"
        case directionText = "DirectionText"
        case delay = "Delay"
        case welcomeOperator = "Operator"
        case timestamp = "Timestamp"
        case journeyIdentifier = "JourneyIdentifier"
        case vehicleIdentifier = "VehicleIdentifier"
        case lineText = "LineText"
        case isAtStop = "IsAtStop"
        case distance = "Distance"
        case nextStop = "NextStop"
        case timestampPrevious = "TimestampPrevious"
        case xPrevious = "XPrevious"
        case yPrevious = "YPrevious"
    }
}
