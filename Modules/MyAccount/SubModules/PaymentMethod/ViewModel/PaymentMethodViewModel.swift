//
//  PaymentMethodViewModel.swift
//  RCRC
//
//  Created by Saheba Juneja on 22/09/22.
//

import Foundation
import UIKit
import Alamofire

class PaymentMethodViewModel: NSObject {
    static let shared = PaymentMethodViewModel()
    var allPaymentMethod = AllPaymentMethod(items: nil)
    var addPaymentMethodHTMLSession = AddPaymentMethodHTMLSessionModel(html: "")
    var transactionStatusResponse = AddNewCardResponseModel(bankCard: nil)

    func fetchAllPaymentMehthod(endpoint: String = URLs.allPaymentMethod, completionHandler : @escaping (AllPaymentMethod, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .allPaymentMethod, methodName: URLs.allPaymentMethod, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: AllPaymentMethod.self) { result in
            switch result {
            case .success((let data, _)):
                self.allPaymentMethod = AllPaymentMethod(items: data?.items)
                completionHandler(self.allPaymentMethod, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.allPaymentMethod,errr)
            }
        }
    }
    
    func getAddPaymentMethodHTMLSession(endpoint: String = URLs.addPaymentMethodHTMLSession, completionHandler : @escaping (AddPaymentMethodHTMLSessionModel, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .addPaymentMethodHTMLSession, methodName: URLs.addPaymentMethodHTMLSession, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: AddPaymentMethodHTMLSessionModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.addPaymentMethodHTMLSession = AddPaymentMethodHTMLSessionModel(html: data?.html)
                completionHandler(self.addPaymentMethodHTMLSession, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.addPaymentMethodHTMLSession,errr)
            }
        }
    }
    
    func updateTransaction(resultIndicator: String, endpoint: String = URLs.addNewPaymentMethod, completionHandler : @escaping (AddNewCardResponseModel, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .addNewPaymentMethod, methodName: URLs.addNewPaymentMethod, method: .post, encoder: URLEncodedFormParameterEncoder.default)
        let parametr = ["paymentMethodTypeId": Constants.creditcard,
                        "bankCard":["sessionId": resultIndicator, "comments": Constants.comments]] as [String : Any]
        ServiceManager.sharedInstance.withRequestJSONEncoding(endPoint: endPoint, parameters: parametr, resultData: AddNewCardResponseModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.transactionStatusResponse = AddNewCardResponseModel(bankCard: data?.bankCard)
                completionHandler(self.transactionStatusResponse, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.transactionStatusResponse,errr)
            }
        }
    }
}

extension PaymentMethodViewModel: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return allPaymentMethod.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExistingCardTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
        cell.existingCardItem = allPaymentMethod.items?[indexPath.section] 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
