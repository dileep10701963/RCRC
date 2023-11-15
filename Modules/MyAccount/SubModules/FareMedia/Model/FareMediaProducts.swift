//
//  FareMediaProducts.swift
//  RCRC
//
//  Created by Errol on 09/08/21.
//

import Foundation

struct FareMediaProducts {
    let availableProducts: [FareMediaAvailableProduct]
    let purchasedProducts: [FareMediaPurchasedProduct]
}

struct FareMediaAvailableProduct {
    let name: String?
    let code: Int?
    let paymentMethods: [String]?
    let numberOfGroupPassengers: Int?
    let productCategory: ProductCategoryType?
    let price: Int?
}

struct FareMediaPurchasedProduct {
    let locale: String?
    let profileName: String?
    let serialNumber: String?
    let code: Int?
    let name, startDate, endDate, purchaseDate: String?
    let productStatus: String?
    let productStatusInt, price: Int?
    let autoreload: Bool?
    let expiryTime: Int?
    let fareClass: Int?
    let validityTime: Int?
}


// MARK: - Welcome6
struct PurchaseHistoryResponseModel: Decodable {
    var items: [PurchaseHistoryModel]?
}

// MARK: - Item
struct PurchaseHistoryModel: Decodable {
    let transactionId, logSerialNumber: String?
    let recordDate: String?
    let agencyName: String?
    let agencyId: Int?
    let line: String?
    let lineId: Int?
    let station: String?
    let stationId, stationAreaId: String?
    let stationAreaName: String?
    let referenceId: String?
    let equipmentModel: String?
    let equipmentId: String?
    let universalSeq: Int?
    let operationNumber: String?
    let numProductRequested, numProductSucessfull: Int?
    let totalAmount, amountPaid, amountReturned, amountToReturn: Double?
    let paymentTypeName: String?
    let paymentAmount: Double?
    let operationTypeId: Int?
    let operationType: String?
    let mediumTemplate: String?
    let mediumType: String?
    let productType: String?
    let productTypeId: Int?
    let product, productId: String?
    var recordInDate: Date?
    
}
