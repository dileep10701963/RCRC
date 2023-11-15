//
//  BusModel.swift
//  RCRC
//
//  Created by Aashish Singh on 27/10/22.
//

import Foundation

// MARK: - BusModel
struct BusModel: Codable {
    let actions: BusModelActions?
    let items: [BusItem]?
    let lastPage, page, pageSize, totalCount: Int?
    var pdfData: Data? = nil
}

// MARK: - BusModelActions
struct BusModelActions: Codable {
    let actionsGet: BusContentGet?

    enum CodingKeys: String, CodingKey {
        case actionsGet = "get"
    }
}

// MARK: - BusContentGet
struct BusContentGet: Codable {
    let method, href: String?
}

// MARK: - BusItem
struct BusItem: Codable {
    let actions: BusItemActions?
    let availableLanguages: [String]?
    let contentFields: [ContentField]?
    let contentStructureID: Int?
    let creator: BusContentCreator?
    let dateCreated, dateModified, datePublished: String?
    let itemDescription, friendlyURLPath: String?
    let id: Int?
    let key: String?
    let numberOfComments: Int?
    let renderedContents: [BusRenderedContent]?
    let siteID: Int?
    let subscribed: Bool?
    let title, uuid: String?

    enum CodingKeys: String, CodingKey {
        case actions, availableLanguages, contentFields
        case contentStructureID = "contentStructureId"
        case creator, dateCreated, dateModified, datePublished
        case itemDescription = "description"
        case friendlyURLPath = "friendlyUrlPath"
        case id, key, numberOfComments, renderedContents
        case siteID = "siteId"
        case subscribed, title, uuid
    }
}

// MARK: - BusItemActions
struct BusItemActions: Codable {
    let getRenderedContent, subscribe, unsubscribe, actionsGet: BusContentGet?
    let replace, update, delete: BusContentGet?

    enum CodingKeys: String, CodingKey {
        case getRenderedContent = "get-rendered-content"
        case subscribe, unsubscribe
        case actionsGet = "get"
        case replace, update, delete
    }
}

// MARK: - ContentField
struct ContentField: Codable {
    let contentFieldValue: ContentFieldContentFieldValue?
    let dataType, inputControl, label, name: String?
    let nestedContentFields: [ContentFieldNestedContentField]?
    let repeatable: Bool?
}

// MARK: - ContentFieldContentFieldValue
struct ContentFieldContentFieldValue: Codable {
    let data: String?
}

// MARK: - ContentFieldNestedContentField
struct ContentFieldNestedContentField: Codable {
    let contentFieldValue: ContentFieldContentFieldValue?
    let dataType, inputControl, label, name: String?
    let nestedContentFields: [PurpleNestedContentField]?
    let repeatable: Bool?
}

// MARK: - PurpleNestedContentField
struct PurpleNestedContentField: Codable {
    let contentFieldValue: ContentFieldContentFieldValue?
    let dataType, inputControl, label, name: String?
    let nestedContentFields: [FluffyNestedContentField]?
    let repeatable: Bool?
}

// MARK: - FluffyNestedContentField
struct FluffyNestedContentField: Codable {
    let contentFieldValue: PurpleContentFieldValue?
    let dataType, label, name: String?
    let repeatable: Bool?
}

// MARK: - PurpleContentFieldValue
struct PurpleContentFieldValue: Codable {
    let document: Document?
}

// MARK: - Document
struct Document: Codable {
    let contentType, contentURL, documentDescription, encodingFormat: String?
    let fileExtension: String?
    let id, sizeInBytes: Int?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case contentType
        case contentURL = "contentUrl"
        case documentDescription = "description"
        case encodingFormat, fileExtension, id, sizeInBytes, title
    }
}

// MARK: - BusContentCreator
struct BusContentCreator: Codable {
    let additionalName, contentType, familyName, givenName: String?
    let id: Int?
    let name: String?
}

// MARK: - BusRenderedContent
struct BusRenderedContent: Codable {
    let renderedContentURL: String?
    let templateName: String?
}
