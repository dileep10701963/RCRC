//
//  FareMediaViewModel.swift
//  RCRC
//
//  Created by anand madhav on 09/03/21.
//

import Foundation
import Alamofire

enum TicketType {
    case twoHour, threeDays, sevenDays, thirtyDays, nDays
}

struct FareMediaViewModel {
    private let service: ServiceManager

    init(service: ServiceManager = .sharedInstance) {
        self.service = service
    }

    func getPurchasedAndAvailableFareMedia(completion: @escaping (Result<FareMediaProducts, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner, methodName: URLs.fareMediaIntegrated, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let requestParameters = DefaultParameters()
        do {
            let headers = try AFCAPIHeaders.generateAuthenticated()
            service.withRequest(endPoint: endpoint, parameters: requestParameters, headers: headers, resultData: FareMediaIntegrated.self) { (result) in
                
                switch result {
                    
                case let .success(fareMedia):
                    
                    let invalidCredentials = "Invalid Credentials"
                    if fareMedia.message?.lowercased() == invalidCredentials.lowercased() {
                        completion(.failure(.invalidToken))
                    } else if isTokenExpired(fareMedia) {
                        completion(.failure(.invalidToken))
                    } else if fareMedia.error == Constants.true {
                        completion(.failure(.invalidData))
                    } else if fareMedia.availableProducts?.first?.error == true &&
                                fareMedia.purchasedProducts?.first?.error == true {
                        completion(.failure(.invalidToken))
                    } else {
                        completion(.success(mapFareMediaProducts(fareMedia)))
                    }
                case .failure:
                    
                    completion(.failure(.connectivity))
                    
                }
            }
        } catch {
            completion(.failure(.notLoggedIn))
        }
    }

    private func mapFareMediaProducts(_ data: FareMediaIntegrated) -> FareMediaProducts {
        if data.availableProducts?.first?.error == true, data.purchasedProducts?.first?.error == true {
            return FareMediaProducts(availableProducts: [], purchasedProducts: [])
        } else if data.availableProducts?.first?.error == true,
                  let purchasedProductsData = data.purchasedProducts {
            let purchasedProducts = mapPurchasedProducts(purchasedProductsData)
            return .init(availableProducts: [], purchasedProducts: purchasedProducts)
        } else if data.purchasedProducts?.first?.error == true,
                  let availableProductsData = data.availableProducts {
            let availableProducts = mapAvailableProducts(availableProductsData)
            return .init(availableProducts: availableProducts, purchasedProducts: [])
        } else if let availableProductsData = data.availableProducts,
                  let purchasedProductsData = data.purchasedProducts {
            let availableProducts = mapAvailableProducts(availableProductsData)
            let purchasedProducts = mapPurchasedProducts(purchasedProductsData)
            return .init(availableProducts: availableProducts, purchasedProducts: purchasedProducts)
        } else {
            return .init(availableProducts: [], purchasedProducts: [])
        }
    }

    private func mapAvailableProducts(_ availableProductsData: [AvailableProduct]) -> [FareMediaAvailableProduct] {
        return availableProductsData.compactMap { product in
            product.categories?.map { element -> FareMediaAvailableProduct in
                return .init(name: product.productData?.name,
                             code: product.productData?.code,
                             paymentMethods: product.paymentMethods,
                             numberOfGroupPassengers: product.numberOfGroupPassengers,
                             productCategory: ProductCategoryType(rawValue: element.productData.typeCat),
                             price: element.productData.price)
            }
        }.flatMap { $0 }
    }

    private func mapPurchasedProducts(_ purchasedProductsData: [PurchasedProduct]) -> [FareMediaPurchasedProduct] {
        return purchasedProductsData.compactMap { product in
            product.productList?.map { element -> FareMediaPurchasedProduct in
                return .init(locale:product.locale,
                             profileName: product.headData?.profileName,
                             serialNumber: product.headData?.serialNumber,
                             code: element.productCode,
                             name: element.name,
                             startDate: element.startDate,
                             endDate: element.endDate,
                             purchaseDate: element.purchaseDate,
                             productStatus: element.productStatus,
                             productStatusInt: element.productStatusInt,
                             price: element.price,
                             autoreload: element.autoreload,
                             expiryTime: element.expiryTime,
                             fareClass: element.fareClass, validityTime: element.validityTime)
            }
        }.flatMap { $0 }
    }

    private func isTokenExpired(_ data: FareMediaIntegrated) -> Bool {
        return (data.error == Constants.true &&
                (data.message?.lowercased().contains("session has expired".lowercased()) ?? false
                 || data.message?.lowercased().contains("Authentication incorrect".lowercased()) ?? false))
        || (data.availableProducts?.first?.error == true &&
            (data.availableProducts?.first?.message?.lowercased().contains("session has expired".lowercased()) ?? false
             || data.availableProducts?.first?.message?.lowercased().contains("Authentication incorrect".lowercased()) ?? false))
        || (data.purchasedProducts?.first?.error == true &&
            (data.purchasedProducts?.first?.message?.lowercased().contains("session has expired".lowercased()) ?? false
             || data.purchasedProducts?.first?.message?.lowercased().contains("Authentication incorrect".lowercased()) ?? false))
    }
    
     func activateProduct(mediaTypeId:String, productId:Int, endpoint: String = URLs.activateProduct, completionHandler : @escaping (NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .activateProduct, methodName: URLs.activateProduct + "?mediaTypeId=\(mediaTypeId)&productid=\(productId)", method: .post, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: ErrorResponseModel.self) { result in
            print("Result", result)
            switch result {
            case .success((let data, _)):
                if let response = data, response.message == "success" {
                    completionHandler(.caseIgnore)
                }
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(errr)
            }
        }
    }
    
    func getProductTypeUsingExpirationTIme(expirationTime: Int) -> TicketType {
        switch expirationTime {
        case 120:
            return .twoHour
        case 4320:
            return .threeDays
        case 10080:
            return .sevenDays
        case 43200:
            return .thirtyDays
        default:
            return .nDays
        }
    }
}
