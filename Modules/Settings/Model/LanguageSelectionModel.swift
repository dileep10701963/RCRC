//
//  LanguageSelectionModel.swift
//  RCRC
//
//  Created by Aashish Singh on 17/02/23.
//

import Foundation

// MARK: - Welcome
struct LanguageSelectionModel: Codable {
    let items: [LanguageSelectionItem]?
}
// MARK: - Get
struct LSGet: Codable {
    let method, href: String?
}

// MARK: - Item
struct LanguageSelectionItem: Codable {
    let contentFields: [LSContentField]?
    enum CodingKeys: String, CodingKey {
        case contentFields
    }
}

// MARK: - ContentField
struct LSContentField: Codable {
    let contentFieldValue: LSContentFieldValue?
    let dataType, label, name: String?
    let repeatable: Bool
}

// MARK: - ContentFieldValue
struct LSContentFieldValue: Codable {
    let data: String?
}


