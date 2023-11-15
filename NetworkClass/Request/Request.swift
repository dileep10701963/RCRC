//
//  Request.swift
//  RCRC
//
//  Created by Ganesh Shinde on 07/08/20.
//

import Foundation
import GoogleMaps

// Weather Request Paremeters
struct WeatherRequest: Encodable {
}

// Document Type Request Paremeters
struct DocumentTypeRequest: Encodable {
}

// App Info Request
struct AppInfoRequest: Encodable {
}

// Get Profile Request Paremeters
struct GetProfileRequest: Encodable {
}

// Hardcoded values for demo purpose
struct AvailableRouteRequest: Encodable {
    var outputFormat: String? = "rapidJSON"
    var typeOrigin: String?
    var nameOrigin: String?
    var typeDestination: String?
    var nameDestination: String?
    var coordOutputFormat: String = "WGS84[DD.DDDDD]"
    var itdTripDateTimeDepArr: String?
    var itdDate: String?
    var itdTime: String?
    var cyclingActive: Int? = 0
    var locationServerActive: Int? = 1
    var itOptionsActive: Int? = 1
    var useAllStopsForMOT: Int? = 5
    var alterNativeStops: Int? = 1
    var routePreferences: String?
    var maxWalkTime: String?
    var walkingSpeed: String?
    var ptOptionsActive: Int? = 1
    var calcOneDirection: Int? = 1
    var trITMOT: Int? = 100
    var excludedMeans: Int?
    var includedMeans: Int?
    var lng: String = currentLanguage.rawValue
    var useRealtime:Int? = 1
    var allInterchangesAsLegs: Int? = 1
    
    //var impairedFriendlyStrip: String = ""
    //var methodOfTransport: String = ""
    

    enum CodingKeys: String, CodingKey {
        case typeOrigin = "type_origin"
        case nameOrigin = "name_origin"
        case typeDestination = "type_destination"
        case nameDestination = "name_destination"
        case alterNativeStops = "useProxFootSearch"
        case maxWalkTime = "trITMOTvalue"
        case walkingSpeed = "changeSpeed"
        case routePreferences = "routeType"
        case lng = "language"
        case outputFormat,
             coordOutputFormat,
             itdDate,
             itdTime,
             itdTripDateTimeDepArr,
             cyclingActive,
             locationServerActive,
             itOptionsActive,
             useAllStopsForMOT,
             ptOptionsActive,
             trITMOT,
             excludedMeans,
             includedMeans,
             calcOneDirection,
             useRealtime,
             allInterchangesAsLegs
    }

}

struct SearchRequest: Encodable {
    var nameSf: String
    let extMacro: String = "sf"
    let typeSf: String = "any"
    let outputFormat: String = "rapidJSON"
    let coordOutputFormat: String = "WGS84[DD.DDDDD]"
    let locationServerActive: String = "1"
    let wPrefStopModesAm: String = "3"
    let anySigWhenPerfectNoOtherMatches: String = "1"
    let useProxFootSearch: String = "1"
    let doNotSearchForStopsSf: String = "1"
    let language: String = currentLanguage == .arabic ? "ar": "en"
    let version: String = "10.5.17.3"

    enum CodingKeys: String, CodingKey {
        case nameSf = "name_sf"
        case extMacro = "ext_macro"
        case typeSf = "type_sf"
        case wPrefStopModesAm = "w_prefStopModesAm"
        case doNotSearchForStopsSf = "doNotSearchForStops_sf"
        case outputFormat,
             coordOutputFormat,
             locationServerActive,
             anySigWhenPerfectNoOtherMatches,
             useProxFootSearch,
             language,
             version
    }
}

struct ReverseGeocodeRequest: Encodable {
    var nameSf: String
    let typeSf: String = "coord"
    let outputFormat: String = "rapidJSON"
    let coordOutputFormat: String = "WGS84[DD.DDDDD]"

    enum CodingKeys: String, CodingKey {
        case nameSf = "name_sf"
        case typeSf = "type_sf"
        case outputFormat, coordOutputFormat
    }
}

struct FileUploadRequest: Encodable {
    var fileName: String
    var fileContent: String
}

struct SendEmailRequest: Encodable {
    var from: String
    var to: String
    var subject: String
    var contentType: String
    var content: String
    var attachmentId: String?
}

// MARK: - Google Api

struct GoogleGeocodeRequest: Encodable {
    var latlng: String?
    var language: String? = "en"
    var key = Keys.googleApiKey
}

struct GoogleDistanceRequest: Encodable {
    var origins: String?
    var language: String? = "en"
    var destinations: String?
    var key = Keys.googleApiKey
}
struct DistanceMatrixRequest: Encodable {
    let key = Keys.googleApiKey
    let units = "metric"
    let origins: String
    let destinations: String
}

struct DefaultParameters: Encodable {}

struct Wso2TokenRequest: Codable {
    let grantType: String = "client_credentials"

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
    }
}

struct GetBusStopRequest: Encodable {
    
    var sl3plusCoordInfoMacro: String? = "1"
    var coordOutputFormat: String? = "WGS84%5BDD.DDDDD%5D"
    var inclFilter: Int? = 1
    var serverInfo: Int? = 1
    var rptnCoordInfoMacro: Int? = 1
    var boundingBox: String? = ""
    var boundingBoxLU: String? = "46.582031%3A24.726859%3AWGS84%5BDD.DDDDD%5D"
    var boundingBoxRL: String? = "46.933594%3A24.567092%3AWGS84%5BDD.DDDDD%5D"
    var language: String? = AFCAPIHeaders.afcLanguage
    var outputFormat: String? = "rapidJSON"
    var type: String? = "BUS_POINT"
    var version: String? = "10.5.17.3"
    
    enum CodingKeys: String, CodingKey {
        case type = "type_1"
        case version,
             sl3plusCoordInfoMacro,
             coordOutputFormat,
             inclFilter,
             serverInfo,
             rptnCoordInfoMacro,
             boundingBox,
             boundingBoxLU,
             boundingBoxRL,
             language,
             outputFormat
    }
    
}

struct GetBusStopForMapRequest: Encodable {
    
    
    
}
struct GetLiveBusRequest: Encodable {
    
    var coordSystem: String? = "WGS84"
    var maxX: String? = "46.84484481159438"
    var maxY: String? = "24.738552623825992"
    var motCode: String? = "-1"
    
    enum CodingKeys: String, CodingKey {
        case coordSystem = "CoordSystem"
        case maxX = "MaxX"
        case maxY = "MaxY"
        case motCode = "MOTCode"
    }
    
}

struct GetStopRouteRequest: Encodable {
    
    var outputFormat: String? = "rapidJSON"
    var coordOutputFormat: String? = "WGS84[DD.DDDDD]"
    var lineReqType: String? = "1"
    var line: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case outputFormat,
             coordOutputFormat,
             lineReqType,
             line
    }
    
}

struct GetNextBusInfoRequest: Encodable {
    
    var namedm: String?
    var typedm: String? = "any"
    var outputFormat: String? = "rapidJSON"
    var mode: String? = "direct"
    var itdDate: String? = Date().dateString
    var itdTime: String? = String(format: Constants.timeDoubleDigitFormat,
                                  arguments: [ Date().hour, Date().minute])
    var useRealtime: String? = "1%27"
    
    enum CodingKeys: String, CodingKey {
        case namedm = "name_dm"
        case typedm = "type_dm"
        case outputFormat,
             mode,
             itdDate,
             itdTime,
             useRealtime
        
    }
    
}
