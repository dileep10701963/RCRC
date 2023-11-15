//
//  EventModel.swift
//  RCRC
//
//  Created by Errol on 22/06/21.
//

//import Foundation
//
//struct Event: Decodable {
//    let name: String
//    let coordinates: String
//    let startDate: String
//    let endDate: String
//    let startTime: String
//    let endTime: String
//    let entryFee: String
//    let description: String
//    let imageURL: URL
//
//    enum CodingKeys: String, CodingKey {
//        case name = "nameEn"
//        case description = "descriptionEn"
//        case coordinates, startDate, startTime, endDate, endTime
//        case entryFee = "price"
//        case imageURL = "imagesEn"
//    }
//}
//
//struct EventRoot: Decodable {
//    let totalCount: Int
//    let events: [Event]
//
//    enum CodingKeys: String, CodingKey {
//        case totalCount = "TotalCount"
//        case events = "Events"
//    }
//}


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let eventRoot = try? newJSONDecoder().decode(EventRoot.self, from: jsonData)

import Foundation

// MARK: - EventRoot
struct EventRoot: Codable {
    let totalCount: Int
    let events: [Event]

    enum CodingKeys: String, CodingKey {
        case totalCount = "TotalCount"
        case events = "Events"
    }
}

// MARK: - Event
struct Event: Codable {
    let imagesEn: String
    let columnBitmask: Int
    let endDate: String
    let cachedModel: Bool
    let groupID: Int
    let imagesAr, uuid: String
    let attributeSetterBIConsumers: [String: Attribute]
    let price, descriptionEn: String
    let eventID: Int
    let new: Bool
    let nameAr: String
    let finderCacheEnabled: Bool
    let modelClass, timing, descriptionAr, nameEn: String
    let arIsSubmitted: String
    let companyID: Int
    let modelAttributes: ModelAttributes
    let nameUr, userUUID, modifiedDate, startDate: String
    let originalUUID, originalNameEn: String
    let stagedModelType: StagedModelType
    let url: String
    let modelClassName, programStartTime: String
    let originalEventID: Int
    let currency, startTime, descriptionUr: String
    let attributeGetterFunctions: [String: Attribute]
    let expandoBridge: ExpandoBridge
    let createDate, coordinates: String
    let entityCacheEnabled: Bool
    let userName: String
    let userID, originalCompanyID: Int
    let escapedModel: Bool
    let primaryKeyObj, originalGroupID: Int
    let imagesUr, urIsSubmitted, endTime, enIsSubmitted: String
    let programEndTime: String
    let primaryKey: Int

    enum CodingKeys: String, CodingKey {
        case imagesEn, columnBitmask, endDate, cachedModel
        case groupID = "groupId"
        case imagesAr, uuid
        case attributeSetterBIConsumers = "attributeSetterBiConsumers"
        case price, descriptionEn
        case eventID = "eventId"
        case new, nameAr, finderCacheEnabled, modelClass, timing, descriptionAr, nameEn, arIsSubmitted
        case companyID = "companyId"
        case modelAttributes, nameUr
        case userUUID = "userUuid"
        case modifiedDate, startDate
        case originalUUID = "originalUuid"
        case originalNameEn, stagedModelType
        case url = "URL"
        case modelClassName, programStartTime
        case originalEventID = "originalEventId"
        case currency, startTime, descriptionUr, attributeGetterFunctions, expandoBridge, createDate, coordinates, entityCacheEnabled, userName
        case userID = "userId"
        case originalCompanyID = "originalCompanyId"
        case escapedModel, primaryKeyObj
        case originalGroupID = "originalGroupId"
        case imagesUr, urIsSubmitted, endTime, enIsSubmitted, programEndTime, primaryKey
    }
}

// MARK: - Attribute
struct Attribute: Codable {
}

// MARK: - ExpandoBridge
struct ExpandoBridge: Codable {
    let classPK, companyID: Int
    let attributeNames: String
    let indexEnabled: Bool
    let attributes: Attribute
    let className: String

    enum CodingKeys: String, CodingKey {
        case classPK
        case companyID = "companyId"
        case attributeNames, indexEnabled, attributes, className
    }
}

// MARK: - ModelAttributes
struct ModelAttributes: Codable {
    let imagesEn: String
    let endDate: String
    let groupID: Int
    let imagesAr, uuid: String
    let url: String
    let programStartTime, price, currency, startTime: String
    let descriptionUr, createDate: String
    let eventID: Int
    let descriptionEn, nameAr: String
    let finderCacheEnabled: Bool
    let timing, coordinates, descriptionAr: String
    let entityCacheEnabled: Bool
    let nameEn, userName: String
    let userID: Int
    let arIsSubmitted: String
    let companyID: Int
    let imagesUr, nameUr, urIsSubmitted, modifiedDate: String
    let endTime, enIsSubmitted, startDate, programEndTime: String

    enum CodingKeys: String, CodingKey {
        case imagesEn, endDate
        case groupID = "groupId"
        case imagesAr, uuid
        case url = "URL"
        case programStartTime, price, currency, startTime, descriptionUr, createDate
        case eventID = "eventId"
        case descriptionEn, nameAr, finderCacheEnabled, timing, coordinates, descriptionAr, entityCacheEnabled, nameEn, userName
        case userID = "userId"
        case arIsSubmitted
        case companyID = "companyId"
        case imagesUr, nameUr, urIsSubmitted, modifiedDate, endTime, enIsSubmitted, startDate, programEndTime
    }
}

// MARK: - StagedModelType
struct StagedModelType: Codable {
    let classSimpleName: String
    let referrerClassNameID: Int
    let className: String
    let classNameID: Int

    enum CodingKeys: String, CodingKey {
        case classSimpleName
        case referrerClassNameID = "referrerClassNameId"
        case className
        case classNameID = "classNameId"
    }
}
