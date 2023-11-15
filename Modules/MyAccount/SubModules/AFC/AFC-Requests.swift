//
//  AFC-Requests.swift
//  RCRC
//
//  Created by Errol on 12/07/21.
//

import Foundation

struct TransactionStartRequest: Encodable {
    let productId: Int
    let firstClass: Bool
    let paymentMethodTypeId: String
    let loadStartDate: String
}

struct TransactionStatusRequest: Encodable {
    let resultIndicator: String
}

struct FareMediaBarcodeRequest: Encodable {
    let mediaTypeId: String

    enum CodingKeys: String, CodingKey {
        case mediaTypeId = "mediatypeid"
    }
}
