//
//  ContactModel.swift
//  RCRC
//
//  Created by Errol on 06/04/21.
//

import Foundation

// MARK: - ContactModel
struct ContactModel: Decodable {
    let actions: ContactActions?
    let items: [ContactItem?]
    let lastPage, page, pageSize, totalCount: Int?
}

// MARK: - Actions
struct ContactActions: Decodable {
    let actionsGet: Get?

    enum CodingKeys: String, CodingKey {
        case actionsGet = "get"
    }
}

// MARK: - Get
struct Get: Decodable {
    let method, href: String?
}

// MARK: - Item
struct ContactItem: Decodable {
    let actions: ItemActions?
    let availableLanguages: [String?]
    let contentFields: [ContactContentField?]
    let contentStructureID: Int?
    let creator: Creator?
    let dateCreated, dateModified, datePublished: String?
    let itemDescription, friendlyURLPath: String?
    let id: Int?
    let key: String?
    let numberOfComments: Int?
    let renderedContents: [RenderedContent?]
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

// MARK: - ItemActions
struct ItemActions: Decodable {
    let getRenderedContent, subscribe, unsubscribe, actionsGet: Get?
    let replace, update, delete: Get?

    enum CodingKeys: String, CodingKey {
        case getRenderedContent = "get-rendered-content"
        case subscribe, unsubscribe
        case actionsGet = "get"
        case replace, update, delete
    }
}

// MARK: - ContentField
struct ContactContentField: Decodable {
    let contentFieldValue: ContentFieldValue?
    let dataType, inputControl, label, name: String?
    let repeatable: Bool?
}

// MARK: - ContentFieldValue
struct ContentFieldValue: Codable {
    let data: String?
}

// MARK: - Creator
struct Creator: Decodable {
    let additionalName, contentType, familyName, givenName: String?
    let id: Int?
    let name: String?
}

// MARK: - RenderedContent
struct RenderedContent: Decodable {
    let renderedContentURL: String?
    let templateName: String?
}

let suggestionFeedback = [IncidentLostFoundData(category: "Options", subCategory: ["General", "Transport Card", "Public Transport Services", "Bus", "Metro", "Facility management", "Others"])]
