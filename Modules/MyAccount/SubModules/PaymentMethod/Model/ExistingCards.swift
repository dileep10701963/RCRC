//
//  ExistingCards.swift
//  RCRC
//
//  Created by Saheba Juneja on 12/10/22.
//

import Foundation
// MARK: - AllPaymentMethod
struct AllPaymentMethod: Codable {
    let items: [ExistingCardItem]?
}

// MARK: - Item
struct ExistingCardItem: Codable {
    let paymentMethodTypeID: String?
    let bankCard: BankCard?

    enum CodingKeys: String, CodingKey {
        case paymentMethodTypeID = "paymentMethodTypeId"
        case bankCard
    }
}

// MARK: - BankCard
struct BankCard: Codable {
    let paymentMethodID: Int?
    let maskedCardNumber: String?

    enum CodingKeys: String, CodingKey {
        case paymentMethodID = "paymentMethodId"
        case maskedCardNumber
    }
}
