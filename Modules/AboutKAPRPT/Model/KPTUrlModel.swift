//
//  KPTUrlModel.swift
//  RCRC
//
//  Created by Aashish Singh on 22/12/22.
//

import Foundation


// MARK: - KPTUrlModel
struct KPTUrlModel: Codable {
    let items: [KAPTUrlItem]?
}

// MARK: - Get
struct KAPTUrlGet: Codable {
    let method, href: String?
}

// MARK: - Item
struct KAPTUrlItem: Codable {
    let friendlyURLPath: String?
    let renderedContents: [KAPTUrlRenderedContent]?
    let contentFields: [KAPTUrlContentField]?
    let siteID: Int?
    let title: String?
    let uuid: String?
    let availableLanguages: [String]?
    let dateCreated: String?
    let id: Int?
    let subscribed: Bool?
    let dateModified: String?
    let contentStructureID: Int?
    let numberOfComments: Int?
    let actions: KAPTUrlItemActions?
    let datePublished: String?
    let itemDescription: String?

    enum CodingKeys: String, CodingKey {
        case friendlyURLPath = "friendlyUrlPath"
        case renderedContents, contentFields
        case siteID = "siteId"
        case title, uuid, availableLanguages, dateCreated, id, subscribed, dateModified
        case contentStructureID = "contentStructureId"
        case numberOfComments, actions, datePublished
        case itemDescription = "description"
    }
}

// MARK: - ItemActions
struct KAPTUrlItemActions: Codable {
    let update, delete, getRenderedContent, actionsGet: KAPTUrlGet?
    let replace, unsubscribe, subscribe: KAPTUrlGet?

    enum CodingKeys: String, CodingKey {
        case update, delete
        case getRenderedContent = "get-rendered-content"
        case actionsGet = "get"
        case replace, unsubscribe, subscribe
    }
}

// MARK: - ContentField
struct KAPTUrlContentField: Codable {
    let dataType, inputControl: String?
    let nestedContentFields: [KAPTUrlContentField]?
    let repeatable: Bool?
    let label: String?
    let contentFieldValue: KAPTUrlContentFieldValue?
    let name: String?
}

// MARK: - ContentFieldValue
struct KAPTUrlContentFieldValue: Codable {
    let data: String?
}

// MARK: - KAPTUrlRenderedContent
struct KAPTUrlRenderedContent: Codable {
    let renderedContentURL: String?
    let templateName: String?
}
