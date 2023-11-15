//
//  AddPaymentMethodHTMLSession.swift
//  RCRC
//
//  Created by Saheba Juneja on 13/10/22.
//

import Foundation

// MARK: - AddPaymentMethodHTMLSessionModel
struct AddPaymentMethodHTMLSessionModel: Codable {
    let html: String?
}

struct NewPaymentMethodRequest: Encodable {
    let bankCard: BankCardRequest
    let paymentMethodTypeID: String
    
    enum CodingKeys: String, CodingKey {
        case bankCard
        case paymentMethodTypeID = "paymentMethodTypeId"
    }
}
// MARK: - BankCard
struct BankCardRequest: Encodable {
    let sessionID, comments: String

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case comments
    }
}

// MARK: - AddPaymentMethodHTMLSessionModel
struct AddNewCardResponseModel: Codable {
    let bankCard: BankCardResponse?
}

// MARK: - BankCard
struct BankCardResponse: Codable {
    let sessionID, comments: String?
    let paymentMethodID: Int?

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case comments
        case paymentMethodID = "paymentMethodId"
    }
}

