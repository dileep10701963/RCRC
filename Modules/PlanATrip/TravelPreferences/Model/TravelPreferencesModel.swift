//
//  TravelPreferencesModel.swift
//  RCRC
//
//  Created by Aashish Singh on 03/08/22.
//

import Foundation

enum RoutePreference: String, CaseIterable, Codable {
    case quickest = "LEASTTIME"
    case fewer = "LEASTINTERCHANGE"
    case least = "LEASTWALKING"
    
    var displayName: String {
        switch self {
        case .quickest:
            return Constants.quickestConnection.localized
        case .fewer:
            return Constants.fewerInterchanges.localized
        case .least:
            return Constants.leastWalking.localized
        }
    }
    
    var apiValue: String {
        switch self {
        case .quickest:
            return "LEASTTIME"
        case .fewer:
            return "LEASTINTERCHANGE"
        case .least:
            return "LEASTWALKING"
        }
    }
}

enum WalkSpeedPreference: String, CaseIterable, Codable {
    case slow = "slow"
    case normal = "normal"
    case fast = "fast"
    
    var displayName: String {
        switch self {
        case .slow:
            return Constants.slow.localized
        case .normal:
            return Constants.normal.localized
        case .fast:
            return Constants.fast.localized
        }
    }
}

enum MaxWalkTimePreferences: String, CaseIterable, Codable {
    case fiveMin = "5"
    case tenMin = "10"
    case fifteenMin = "15"
    case twentyMin = "20"
    case thirtyMin = "30"
    case fortyFiveMin = "45"
    case sixtyMin = "60"
    
    var displayTime: String {
        switch self {
        case .fiveMin: return "5 min".localized
        case .tenMin: return "10 min".localized
        case .fifteenMin: return "15 min".localized
        case .twentyMin: return "20 min".localized
        case .thirtyMin: return "30 min".localized
        case .fortyFiveMin: return "45 min".localized
        case .sixtyMin: return "60 min".localized
        }
    }
}

enum TransportMethodPreferences: String, CaseIterable, Codable {
    case bus
//    case uber
//    case metro
//    case careem
    
    var transportMethodName: String {
        switch self {
        case .bus:
            return "Bus".localized
//        case .uber:
//            return "Uber".localized
//        case .metro:
//            return "Metro".localized
//        case .careem:
//            return "Careem".localized
        }
    }
    
    var transportTypeImages: String {
        switch self {
        case .bus:
            return "busTicketImage"
//        case .uber:
//            return "uber_trans"
//        case .metro:
//            return "metro_trans"
//        case .careem:
//            return "careem_trans"
        }
    }
}

struct SaveTravelPreferencesModel: Codable {
    var collection: String
    var documents: [TravelPreferenceModel]
}

struct TravelPreferenceModel: Codable, Equatable {
    var userName: String?
    var alternativeStopsPreference: Bool?
    var busTransport: Bool?
    var careemTransport: Bool?
    var impaired: Bool?
    var maxTime: MaxWalkTimePreferences?
    var metroTransport: Bool?
    var routePreference: RoutePreference?
    var uberTransport: Bool?
    var walkSpeed: WalkSpeedPreference?
    var FindOneResult: String?
    
    static func == (lhs: TravelPreferenceModel, rhs: TravelPreferenceModel) -> Bool {
            return (lhs.userName ?? "" == rhs.userName ?? "" &&
                    lhs.alternativeStopsPreference ?? false == rhs.alternativeStopsPreference ?? false &&
                    lhs.busTransport ?? false == rhs.busTransport ?? false &&
                    lhs.walkSpeed == rhs.walkSpeed &&
                    lhs.routePreference == rhs.routePreference &&
                    lhs.maxTime == rhs.maxTime)
        }
    
}
