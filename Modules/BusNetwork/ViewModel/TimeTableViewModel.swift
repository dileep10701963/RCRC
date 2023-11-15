//
//  TimeTableViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 03/11/22.
//

import Foundation
import UIKit
import Alamofire

class TimeTableViewModel: NSObject {

    static let shared = BusNetworkViewModel()
    var selectedSection: Int?
    
    var busTimeTableResult: RouteModel? = nil
    var busTimeTableTitleResult: RouteModel? = nil
    
    func getBusTimeTableContent(endpoint: String = URLs.busTimeTableContent, completionHandler : @escaping (RouteModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .busNetworkContent, methodName: URLs.busTimeTableContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: RouteModel.self) { result in
            switch result {
            case .success((let data, _)):
                
                let sortedModel = self.sortedRouteModel(routeModel: data)
                self.busTimeTableResult = sortedModel
                if currentLanguage == .arabic {
                    ServiceManager.sharedInstance.routeModelArabic = sortedModel
                } else {
                    ServiceManager.sharedInstance.routeModelEng = sortedModel
                }
                completionHandler(self.busTimeTableResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.busTimeTableResult,errr)
                
            }
        }
    }
    
    func getBusTimeTableHeaderTitle(endpoint: String = URLs.routesHeader, completionHandler : @escaping (RouteModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .busNetworkHeader, methodName: URLs.routesHeader, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: RouteModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.busTimeTableTitleResult = data
                if currentLanguage == .arabic {
                    ServiceManager.sharedInstance.routeModelTitleArabic = data
                } else {
                    ServiceManager.sharedInstance.routeModelTitleEng = data
                }
                completionHandler(self.busTimeTableTitleResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.busTimeTableTitleResult,errr)
                
            }
        }
    }
    
    private func sortedRouteModel(routeModel: RouteModel?) -> RouteModel? {
        var model: RouteModel? = nil
        if let routeModel = routeModel {
            model = routeModel
            if let items = routeModel.items, items.count > 0, let contentFields = items[0].contentFields, contentFields.count > 0 {
                if contentFields.contains(where: {$0.label ?? emptyString == "Route Number"}) {
                    let newItems = items.sorted(by: {Int($0.contentFields?.first(where: {$0.label == "Route Number"})?.contentFieldValue?.data ?? "0") ?? 0 < Int($1.contentFields?.first(where: {$0.label == "Route Number"})?.contentFieldValue?.data ?? "0") ?? 0 })
                    model = RouteModel(items: newItems, lastPage: nil, page: nil, pageSize: nil, totalCount: nil)
                }
            }
        }
        return model
    }
    
    private func getBusTitleModel() -> RouteModel? {
        if currentLanguage == .arabic {
            if ServiceManager.sharedInstance.routeModelTitleArabic != nil {
                return ServiceManager.sharedInstance.routeModelTitleArabic
            } else {
                return self.busTimeTableTitleResult
            }
        } else if currentLanguage == .english {
            if ServiceManager.sharedInstance.routeModelTitleEng != nil {
                return ServiceManager.sharedInstance.routeModelTitleEng
            } else {
                return self.busTimeTableTitleResult
            }
        } else {
            return self.busTimeTableTitleResult
        }
    }
    
    func getBusitleAndHeading() -> (NSMutableAttributedString?, NSMutableAttributedString?) {
        if let items = self.getBusTitleModel()?.items, items.count > 0 , let contentFields = items[0].contentFields, contentFields.count > 0 {
            
            let titleContent = contentFields.first(where: {$0.label?.lowercased() == "Route Title".lowercased()})
            let title = titleContent?.contentFieldValue?.data ?? emptyString
            let titleAttributed = NSMutableAttributedString(string: title, attributes: [NSMutableAttributedString.Key.foregroundColor: Colors.textColor, NSMutableAttributedString.Key.font: Fonts.CodecBold.nineteen])
            
            let headerContent = contentFields.first(where: {$0.label?.lowercased() == "Route Heading".lowercased()})
            let header = headerContent?.contentFieldValue?.data ?? emptyString
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            let headerAttributed = NSMutableAttributedString(string: header, attributes: [NSMutableAttributedString.Key.foregroundColor: Colors.textColor, NSMutableAttributedString.Key.font: Fonts.CodecRegular.sixteen, NSMutableAttributedString.Key.paragraphStyle: paragraphStyle])
            
            return (titleAttributed, headerAttributed)
        } else {
            return (nil, nil)
        }
    }
    
    private func getBusModel() -> RouteModel? {
        if currentLanguage == .arabic {
            if ServiceManager.sharedInstance.routeModelArabic != nil {
                return ServiceManager.sharedInstance.routeModelArabic
            } else {
                return self.busTimeTableResult
            }
        } else if currentLanguage == .english {
            if ServiceManager.sharedInstance.routeModelEng != nil {
                return ServiceManager.sharedInstance.routeModelEng
            } else {
                return self.busTimeTableResult
            }
        } else {
            return self.busTimeTableResult
        }
    }
    
    private func getTitleHeading(section: Int) -> String {
        if let model = self.getBusModel()?.items?[section].contentFields?.first(where: {$0.label?.lowercased() == "Heading".lowercased()}) {
            return model.contentFieldValue?.data ?? emptyString
        } else {
            return emptyString
        }
    }
    
    private func getTackColor(section: Int) -> UIColor {
        if let model = self.getBusModel()?.items?[section].contentFields?.first(where: {$0.label?.lowercased() == "Colorcode".lowercased()}) {
            let strColor:String = model.contentFieldValue?.data ?? emptyString
            return strColor.hexToUIColor()
        } else {
            return UIColor()
        }
    }
    
    private func getRouteNumber(section: Int) -> String {
        if let model = self.getBusModel()?.items?[section].contentFields?.first(where: {$0.label?.lowercased() == "Route Number".lowercased()}) {
            return model.contentFieldValue?.data ?? emptyString
        } else {
            return emptyString
        }
    }
   
   
    private func busRouteContent(section: Int) -> (north: String, south: String, keyPoints: String, count: Int)? {
        
        if let contentFields = self.getBusModel()?.items?[section].contentFields {
            var northMessage: String = emptyString
            var southMessage: String = emptyString
            var keyPointMessage: String = emptyString
            
            if let northModel = contentFields.first(where: {$0.label?.lowercased() == "North Direction Stops".lowercased() }) {
                northMessage = northModel.contentFieldValue?.data ?? emptyString
            }
            
            if let southModel = contentFields.first(where: {$0.label?.lowercased() == "South Direction Stops".lowercased() }) {
                southMessage = southModel.contentFieldValue?.data ?? emptyString
            }
            
            if let landMarkModel = contentFields.first(where: {$0.label?.lowercased() == "Landmark".lowercased() }) {
                keyPointMessage = landMarkModel.contentFieldValue?.data ?? emptyString
            }
            
            var count = 3
            
            if keyPointMessage == emptyString {
                count = 2
            }
            
            return (northMessage, southMessage, keyPointMessage, count)
            
        } else {
            return (emptyString, emptyString, emptyString, 0)
        }
        
    }
    
}

extension TimeTableViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.getBusModel()?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        if selectedSection == section {
            let contentValue = self.busRouteContent(section: section)
            numberOfRows = contentValue?.count ?? 0
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let timeTableCardCount = self.getBusModel()?.items?[indexPath.section].contentFields?.count, timeTableCardCount > 0 {
            
            let contentValue = self.busRouteContent(section: indexPath.section)
            
            switch indexPath.row {
            case 0:
                let cell: BusRouteNorthSouthTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configureCell(routes: contentValue?.north, routeType: .north)
                return cell
            case 1:
                let cell: BusRouteNorthSouthTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configureCell(routes: contentValue?.south, routeType: .south)
                return cell
            case 2:
                let cell: BusRouteNorthSouthTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configureCell(routes: contentValue?.keyPoints, routeType: .keyFeatures)
                return cell
            default:
                return UITableViewCell()
            }
            
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let timeTableCardCount = self.getBusModel()?.items?[indexPath.section].contentFields?.count, timeTableCardCount > 0 {
            let contentValue = self.busRouteContent(section: indexPath.section)
            switch indexPath.row {
            case 0:
                if contentValue?.north == emptyString {
                    return 0
                }
            case 1:
                if contentValue?.south == emptyString {
                    return 0
                }
            case 2:
                if contentValue?.keyPoints == emptyString {
                    return 0
                }
            default:
                return UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String.className(BusTimeTableHeaderView.self)) as? BusTimeTableHeaderView
        
        var headerTitle: String = emptyString
        headerTitle = self.getTitleHeading(section: section)
        let routeColor = self.getTackColor(section: section)
        
        headerView?.routeColorLabel.text = getRouteNumber(section: section) ?? emptyString
        headerView?.configureHeaderTitle(title: headerTitle, section: section, selected: selectedSection, routeColr: routeColor)
        headerView?.sectionTapped = { [weak self] clickedSectionIn in
            DispatchQueue.main.async {
                if self?.selectedSection == section {
                    self?.selectedSection = -1
                } else {
                    self?.selectedSection = section
                }
                tableView.reloadData()
                if self?.selectedSection != -1 {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: false)
                }
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70//UITableView.automaticDimension
    }
    
}
