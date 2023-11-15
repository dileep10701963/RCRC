//
//  FareMediaBarcodeViewModel.swift
//  RCRC
//
//  Created by Errol on 29/07/21.
//

import Foundation
import Alamofire

struct FareMediaBarcodeViewModel {
    private let service: ServiceManager
    private let product: FareMediaPurchasedProduct

    var productName: String {
        return product.profileName ?? ""
    }

    var productTicketType: String {
        return product.name ?? ""
    }
    
    var productCost: String {
        if let productPrice = product.price {
            let price = (Int(productPrice) / 100)
            //let priceFormat = String(format: "%.2f", price).localized
            return "\(price)\(Constants.currencyTitle.localized)"
        } else {
            return "\(product.price?.string.localized ?? "")\(Constants.currencyTitle.localized)"
        }
    }

    var validity: String {
        return "\(calculateValidity())"
    }

    var title: String {
        if currentLanguage == .english {
            if let name = product.name, name.contains("Pass") {
                return ((product.name ?? ""))
            } else {
                return ((product.name ?? "") + " Pass")
            }
        } else {
            return ((product.name ?? ""))
        }
    }

    var barcodeRefreshInterval: DispatchTime {
        
        return DispatchTime.now() + 3
    }

    init(service: ServiceManager = .sharedInstance, product: FareMediaPurchasedProduct) {
        self.service = service
        self.product = product
    }

    private func calculateValidity() -> String {
//        let currentDate = Date()
//        let calendar = Calendar.current
//        let timeDifference = product.expiryTime ?? 0
//        let expiryDate = calendar.date(byAdding: .second, value: timeDifference, to: currentDate)
//        return expiryDate?.toString(withFormat: Constants.expiryDateFormat) ?? ""
        return product.endDate ?? ""
    }

    func getBarcodeData(completion: @escaping (Result<String, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner, methodName: URLs.fareMediaBarcode, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let requestParameters = FareMediaBarcodeRequest(mediaTypeId: Constants.barcodeType)
        do {
            let headers = try AFCAPIHeaders.generateAuthenticated()
            service.withRequest(endPoint: endpoint, parameters: requestParameters, headers: headers, resultData: BarcodeResponse.self) { (result) in
                switch result {
                case let .success(barcode):
                    if let rawBytes = barcode.rawBytes {
                        completion(.success(rawBytes))
                    } else {
                        completion(.failure(.invalidData))
                    }
                case .failure:
                    completion(.failure(.connectivity))
                }
            }
        } catch {
            completion(.failure(.invalidToken))
        }
    }
    
    func getBarcodes(completion: @escaping (Result<ETicket, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner, methodName: URLs.barcodeStack, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let requestParameters = FareMediaBarcodeRequest(mediaTypeId: Constants.barcodeType)
        do {
            let headers = try AFCAPIHeaders.generateAuthenticated()
            service.withRequest(endPoint: endpoint, parameters: requestParameters, headers: headers, resultData: ETicket.self) { (result) in
                switch result {
                case let .success(barcode):
                    if barcode.items != nil {
                        completion(.success(barcode))
                    } else {
                        completion(.failure(.invalidData))
                    }
                case .failure:
                    completion(.failure(.connectivity))
                }
            }
        } catch {
            completion(.failure(.invalidToken))
        }
    }
}
