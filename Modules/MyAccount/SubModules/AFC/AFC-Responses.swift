//
//  AFC-Responses.swift
//  RCRC
//
//  Created by Errol on 12/07/21.
//

import Foundation

// MARK: - Fare Media Types
struct FareMediaTypes: Decodable {
    let items: [FareMediaType]
}

struct FareMediaType: Decodable {
    let id: String
    let name: String
}

// MARK: - Payment Methods
struct PaymentMethods: Decodable {
    let items: [PaymentMethod]
}

struct PaymentMethod: Decodable {
    let id: String
    let name: String
}

// MARK: - Products list
struct ProductsList: Decodable {
    // Success
    let items: [ProductItem]?
    // Failure
    let message: String?
}

struct ProductItem: Decodable {
    let productData: ProductData
    let numberOfGroupPassengers: Int
    let categories: [ProductCategory]
}

struct ProductData: Decodable {
    let code: Int
    let name: String
}

struct ProductCategory: Decodable {
    let productData: ProductCategoryData
}

struct ProductCategoryData: Decodable {
    let typeCat: String
    let price: Int
}

enum ProductCategoryType: String, Decodable {
    case firstClass = "FIRST_CLASS"
    case regularClass = "REGULAR_CLASS"
    
    var displayName: String {
        switch self {
        case .firstClass:
            return "First Class"
        case .regularClass:
            return "Regular Class"
        }
    }
}

// MARK: - Payment Transaction Start
struct TransactionStartResponse: Decodable {
    // Success
    let paymentTransactionId: Int?
    let html: String?
    // Failure
    let message: String?
}

// MARK: - Payment Transaction Status
struct TransactionStatusResponse: Decodable {
    let error: Bool?
    let message: String?
}

// MARK: Payment Transactions List
struct TransactionsList: Decodable {
    // Success
    let items: [TransactionItem]?
    // Failure
    let message: String?
}

struct TransactionItem: Decodable {
    // Success
    let id: Int?
    let htmlGiven: String?
    let idProduct: String?
    let firstClass: Bool?
    let status: String?
    let creationDate: String?
    // Failure
    let message: String?
}

// MARK: - Fare Media Integrated - Purchased and Available
struct FareMediaIntegrated: Decodable {
    // Success
    let availableProducts: [AvailableProduct]?
    let purchasedProducts: [PurchasedProduct]?
    // Failure
    let error: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case availableProducts = "productAvailable"
        case purchasedProducts = "purchasedProduct"
        case error, message
    }
}

struct AvailableProduct: Decodable {
    // Success
    let productData: ProductData?
    let paymentMethods: [String]?
    let numberOfGroupPassengers: Int?
    let categories: [ProductCategory]?
    // Failure
    let error: Bool?
    let message: String?
}

struct PurchasedProduct: Decodable {
    // Success
    let locale: String?
    let productList: [ProductList]?
    let headData: HeadData?
    // Failure
    let error: Bool?
    let message: String?
}

struct HeadData: Decodable {
    let serialNumber: String?
    let profileName: String?
}

struct ProductList: Decodable {
    let productCode: Int
    let name, startDate, endDate, purchaseDate: String
    let productStatus: String
    let productStatusInt, price: Int
    let autoreload: Bool
    let expiryTime: Int
    let fareClass: Int
    let validityTime: Int
}

// MARK: - Account Barcode
struct BarcodeResponse: Decodable {
    let rawBytes: String?
    let error: Bool?
    let message: String?
}

// MARK: - Payment Status
enum PaymentStatus: String {
    case success = "www.mts_success.com"
    case failure = "www.mts_error.com"
    case cancelled = "www.mts_cancel.com"
}
