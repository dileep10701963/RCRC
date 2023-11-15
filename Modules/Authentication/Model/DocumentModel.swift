//
//  DocumentModel.swift
//  RCRC
//
//  Created by Aashish Singh on 13/07/22.
//

import Foundation

struct DocumentTypeResponseModel: Decodable {
    var items: [ItemsDecodable]
}

struct ItemsDecodable: Decodable {
    var id: String?
    var name: String?
}
