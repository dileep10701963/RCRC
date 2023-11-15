//
//  TravelHistoryViewModel.swift
//  RCRC
//
//  Created by Saheba Juneja on 03/05/23.
//

import Foundation
import UIKit
import Alamofire

extension URLs {
    static let travelHistory = "travel-history/1.0.0/media-types"
}

protocol TravelHistoryDelegate: AnyObject {
    func openTableHeightConstraint()
    func closeTableHeightConstraint()
}

class TravelHistoryViewModel: NSObject {

    static let shared = TravelHistoryViewModel()
    var selectedSection: Int?
    var faremediaViewModel = FareMediaViewModel()
    var travelHistoryModel = TravelHistory(items: nil)
    var searchTravelHistoryModel = TravelHistory(items: nil)
    var travelHistoryTotalModel = TravelHistory(items: nil)//TravelHistory(items: nil)
    
    func getSerialNumber(completionHandler : @escaping (String?, FareMediaError?) -> Void) {
        var serialNumber = ""
        faremediaViewModel.getPurchasedAndAvailableFareMedia { result in
            switch result {
            case let .success(fareMedia):
                /*if fareMedia.purchasedProducts.count > 0 {
                    for ap in fareMedia.purchasedProducts {
                        serialNumber = ap.serialNumber ?? ""
                        completionHandler(serialNumber)
                    }
                } else {
                    serialNumber = ""
                    completionHandler(serialNumber)
                }*/
                
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
    
    func getTravelHistory(endpoint: String = URLs.travelHistory, completionHandler : @escaping (TravelHistory?, FareMediaError?) -> Void) {
        getSerialNumber { srNumber, error in
            
            if let srNumber = srNumber {
                let endPoint = EndPoint(baseUrl: .travelHistory, methodName: URLs.travelHistory + "?mediaTypeId=\(Constants.barcodeType)&serialNumber=\(srNumber)", method: .get, encoder: URLEncodedFormParameterEncoder.default)
                let parameters = DefaultParameters()
                
                ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: TravelHistory.self) { result in
                    switch result {
                    case .success((let data, _)):
                        
                        let dataa = TravelHistory(items: data?.items)
                        if let item = dataa.items, item.count > 0 {
                            var itemData = item
                            for index in 0..<item.count {
                                let rDate = itemData[index].date?.toDateLocalEn(timeZone: .AST)
                                let n1Date = rDate?.toString(timeZone: .AST)
                                print("n1Date: \(n1Date ?? "")")
                                itemData[index].recordInDate = rDate
                            }
                            itemData = itemData.filter({$0.recordInDate ?? Date() >= Date().subtracting(months: -1) ?? Date()})
                            
                            itemData.sort(){($0.recordInDate  ?? Date()) > ($1.recordInDate ?? Date())}
                            print(itemData)
                                                        
                            self.travelHistoryTotalModel = TravelHistory(items: itemData)//itemData//data?.items
                            self.loadHistoryData()
                            self.searchTravelHistoryModel = TravelHistory(items: itemData)
                            print(self.searchTravelHistoryModel)
                            
                            completionHandler(self.travelHistoryModel, .none)
                        } else {
                            completionHandler(nil, .invalidData)
                        }
                    case .failure(let errr):
                        print("Error-->", errr)
                        completionHandler(nil, .invalidData)
                    }
                }
            } else {
                completionHandler(nil,error)
            }
        }
    }
    
    func loadHistoryData() {
        
        if self.travelHistoryTotalModel.items?.count ?? 0 >= 5 {
            
            if let historyModel = self.travelHistoryTotalModel.items?[0..<5] {
                
                if let existingItem = self.travelHistoryModel.items, existingItem.count > 0 {
                    let finalItems = existingItem + historyModel
                    self.travelHistoryModel = TravelHistory(items: Array(finalItems))//itemData//data?.items
                } else {
                    self.travelHistoryModel = TravelHistory(items: Array(historyModel))//itemData//data?.items
                }
                self.travelHistoryTotalModel = TravelHistory(items: Array(self.travelHistoryTotalModel.items?.dropFirst(5) ?? []))
                print(self.travelHistoryModel)
                print(self.travelHistoryTotalModel)
            }
        } else {
            let itemCount = self.travelHistoryTotalModel.items?.count ?? 0
            if let historyModel = self.travelHistoryTotalModel.items?[0..<(itemCount)] {
                
                if let existingItem = self.travelHistoryModel.items, existingItem.count > 0 {
                    let finalItems = existingItem + historyModel
                    self.travelHistoryModel = TravelHistory(items: Array(finalItems))//itemData//data?.items
                } else {
                    self.travelHistoryModel = TravelHistory(items: Array(historyModel))//itemData//data?.items
                }
                self.travelHistoryTotalModel = TravelHistory(items: Array(self.travelHistoryTotalModel.items?.dropFirst(itemCount) ?? []))
                print(self.travelHistoryModel)
                print(self.travelHistoryTotalModel)
            } else {
                print(self.travelHistoryModel)
                print(self.travelHistoryTotalModel)
            }
        }
    }
    
    func loadJson(filename fileName: String) -> TravelHistory? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(TravelHistory.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

extension TravelHistoryViewModel: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  travelHistoryModel.items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let travelHistory = travelHistoryModel.items?[indexPath.row]
        let cell: TravelHistoryCellTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
        let stationName = travelHistory?.station?.localized ?? ""
        let travelLine =  travelHistory?.line?.localized ?? ""
        let dateInresponse = travelHistory?.date?.toDateLocalEn(timeZone: .AST) ?? Date()
        let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
        cell.setCellConstraints(stationName: stationName, travelnumber: travelLine, dateofTravel: formattedDateString)
        return cell
    }
}
