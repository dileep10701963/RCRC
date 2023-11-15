//
//  BusTimeTableModel.swift
//  RCRC
//
//  Created by Aashish Singh on 04/11/22.
//

import Foundation

// MARK: - BusTimeTable
struct BusTimeTableModel: Codable {
    let items: [BusTimeTableItem]?
    let lastPage, page, pageSize, totalCount: Int?
}

// MARK: - BusTimeTableItem
struct BusTimeTableItem: Codable {
    let actions: BusTimeTableItemActions?
    let availableLanguages: [String]?
    let contentFields: [ContentField]?
    let contentStructureID: Int?
    let dateCreated, dateModified, datePublished: String?
    let itemDescription, friendlyURLPath: String?
    let id: Int?
    let key: String?
    let numberOfComments: Int?
    let renderedContents: [TimeTableRenderedContent]?
    let siteID: Int?
    let subscribed: Bool?
    let title, uuid: String?

    enum CodingKeys: String, CodingKey {
        case actions, availableLanguages, contentFields
        case contentStructureID = "contentStructureId"
        case dateCreated, dateModified, datePublished
        case itemDescription = "description"
        case friendlyURLPath = "friendlyUrlPath"
        case id, key, numberOfComments, renderedContents
        case siteID = "siteId"
        case subscribed, title, uuid
    }
}

// MARK: - BusTimeTableItemActions
struct BusTimeTableItemActions: Codable {
    let getRenderedContent, subscribe, unsubscribe, actionsGet: TimeTableGet?
    let replace, update, delete: TimeTableGet?

    enum CodingKeys: String, CodingKey {
        case getRenderedContent = "get-rendered-content"
        case subscribe, unsubscribe
        case actionsGet = "get"
        case replace, update, delete
    }
}

// MARK: - TimeTableGet
struct TimeTableGet: Codable {
    let method, href: String?
}

// MARK: - BusTimeTableContentField
struct BusTimeTableContentField: Codable {
    let contentFieldValue: TimeTableContentFieldValue?
    let dataType: TimeTableDataType?
    let inputControl: InputControl?
    let label, name: String?
    let nestedContentFields: [ContentField]?
    let repeatable: Bool?
}

// MARK: - ContentFieldValue
struct TimeTableContentFieldValue: Codable {
    let data: String?
}

enum TimeTableDataType: String, Codable {
    case string = "string"
}

enum InputControl: String, Codable {
    case text = "text"
    case textarea = "textarea"
}

// MARK: - RenderedContent
struct TimeTableRenderedContent: Codable {
    let renderedContentURL: String?
    let templateName: String?
}
