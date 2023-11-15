

import Foundation

// MARK: - KAPTInfoModel
struct KAPTInfoModel: Codable {
    let items: [KAPTItem]?
}

// MARK: - Get
struct KAPTGet: Codable {
    let method: String?
    let href: String?
}

// MARK: - Item
struct KAPTItem: Codable {
    let actions: KAPTItemActions?
    let availableLanguages: [String]?
    let contentFields: [KAPTContentField]?
    let contentStructureID: Int?
    let creator: KAPTCreator?
    let dateCreated, dateModified: String?
    let itemDescription, friendlyURLPath: String?
    let id: Int?
    let key: String?
    let numberOfComments: Int?
    let renderedContents: [KAPTRenderedContent]?
    let siteID: Int?
    let subscribed: Bool?
    let title, uuid: String?

    enum CodingKeys: String, CodingKey {
        case actions, availableLanguages, contentFields
        case contentStructureID = "contentStructureId"
        case creator, dateCreated, dateModified
        case itemDescription = "description"
        case friendlyURLPath = "friendlyUrlPath"
        case id, key, numberOfComments, renderedContents
        case siteID = "siteId"
        case subscribed, title, uuid
    }
}

// MARK: - KAPTItemActions
struct KAPTItemActions: Codable {
    let getRenderedContent, subscribe, unsubscribe, actionsGet: KAPTGet?
    let replace, update, delete: KAPTGet?

    enum CodingKeys: String, CodingKey {
        case getRenderedContent = "get-rendered-content"
        case subscribe, unsubscribe
        case actionsGet = "get"
        case replace, update, delete
    }
}

// MARK: - KAPTContentField
struct KAPTContentField: Codable {
    let contentFieldValue: KAPTContentFieldValue?
    let dataType, inputControl, label, name: String?
    let repeatable: Bool?
    let nestedContentFields: [KAPTNestedContentField]?
}

// MARK: - KAPTContentFieldValue
struct KAPTContentFieldValue: Codable {
    let data: String?
    let image: KAPTImage?
}

// MARK: - KAPTCreator
struct KAPTCreator: Codable {
    let additionalName, contentType, familyName, givenName: String?
    let id: Int?
    let name: String?
}

// MARK: - KAPTRenderedContent
struct KAPTRenderedContent: Codable {
    let renderedContentURL: String?
    let templateName: String?
}

// MARK: - KAPTImage
struct KAPTImage: Codable {
    let contentType, contentURL, imageDescription, encodingFormat: String?
    let fileExtension: String?
    let id, sizeInBytes: Int?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case contentType
        case contentURL = "contentUrl"
        case imageDescription = "description"
        case encodingFormat, fileExtension, id, sizeInBytes, title
    }
}

// MARK: - KAPTNestedContentField
struct KAPTNestedContentField: Codable {
    let contentFieldValue: KAPTNestedContentFieldContentFieldValue?
    let dataType: KAPTDataType?
    let inputControl: KAPTInputControl?
    let label: Label?
    let name: Name?
    let nestedContentFields: [KAPTNestedContentField]?
    let repeatable: Bool?
}

enum KAPTDataType: String, Codable {
    case image = "image"
    case string = "string"
}

enum KAPTInputControl: String, Codable {
    case text = "text"
    case textarea = "textarea"
}

// MARK: - KAPTNestedContentFieldContentFieldValue
struct KAPTNestedContentFieldContentFieldValue: Codable {
    let data: String
}

enum Label: String, Codable {
    case imageDescription = "image description"
    case imageTitle = "Image Title"
}

enum Name: String, Codable {
    case imageDescription = "imageDescription"
    case imageTitle = "imageTitle"
}
