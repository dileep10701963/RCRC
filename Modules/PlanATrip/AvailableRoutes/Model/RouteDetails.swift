//
//  RouteDetails.swift
//  RCRC
//
//  Created by Sagar Tilekar on 28/09/20.
//

import Foundation
import UIKit

// MARK: - Trip
struct Trip: Codable {
    let version: String?
    let systemMessages: [SystemMessage?]?
    let journeys: [Journey?]?
}

// MARK: - Journey
struct Journey: Codable {
    let rating: Int?
    let isAdditional: Bool?
    let interchanges: Int?
    let legs: [Leg?]?
    let fare: Fare?
    let daysOfService: DaysOfService?
}

// MARK: - DaysOfService
struct DaysOfService: Codable {
    let rvb: String?
}

// MARK: - Fare
struct Fare: Codable {
    let tickets: [Ticket?]?
    let zones: [ZoneElement?]?
}

// MARK: - Ticket
struct Ticket: Codable {
    let currency: String?
    let name: String?
    let properties: TicketProperties?
}

enum Currency: String, Codable {
    case sar = "SAR"
}

enum IsShortHaul: String, Codable {
    case no = "NO"
}

enum Net: String, Codable {
    case rda
}

enum Person: String, Codable {
    case adult = "ADULT"
    case child = "CHILD"
    case reduced = "REDUCED"
    case scholar = "SCHOLAR"
    case senior = "SENIOR"
    case student = "STUDENT"
}

// MARK: - TicketProperties
struct TicketProperties: Codable {
    let riderCategoryName: RiderCategoryName?
    let priceTotalFare: String?
}

enum RiderCategoryName: String, Codable {
    case adult = "Adult"
    case child = "Child"
    case disabled = "Disabled"
    case minor = "Minor"
    case senior = "Senior"
    case student = "Student"
}

enum TimeValidity: String, Codable {
    case single = "SINGLE"
}

enum TravellerClass: String, Codable {
    case second = "SECOND"
}

enum ValidForOneJourneyOnly: String, Codable {
    case slightLeft = "SLIGHT_LEFT"
    case slightRight = "SLIGHT_RIGHT"
    case straight = "STRAIGHT"
    case unknown = "UNKNOWN"
    case sharpLeft = "SHARP_LEFT"
    case sharpRight = "SHARP_RIGHT"
    case uTurn = "U_TURN"
    case left = "LEFT"
    case right = "RIGHT"
    
    var image: UIImage {
            switch self {
            case .straight:
                return Images.dirStraight!
            case .left:
                return Images.dirLeft!
            case .right:
                return Images.dirRight!
            case .slightLeft:
                return Images.dirSlightLeft!
            case .slightRight:
                return Images.dirSlightRight!
            case .sharpLeft:
                return Images.dirSharpLeft!
            case .sharpRight:
                return Images.dirSharpRight!
            case .uTurn:
                return Images.dirUTurn!
            default:
                return UIImage()
            }
        }
}

// MARK: - ZoneElement
struct ZoneElement: Codable {
    let net: Net?
    let toLeg, fromLeg: Int?
    let neutralZone: String?
}

// MARK: - Leg
struct Leg: Codable {
    let duration: Int?
    let distance: Int?
    let origin: Origin?
    let destination: Destination?
    let transportation: Transportation
    let stopSequence: [StopSequence?]?
    let coords: [[Double?]?]?
    let pathDescriptions: [PathDescription]?
}

// MARK: - Destination
struct Destination: Codable {
    let isGlobalId: Bool?
    let id, name: String?
    let disassembledName: String?
    let type: OriginType?
    let parent: Parent?
    let arrivalTimeEstimated: String?
    let arrivalTimePlanned: String?
}

// MARK: - Parent
class Parent: Codable {
    let id, name: String?
    let type: ParentType?
    let parent: Parent?
}

enum ParentType: String, Codable {
    case locality
    case stop
}

// MARK: - DestinationProperties
struct DestinationProperties: Codable {
    let downloads: [Download?]?
    let areaNiveauDiva: String?

    enum CodingKeys: String, CodingKey {
        case downloads
        case areaNiveauDiva
    }
}

// MARK: - Download
struct Download: Codable {
    let type: DownloadType?
    let url: URLEnum?
}

enum DownloadType: String, Codable {
    case rm = "RM"
}

enum URLEnum: String, Codable {
    case fileloadFilenameRda5F6C374F1PDF = "FILELOAD?Filename=rda_5F6C374F1.pdf"
    case fileloadFilenameRda5F6C374F2PDF = "FILELOAD?Filename=rda_5F6C374F2.pdf"
    case fileloadFilenameRda5F6C374F3PDF = "FILELOAD?Filename=rda_5F6C374F3.pdf"
    case fileloadFilenameRda5F6C374F4PDF = "FILELOAD?Filename=rda_5F6C374F4.pdf"
    case fileloadFilenameRda5F6C374F5PDF = "FILELOAD?Filename=rda_5F6C374F5.pdf"
}

enum OriginType: String, Codable {
    case platform
    case stop
    case address
    case placeOfInterest = "poi"
    case street
}

// MARK: - FootPathInfo
struct FootPathInfo: Codable {
    let position: String?
    let duration: Int?
}

// MARK: - Origin
struct Origin: Codable {
    let id, name: String?
    let disassembledName: String?
    let type: OriginType?
    let parent: Parent?
    let departureTimeEstimated: String?
    let departureTimePlanned: String?
}

// MARK: - StopSequence
struct StopSequence: Codable {
    let isGlobalID: Bool?
    let id, name, disassembledName: String?
    let type: OriginType?
    let coord: [Double]?
    let niveau: Int?
    let parent: Parent?
    let productClasses: [Int]?
    let properties: DestinationProperties?
    let departureTimePlanned, arrivalTimePlanned: String?
    let departureTimeEstimated, arrivalTimeEstimated: String?

    enum CodingKeys: String, CodingKey {
        case isGlobalID = "isGlobalId"
        case id, name, disassembledName, type, coord, niveau, parent, productClasses, properties, departureTimePlanned, arrivalTimePlanned, departureTimeEstimated, arrivalTimeEstimated
    }
}

// MARK: - StopSequenceProperties
struct StopSequenceProperties: Codable {
    let areaNiveauDiva: String?
    let zone: ZoneEnum?

    enum CodingKeys: String, CodingKey {
        case areaNiveauDiva
        case zone
    }
}

enum ZoneEnum: String, Codable {
    case rda1 = "rda:1"
}

// MARK: - Transportation
struct Transportation: Codable {
    let product: Product
    let name: String?
    let destination: transportDestination?
}

struct transportDestination: Codable {
    let name: String?
}

enum ID: String, Codable {
    case rda01007RA20 = "rda:01007: :R:a20"
    case rda01016RA20 = "rda:01016: :R:a20"
    case rda01660HA20 = "rda:01660: :H:a20"
}

// MARK: - Product
struct Product: Codable {
    let name: ProductName
    let iconId: Int?
    let id: Int?
}

enum ProductName: String, Codable {
    case bus = "Bus"
    case footpath = "footpath"
    case FootPath = "Footpath"
    case cycling = "Fahrrad"
    case taxi = "Taxi"
    case BUS = "n.n."
    case community = "Community"
    case arabBus = "حافلة"
    case arabFootpath = "مسار المشي"
}

// MARK: - TransportationProperties
struct TransportationProperties: Codable {
    let tripCode: Int?
    let mtSubcode: String?
    let lineDisplay: LineDisplay?
    let timetablePeriod: TimetablePeriod?
    let trainName: String?
}

enum LineDisplay: String, Codable {
    case line = "LINE"
}

enum TimetablePeriod: String, Codable {
    case timetablePeriodImport = "import"
}

enum Description: String, Codable {
    case bilalBinRabah04AlBatha01 = "Bilal Bin Rabah_04-Al Batha_01"
    case ksu03TransportationCenterInterchange = "KSU_03-Transportation Center (Interchange)"
    case transportationCenterInterchangeDirab01 = "Transportation Center (Interchange)-Dirab_01"
}

// MARK: - Operator
struct Operator: Codable {
    let code, id: Code?
    let name: OperatorName?
}

enum Code: String, Codable {
    case ptc = "PTC"
}

enum OperatorName: String, Codable {
    case publicTransportationCompany = "Public Transportation Company"
}

// MARK: - SystemMessage
struct SystemMessage: Codable {
 //   let type, module: String
    let code: Int?
    let text: String?
}

// MARK: - PathDescription
struct PathDescription: Codable {
    let fromCoordsIndex, distance: Int?
    let coord: [Double]?
    let toCoordsIndex, skyDirection, cumDuration, duration: Int?
    let cumDistance: Int?
    let manoeuvre: Manoeuvre
    let turnDirection: ValidForOneJourneyOnly
    let name: String?
}

enum Manoeuvre: String, Codable {
    case origin = "ORIGIN"
    case destination = "DESTINATION"
    case continueM = "CONTINUE"
    case keep = "KEEP"
    case turn = "TURN"
    case uTurn = "U_TURN"
    case enter = "ENTER"
    case leave = "LEAVE"
    case enterRoundAbout = "ENTER_ROUNDABOUT"
    case stayRoundAbout = "STAY _ROUNDABOUT"
    case stayRoundAboutWS = "STAY_ROUNDABOUT"
    case leaveRoundAbout = "LEAVE _ROUNDABOUT"
    case leaveRoundAboutWS = "LEAVE_ROUNDABOUT"
    case traverseCrossing = "TRAVERSE_CROSSING"
    case enterBuiltUparea = "ENTER_BUILTUPAREA"
    case leaveBuiltUparea = "LEAVE _BUILTUPAREA"
    case leaveBuiltUpareaWS = "LEAVE_BUILTUPAREA"
    case enterToll = "ENTER_TOLL"
    case leaveToll = "LEAVE_TOLL"
    case ramp = "RAMP"
    case onRamp = "ON_RAMP"
    case offRamp = "OFF_RAMP"
    case unknow = "UNKNOWN"
}
