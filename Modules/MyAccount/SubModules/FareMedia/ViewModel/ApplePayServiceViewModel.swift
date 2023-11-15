//
//  ApplePayServiceViewModel.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 11/05/23.
//

import Foundation
import Alamofire
import UIKit

struct ApplePayServiceViewModel {
    private let service: ServiceManager
    
    init(service: ServiceManager = .sharedInstance) {
        self.service = service
    }
    
    func initiateTransaction(productId: Int, isFirstClass: Bool, paymentMethod: String, cardDevicePaymentToken: String? = nil, completion: @escaping (Result<TransactionStartResponse, FareMediaError>) -> Void) {
        
        let endpoint = EndPoint(baseUrl: .journeyPlanner,
                                methodName: URLs.fareMediaTransactionStart + "?mediatypeid=barcode",
                                method: .post,
                                encoder: JSONParameterEncoder.default)
        let requestParameters = ApplePayTransactionStartRequest(productId: productId,
                                                        firstClass: isFirstClass,
                                                        paymentMethodTypeId: paymentMethod,
                                                        loadStartDate: "", cardDevicePaymentToken: cardDevicePaymentToken)
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
    
    func getTransactionByID(transactionId: Int, completion: @escaping (Result<GetTransactionResponseModel, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner,
                                methodName: URLs.getTransactionByID + "?mediatypeid=barcode&paymenttransactionid=" + transactionId.string,
                                method: .get,
                                encoder: JSONParameterEncoder.default)
        let requestParameters = DefaultParameters()
        do {
            let headers = try AFCAPIHeaders.generateAuthenticated()
            
            let str = "endPoint : \(endpoint) ,Header : \(headers)"
            alertMessagePaymentFailledDebugOnly(message: str)
            service.withRequest(endPoint: endpoint,
                                parameters: requestParameters,
                                headers: headers,
                                resultData: GetTransactionResponseModel.self) { (result) in
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
    
    func reAttemptApplePayTopUp(transactionId: Int, completion: @escaping (Result<GetTransactionResponseModel, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner,
                                methodName: URLs.getTransactionByID + "?mediatypeid=barcode&paymenttransactionid=" + transactionId.string,
                                method: .get,
                                encoder: JSONParameterEncoder.default)
        let requestParameters = DefaultParameters()
        do {
            let headers = try AFCAPIHeaders.generateAuthenticated()
            service.withRequest(endPoint: endpoint,
                                parameters: requestParameters,
                                headers: headers,
                                resultData: GetTransactionResponseModel.self) { (result) in
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
    
    
    func alertMessagePaymentFailledDebugOnly(message:String)  {
        DispatchQueue.main.async {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let alert = UIAlertController.init(title: "Test", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            appdelegate.window?.rootViewController?.present(alert, animated: true)
            
        }
    }
}

struct ApplePayTransactionStartRequest: Encodable {
    let productId: Int
    let firstClass: Bool
    let paymentMethodTypeId: String
    let loadStartDate: String
    let cardDevicePaymentToken: String?
}

enum applePayTransactionStatus:String{
    
            case applePayPaid = "Apple Pay Paid"
            case applePayError = "Apple Pay Top Up Error"
            case applePayDone = "Apple Pay Top Up Done"
    
}

