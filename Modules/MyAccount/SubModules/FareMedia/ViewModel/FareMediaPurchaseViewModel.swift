//
//  FareMediaPurchaseViewModel.swift
//  RCRC
//
//  Created by Errol on 29/07/21.
//

import Foundation
import Alamofire

struct FareMediaPurchaseViewModel {
    private let service: ServiceManager

    init(service: ServiceManager = .sharedInstance) {
        self.service = service
    }

    func initiateTransaction(productId: Int, isFirstClass: Bool, paymentMethod: String, completion: @escaping (Result<TransactionStartResponse, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner,
                                methodName: URLs.fareMediaTransactionStart + "?mediatypeid=barcode",
                                method: .post,
                                encoder: JSONParameterEncoder.default)
        let requestParameters = TransactionStartRequest(productId: productId,
                                                        firstClass: isFirstClass,
                                                        paymentMethodTypeId: paymentMethod,
                                                        loadStartDate: "")
        do {
            let headers = try AFCAPIHeaders.generateAuthenticated()
            service.withRequest(endPoint: endpoint,
                                parameters: requestParameters,
                                headers: headers,
                                resultData: TransactionStartResponse.self) { (result) in
                switch result {
                case let .success(data):
                    completion(.success(data))
                case .failure:
                    completion(.failure(.connectivity))
                }
            }
        } catch {
            completion(.failure(.notLoggedIn))
        }
    }

    func updateTransaction(resultIndicator: String, transactionId: Int, completion: @escaping (Result<TransactionStatusResponse, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner,
                                methodName: URLs.fareMediaTransactionUpdate + "?mediatypeid=barcode&paymenttransactionid=" + transactionId.string,
                                method: .put,
                                encoder: JSONParameterEncoder.default)
        let requestParameters = TransactionStatusRequest(resultIndicator: resultIndicator)
        do {
            let headers = try AFCAPIHeaders.generateAuthenticated()
            service.withRequest(endPoint: endpoint,
                                parameters: requestParameters,
                                headers: headers,
                                resultData: TransactionStatusResponse.self) { (result) in
                switch result {
                case let .success(data):
                    completion(.success(data))
                case .failure:
                    completion(.failure(.connectivity))
                }
            }
        } catch {
            completion(.failure(.notLoggedIn))
        }
    }
}
