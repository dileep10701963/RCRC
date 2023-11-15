//
//  FAQModel.swift
//  RCRC
//
//  Created by anand madhav on 17/08/20.
//

import Foundation

// MARK: - FAQ Model
struct FAQModel: Decodable {
    let actions: FAQActions?
    let items: [FAQItem]?
    let lastPage, page, pageSize, totalCount: Int?
}

// MARK: - FAQ Actions
struct FAQActions: Decodable {
    let actionsGet: Get?

    enum CodingKeys: String, CodingKey {
        case actionsGet = "get"
    }
}

// MARK: - Item
struct FAQItem: Decodable {
    let actions: FAQItemActions?
    let availableLanguages: [String]?
    let contentFields: [FAQContentField]?
    let contentStructureID: Int?
    let creator: FAQCreator?
    let dateCreated, dateModified, datePublished: String?
    let itemDescription, friendlyURLPath: String?
    let id: Int?
    let key: String?
    let numberOfComments: Int?
    let renderedContents: [FAQRenderedContent]?
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
struct FAQItemActions: Decodable {
    let getRenderedContent, subscribe, unsubscribe, actionsGet: Get?
    let replace, update, delete: Get?

    enum CodingKeys: String, CodingKey {
        case getRenderedContent = "get-rendered-content"
        case subscribe, unsubscribe
        case actionsGet = "get"
        case replace, update, delete
    }
}

// MARK: - NestedContentField
struct FAQNestedContentField: Decodable {
    let contentFieldValue: FAQContentFieldValue?
    let dataType, inputControl, label, name: String?
    let nestedContentFields: [FAQContentField]?
    let repeatable: Bool?
}

// MARK: - ContentField
struct FAQContentField: Decodable {
    let contentFieldValue: FAQContentFieldValue?
    let dataType, inputControl, label, name: String?
    let nestedContentFields: [FAQNestedContentField]?
    let repeatable: Bool?
}

// MARK: - ContentFieldValue
struct FAQContentFieldValue: Decodable {
    let data: String?
    let dataType: String?
    let label: String?
    let name: String?
}

// MARK: - Creator
struct FAQCreator: Decodable {
    let additionalName, contentType, familyName, givenName: String?
    let id: Int?
    let name: String?
}

// MARK: - RenderedContent
struct FAQRenderedContent: Decodable {
    let renderedContentURL: String?
    let templateName: String?
}
