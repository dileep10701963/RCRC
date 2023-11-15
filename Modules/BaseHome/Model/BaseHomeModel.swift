//
//  BaseHomeModel.swift
//  RCRC
//
//  Created by Aashish Singh on 23/03/23.
//

import Foundation

// MARK: - BaseHomeModel
struct BaseHomeModel: Codable {
    let items: [BaseHomeItem]?
}

// MARK: - Get
struct BaseHomeGet: Codable {
    let method, href: String?
}

// MARK: - Item
struct BaseHomeItem: Codable {
    let actions: BaseHomeItemActions?
    let availableLanguages: [String]?
    let contentFields: [BaseHomeContentField]?
    let contentStructureID: Int?
    let dateCreated, dateModified, datePublished: String?
    let description, friendlyURLPath: String?
    let id: Int?
    let key: String?
    let numberOfComments: Int?
    let siteID: Int?
    let subscribed: Bool?
    let title, uuid: String?

    enum CodingKeys: String, CodingKey {
        case actions, availableLanguages, contentFields
        case contentStructureID = "contentStructureId"
        case dateCreated, dateModified, datePublished, description
        case friendlyURLPath = "friendlyUrlPath"
        case id, key, numberOfComments
        case siteID = "siteId"
        case subscribed, title, uuid
    }
}

// MARK: - ItemActions
struct BaseHomeItemActions: Codable {
    let getRenderedContent, subscribe, unsubscribe, actionsGet: BaseHomeGet?
    let replace, update, delete: BaseHomeGet?

    enum CodingKeys: String, CodingKey {
        case getRenderedContent = "get-rendered-content"
        case subscribe, unsubscribe
        case actionsGet = "get"
        case replace, update, delete
    }
}

// MARK: - ContentField
struct BaseHomeContentField: Codable {
    let contentFieldValue: BaseHomeContentFieldValue?
    let dataType, label, name: String?
    let repeatable: Bool?
}

// MARK: - ContentFieldValue
struct BaseHomeContentFieldValue: Codable {
    let document: BaseHomeDocument?
}

// MARK: - Document
struct BaseHomeDocument: Codable {
    let contentType, contentURL, description, encodingFormat: String?
    let fileExtension: String?
    let id, sizeInBytes: Int?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case contentType
        case contentURL = "contentUrl"
        case description, encodingFormat, fileExtension, id, sizeInBytes, title
    }
}
