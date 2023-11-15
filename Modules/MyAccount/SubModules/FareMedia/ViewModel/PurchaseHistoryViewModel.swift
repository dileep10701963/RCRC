//
//  PurchaseHistoryViewModel.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 04/05/23.
//

import Foundation
import UIKit
import Alamofire

protocol PurchaseHistoryDelegate: AnyObject {
    func openTableHeightConstraint()
    func closeTableHeightConstraint()
}

class PurchaseHistoryViewModel: NSObject {
    var selectedIndexPath: IndexPath?
    static let shared = PurchaseHistoryViewModel()
    var selectedSection: Int?
    var faremediaViewModel = FareMediaViewModel()
    var purchaseHistoryModel = PurchaseHistoryResponseModel(items: nil)//TravelHistory(items: nil)
    var searchPurchaseHistoryModel = PurchaseHistoryResponseModel(items: nil)//TravelHistory(items: nil)
    var purchaseHistoryTotalModel = PurchaseHistoryResponseModel(items: nil)//TravelHistory(items: nil)
    var delegate: PurchaseHistoryDelegate?
    
    func getSerialNumber(completionHandler : @escaping (String?, FareMediaError?) -> Void) {
        var serialNumber = ""
        faremediaViewModel.getPurchasedAndAvailableFareMedia { result in
            switch result {
            case let .success(fareMedia):
                serialNumber = fareMedia.purchasedProducts.map({$0.serialNumber ?? ""}).first ?? ""
                if !serialNumber.isEmpty {
                    completionHandler(serialNumber, nil)
                } else {
                    completionHandler(nil, .invalidData)
                }
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func purchaseHistory(endpoint: String = URLs.purchaseHistory, completionHandler : @escaping (PurchaseHistoryResponseModel?, FareMediaError?) -> Void) {
        
        getSerialNumber { serialNumber, error  in
            
            if let serialNumber = serialNumber {
                let endPoint = EndPoint(baseUrl: .purchaseHistory, methodName: URLs.purchaseHistory + "?mediaTypeId=\(Constants.barcodeType)&serialNumber=\(serialNumber)", method: .get, encoder: URLEncodedFormParameterEncoder.default)
                let parameters = DefaultParameters()
                ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: PurchaseHistoryResponseModel.self) { result in
                    print("Result", result)
                    switch result {
                    case .success((let data, _)):
                        let dataa = PurchaseHistoryResponseModel(items: data?.items)
                        if let item = dataa.items, item.count > 0 {
                            var itemData = item
                            for index in 0..<item.count {
                                let rDate = itemData[index].recordDate?.toDateLocalEn(timeZone: .AST)
                                let n1Date = rDate?.toString(timeZone: .AST)
                                print("n1Date: \(n1Date ?? "")")
                                itemData[index].recordInDate = rDate
                            }
                            itemData = itemData.filter({$0.recordInDate ?? Date() >= Date().subtracting(months: -1) ?? Date()})
                            print(itemData)
                            itemData.sort(){($0.recordInDate  ?? Date()) > ($1.recordInDate ?? Date())}
                            print(itemData)
                            
                            self.purchaseHistoryTotalModel = PurchaseHistoryResponseModel(items: itemData) //data?.items
                            self.loadPurchaseData()
                            self.searchPurchaseHistoryModel = PurchaseHistoryResponseModel(items: itemData)
                            print(self.searchPurchaseHistoryModel)
                            
                            completionHandler(self.purchaseHistoryModel, .none)
                        } else {
                            completionHandler(nil, .invalidData)
                        }
                    case .failure(let error):
                        print("Error-->", error)
                        completionHandler(nil, .invalidData)
                    }
                }
            } else {
                completionHandler(nil,error)
            }
        }
    }
    
    func loadPurchaseData() {
        
        if self.purchaseHistoryTotalModel.items?.count ?? 0 >= 5 {
            
            if let historyModel = self.purchaseHistoryTotalModel.items?[0..<5] {
                
                if let existingItem = self.purchaseHistoryModel.items, existingItem.count > 0 {
                    let finalItems = existingItem + historyModel
                    self.purchaseHistoryModel = PurchaseHistoryResponseModel(items: Array(finalItems))//itemData//data?.items
                } else {
                    self.purchaseHistoryModel = PurchaseHistoryResponseModel(items: Array(historyModel))//itemData//data?.items
                }
                self.purchaseHistoryTotalModel = PurchaseHistoryResponseModel(items: Array(self.purchaseHistoryTotalModel.items?.dropFirst(5) ?? []))
                print(self.purchaseHistoryModel)
                print(self.purchaseHistoryTotalModel)
            }
        } else {
            let itemCount = self.purchaseHistoryTotalModel.items?.count ?? 0
            if let historyModel = self.purchaseHistoryTotalModel.items?[0..<(itemCount)] {
                
                if let existingItem = self.purchaseHistoryModel.items, existingItem.count > 0 {
                    let finalItems = existingItem + historyModel
                    self.purchaseHistoryModel = PurchaseHistoryResponseModel(items: Array(finalItems))//itemData//data?.items
                } else {
                    self.purchaseHistoryModel = PurchaseHistoryResponseModel(items: Array(historyModel))//itemData//data?.items
                }
                self.purchaseHistoryTotalModel = PurchaseHistoryResponseModel(items: Array(self.purchaseHistoryTotalModel.items?.dropFirst(itemCount) ?? []))
                print(self.purchaseHistoryModel)
                print(self.purchaseHistoryTotalModel)
            } else {
                print(self.purchaseHistoryModel)
                print(self.purchaseHistoryTotalModel)
            }
        }
    }
    
    func setStation(indexPath: IndexPath) -> String? {
        if let items = self.purchaseHistoryModel.items {
            let recordDate = items[indexPath.section].recordDate?.toDateLocalEn(timeZone: .AST) ?? Date()
            let formattedDateString = recordDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)
            return formattedDateString
        } else {
            return emptyString
        }
    }
}

extension PurchaseHistoryViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseHistoryModel.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DescriptionTableCell? = tableView.dequeueReusableCell(withIdentifier: DescriptionTableCell.identifier, for: indexPath) as? DescriptionTableCell
        cell?.configure(self.purchaseHistoryModel.items?[indexPath.section])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
