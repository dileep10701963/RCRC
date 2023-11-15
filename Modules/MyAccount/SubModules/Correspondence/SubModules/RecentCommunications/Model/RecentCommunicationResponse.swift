//
//  RecentCommunicationResponse.swift
//  RCRC
//
//  Created by Saheba Juneja on 16/09/22.
//

import Foundation

// MARK: - RecentCommunicationResponseModel
struct RecentCommunicationResponseModel: Codable {
    let items: [Item]?
}

// MARK: - Item
struct Item: Codable {
    let srsubType, srNumber, serviceRequestType, itemDescription: String?
    let sRSubType, area, status, comments: String?
    
    init() {
        srsubType = ""
        srNumber = ""
        serviceRequestType = ""
        itemDescription = ""
        sRSubType = ""
        area = ""
        status = ""
        comments = ""
    }

    enum CodingKeys: String, CodingKey {
        case srsubType, srNumber, serviceRequestType
        case itemDescription = "description"
        case sRSubType, area, status, comments
    }
}
