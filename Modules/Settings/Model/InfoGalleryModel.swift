//
//  InfoGalleryModel.swift
//  RCRC
//
//  Created by Aashish Singh on 21/02/23.
//

import Foundation
import UIKit

struct InfoGalleryModel: Codable {
    let items: [InfoGalleryItem]?
}

// MARK: - Get
struct InfoGalleryGet: Codable {
    let method, href: String?
}

// MARK: - Item
struct InfoGalleryItem: Codable {
    let contentFields: [InfoGalleryContentField]?

    enum CodingKeys: String, CodingKey {
        case contentFields
    }
}

// MARK: - ContentField
struct InfoGalleryContentField: Codable {
    let contentFieldValue: ContentFieldContentFieldValue?
    let dataType, inputControl, label, name: String?
    let nestedContentFields: [InfoGalleryNestedContentField]?
    let repeatable: Bool
}

// MARK: - ContentFieldContentFieldValue
struct InfoGalleryContentFieldContentFieldValue: Codable {
    let data: String?
}

// MARK: - NestedContentField
struct InfoGalleryNestedContentField: Codable {
    let contentFieldValue: NestedContentFieldContentFieldValue?
    let dataType, label, name: String?
    let repeatable: Bool
}

// MARK: - NestedContentFieldContentFieldValue
struct NestedContentFieldContentFieldValue: Codable {
    let image: Image?
}

// MARK: - Image
struct Image: Codable {
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
