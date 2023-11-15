//
//  GetTransactionResponseModel.swift
//  RCRC
//
//  Created by Aashish Singh on 16/11/22.
//

import Foundation

struct GetTransactionResponseModel: Codable {
    
    let id: Int?
    let htmlGiven: String?
    let idProduct: String?
    let firstClass: Bool?
    let status: GetTransactionStatus?
    let creationDate: String?
    let message: String?
    let loadStartDate: String?
    
}

enum GetTransactionStatus: Codable {
    case applePayPaid, applePayError, applePayDone
    case otherStatus(name: String)
    
    private enum RawValue: String, Codable {
        case applePayPaid = "Apple Pay Paid"
        case applePayError = "Apple Pay Top Up Error"
        case applePayDone = "Apple Pay Top Up Done"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedString = try container.decode(String.self)
        
        if let value = RawValue(rawValue: decodedString) {
            switch value {
            case .applePayPaid: self = .applePayPaid
            case .applePayError: self = .applePayError
            case .applePayDone: self = .applePayDone
            }
        } else {
            self = .otherStatus(name: decodedString)
        }
        
    }
}
