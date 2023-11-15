//
//  HomeViewViewModel.swift
//  RCRC
//
//  Created by Sagar Tilekar on 03/07/20.
//  Copyright © 2020 Riyadh Journey Planner. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import GoogleMaps

class HomeViewModel: NSObject {
    
    var weatherResult: Observable<WeatherModel?, Error?> = Observable(nil, nil)
    var favoritePlaces = ValueObservable<[SavedLocation]>([])
    var stopRouteModel: StopRouteModel!
    var busStopModelList: [StopsItem]!
    func getWeather(endpoint: String = URLs.weatherEndpointUrl, completionHandler : (() -> Void)? = nil) {
        let request = WeatherRequest()
        let endPoint = EndPoint(baseUrl: .journeyPlanner, methodName: endpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: WeatherModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(weatherResult):
                self.weatherResult.value = weatherResult
            case let .failure(error):
                self.weatherResult.error = error
            }
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
    
    func fetchFavoritePlaces() {
        if let favoritePlaces = FavoriteLocationDataRepository.shared.fetchAll() {
            self.favoritePlaces.value = favoritePlaces
        } else {
            self.favoritePlaces.value = []
        }
    }
   
    func getBusStopListForMap(completion: @escaping ([StopsItem]?, Error?) -> Void) {
        let request = GetBusStopForMapRequest()
//        let endPoint = EndPoint(baseUrl: .busStopOnMap, methodName: URLs.busStopPointsOnMap, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let langaugeCode = currentLanguage == .english ? Languages.english.rawValue : Languages.arabic.rawValue
        let endPoint = EndPoint(baseUrl: .busStopOnMap, methodName: URLs.listCord + "?language=\(langaugeCode)", method: .get, encoder: URLEncodedFormParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: [StopsItem].self) { [weak self] result in
            switch result {
            case let .success(busStopResult):
                completion(busStopResult, nil)
            case .failure(_):
                completion(nil, nil)
            }
        }
        
    }
    
    func getNextBusDetail(stopID: String, completion: @escaping ([NextBusInfoModel]?, Error?) -> Void) {
        let request = GetNextBusInfoRequest(namedm: stopID)
        let endPoint = EndPoint(baseUrl: .nextBusInfo, methodName: URLs.nextBusInfo, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: [NextBusInfoModel].self) { [weak self] result in
            guard self != nil else {
                completion(nil, nil)
                return
            }
            switch result {
            case let .success(nextBusInfoModel):
                completion(nextBusInfoModel, nil)
            case .failure(_):
                completion(nil, nil)
                
            }
        }
    }
    
    func getLiveStatusOfBus(routeDirectionModel: RouteDirectionModel?, selectedRoute: String?, completion: @escaping ([LiveBusStatusModel]?, Error?) -> Void) {
        
        var routeID: String = ""
        let selectedRoute: String = selectedRoute ?? ""
        if let routeDirectionModel = routeDirectionModel, routeDirectionModel.directionType != .none {
            if routeDirectionModel.directionType == .north {
                routeID = routeDirectionModel.northID
            } else if routeDirectionModel.directionType == .south {
                routeID = routeDirectionModel.southID
            }
        }
        
        var liveVelocURL: String = ""
        if routeID != "" && selectedRoute != "" {
            if routeID.contains(":H:") {
                liveVelocURL = "\(URLs.liveBusStatus)?LineID=\(selectedRoute)&LineDir=\(selectedRoute)A"
            } else if routeID.contains(":R:") {
                liveVelocURL = "\(URLs.liveBusStatus)?LineID=\(selectedRoute)&LineDir=\(selectedRoute)B"
            }
        }
        
        if liveVelocURL != "" && selectedRoute != "" && routeID != "" {
                        
            let endPoint = EndPoint(baseUrl: .liveBusStatus, methodName: liveVelocURL, method: .get, encoder: URLEncodedFormParameterEncoder.default)
            ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: DefaultParameters(), res: [LiveBusStatusModel].self) { [weak self] result in
                guard self != nil else {
                    completion(nil, nil)
                    return
                }
                switch result {
                case let .success(liveBusResult):
                    completion(liveBusResult, nil)
                case .failure(_):
                    completion(nil, nil)
                }
            }
        } else {
            
            let request = GetLiveBusRequest()
            let endPoint = EndPoint(baseUrl: .liveBusStatus, methodName: URLs.liveBusStatus, method: .get, encoder: URLEncodedFormParameterEncoder.default)
            ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: [LiveBusStatusModel].self) { [weak self] result in
                guard self != nil else {
                    completion(nil, nil)
                    return
                }
                switch result {
                case let .success(liveBusResult):
                    completion(liveBusResult, nil)
                case .failure(_):
                    completion(nil, nil)
                }
            }
            
        }
    }
    
    func getMaxWidth(routes: [String]) -> CGFloat {
        
        var maxWidth: CGFloat = 125
        
        let font = Fonts.CodecBold.fourteen
        let fontAttributes = [NSAttributedString.Key.font: font]
        for route in routes {
            let text = route == Constants.busStations.localized ? Constants.busStations.localized : "\(Constants.busRoute.localized) \(route)"
            let size = (text as NSString).size(withAttributes: fontAttributes)
            if size.width > maxWidth {
                maxWidth = size.width
            }
        }
        return maxWidth
    }
    
    func getTotalHeightOfTableView(routes: [String]) -> CGFloat {
        
        let screenHeight = UIScreen.main.bounds.size.height
        let contentHeight: CGFloat = CGFloat(routes.count * 28)
        if (screenHeight / 2) > contentHeight {
            return contentHeight
        } else {
            return screenHeight / 2
        }
        
    }
    
    func getTotalHeightOfMarkerTableView(markersInfo: [NextBusInfoModel]) -> CGFloat {
        if markersInfo.count > 0 {
            var contentHeight: CGFloat = CGFloat((markersInfo.count + 1) * 28)
            if contentHeight > 150 {
                contentHeight = 150
            }
            return contentHeight
        } else {
            return 0.0
        }
    }
    
    func getWidthForMarkerInfoView(placeName: String, nextBusInfo: [NextBusInfoModel]) -> (width: CGFloat, updatedWidth: Bool) {
        var markerWidth: CGFloat = getPlaceNameWidth(placeName: placeName)
        var isWidthSet: Bool = false
        if nextBusInfo.count > 0 {
            if markerWidth < self.getNextStopInfoWidth(nextBusInfo: nextBusInfo) {
                markerWidth = self.getNextStopInfoWidth(nextBusInfo: nextBusInfo)
                isWidthSet = true
            }
        }
        return (markerWidth, isWidthSet)
    }
    
    private func getPlaceNameWidth(placeName: String) -> CGFloat {
        return ceil(widthForLabel(text: placeName) + 10)
    }
    
    func widthForLabel(text:String) -> CGFloat{
       let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width:CGFloat.greatestFiniteMagnitude, height: 28))
       label.numberOfLines = 1
       label.lineBreakMode = NSLineBreakMode.byCharWrapping
       label.font = Fonts.CodecBold.twelve
       label.text = " \(text) "
       label.sizeToFit()
       return label.frame.width
    }
    
    private func getNextStopInfoWidth(nextBusInfo: [NextBusInfoModel]) -> CGFloat {
        var width: CGFloat = 0.0
        
        for index in 0 ..< nextBusInfo.count {
            var nameSize = widthForLabel(text: "\(Constants.busTitle.localized) \(nextBusInfo[index].number ?? emptyString)")
            var timeSize = widthForLabel(text: "\(nextBusInfo[index].departureTimePlanned ?? emptyString)")
            if nameSize > timeSize {
                timeSize = nameSize
            } else {
                nameSize = timeSize
            }
            let widthAfterCalculation = nameSize + timeSize + 20
            if widthAfterCalculation > width {
                width = widthAfterCalculation
            }
        }
        
        var routeWidth = widthForLabel(text: Constants.route.localized)
        var departureWidth = widthForLabel(text: Constants.departureInfo.localized)
        
        if routeWidth > departureWidth {
            departureWidth = routeWidth
        } else {
            routeWidth = departureWidth
        }
        let routeDepatureWidth = routeWidth + departureWidth  + 20
        
        if routeDepatureWidth > width {
            width = routeDepatureWidth
        }
        
        return ceil(width)
    }
    
    func getDelayTimeWithCondition(liveBusStatusModel: LiveBusStatusModel) -> (showDelay: Bool, delayTimeValue: String, widthFrame: CGFloat, heighFrame: CGFloat, color: UIColor) {
        
        var isDelayVisible: Bool = false
        var delayTime = ""
        var width: CGFloat = 50
        var height: CGFloat = 20
        let imageWidthHeight: CGFloat = 20
        
        var color = Colors.rptGreen
        isDelayVisible = true
        color = Colors.black
        delayTime = "\(Constants.busTitle.localized) \(liveBusStatusModel.lineText ?? "")"
        
        let font = Fonts.CodecRegular.eleven
        let fontAttributes = [NSAttributedString.Key.font: font]
        let text = delayTime
        let size = (text as NSString).size(withAttributes: fontAttributes)
        width = size.width + 12 + imageWidthHeight
        
        let label = UILabel()
        label.font = Fonts.CodecRegular.eleven
        label.text = delayTime
        label.sizeToFit()
        width = label.frame.size.width + 12 + imageWidthHeight
        if size.height > imageWidthHeight {
            height = size.height
        }
        
        return (isDelayVisible, delayTime, width, height, color)
    }
    
    func secondsToMinutes(_ seconds: Int) -> Int {
        let minute = seconds / 60
        return minute
    }
    
    func getCurrentTimeForBus (delaySec: Int, symbol: String) -> String {
        let delayInMin = secondsToMinutes(delaySec)
        if delayInMin >= 4 {
            print("_______","\(symbol)\(delayInMin) min")
            return "\(symbol)\(delayInMin) \("min".localized)"
        } else {
            print("_______","")
            return ""
        }
    }
    
    func getStopGlobalID(name: String) -> String {
        var globalID: String = emptyString
        if let location:[StopsItem] = ServiceManager.sharedInstance.stopListItemData, location.count > 0 {
            
            guard let stopModel = location.filter({$0.translation == name}).last else {
                return ""
            }
            
            globalID = "\(stopModel.record_id ?? 0)"
        }
        
        
        return globalID
    }
    
    func getBusStopNamebyCordinate(coordinate:CLLocationCoordinate2D) -> String {
        var busStationName: String = emptyString
        if let location:[StopsItem] = ServiceManager.sharedInstance.stopListItemData, location.count > 0 {
            
            guard let stopModel = location.filter({$0.stop_lat == "\(coordinate.latitude)" && $0.stop_lon == "\(coordinate.longitude)"}).last else {
                return ""
            }
            
            busStationName = stopModel.translation ?? emptyString
        }
        
        
        return busStationName
    }
    func getStoGlobalIDByCoordinate(lat:String,long:String) -> String {
        var globalID: String = emptyString
        if let location:[StopsItem] = ServiceManager.sharedInstance.stopListItemData, location.count > 0 {
            
            guard let stopModel = location.filter({$0.stop_lat == lat && $0.stop_lon == long}).last else {
                return ""
            }
            
            globalID = "\(stopModel.record_id ?? 0)"
        }
        
        
        return globalID
        
    }
    func getRouteForSelectedStopAPI(selectedRoute: String, completion: @escaping (StopRouteModel?, Error?) -> Void) {
        
        let selectedRouteNumber = String(format: "%03d", Int(selectedRoute) ?? 0)
        let routeURL = URLs.stopRoute + "?coordOutputFormat=WGS84%5BDD.DDDDD%5D&line=rda%253A01\(selectedRouteNumber)%253A%253AR%253Ay21&line=rda%253A01\(selectedRouteNumber)%253A%253AH%253Ay21&lineReqType=1&outputFormat=rapidJSON&language=\(currentLanguage == .arabic ? "ar": "en")"
        let endPoint = EndPoint(baseUrl: .stopRoutes, methodName: routeURL, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: DefaultParameters(), res: StopRouteModel.self) { [weak self] result in
            switch result {
            case let .success(stopRouteModel):
                self?.stopRouteModel = stopRouteModel 
                completion(stopRouteModel, nil)
            case .failure(_):
                completion(nil, nil)
            }
        }
    }
    
    
    func getMultipleRouteDriection() -> (RouteDirectionModel) {
        
        var directionModel = RouteDirectionModel(northDirection: "", southDirection: "", directionType: .none, northID: "", southID: "")
        if self.stopRouteModel != nil, stopRouteModel.transportations?.count ?? 0 > 0 {
            if let transportations = stopRouteModel.transportations, transportations.count > 1 {
                let northDirectioName = transportations[0].locationSequence?.last?.parent?.name ?? ""
                let southDirectionName = transportations[1].locationSequence?.last?.parent?.name ?? ""
                let northID = stopRouteModel.transportations?[0].id ?? ""
                let southID = stopRouteModel.transportations?[1].id ?? ""
                directionModel = RouteDirectionModel(northDirection: northDirectioName, southDirection: southDirectionName, directionType: .north, northID: northID, southID: southID)
                return directionModel
            } else {
                let northDirectioName = stopRouteModel.transportations?[0].locationSequence?.last?.parent?.name ?? ""
                let northID = stopRouteModel.transportations?[0].id ?? ""
                return RouteDirectionModel(northDirection: northDirectioName, southDirection: "", directionType: .north, northID: northID)
            }
        } else {
            return directionModel
        }
        
    }
    
    func getRoutePath(selectedDirectionType: SelectedDirection) -> [RoutePathForStop] {
        if self.stopRouteModel != nil {
            let routeColor: UIColor =  getColorForSelectedPath()
            
            var modelTransportations = stopRouteModel.transportations
            
            if let transportations = stopRouteModel.transportations, transportations.count > 1 {
                if selectedDirectionType == .north {
                    modelTransportations = [transportations[0]]
                } else if selectedDirectionType == .south {
                    modelTransportations = [transportations[1]]
                }
            }
            
            if let transportations = modelTransportations, transportations.count > 0 {
                var routePathForStops: [RoutePathForStop] = []
                for transportation in transportations where transportation.coords?.count ?? 0 > 0 {
                    if let mainCoord = transportation.coords {
                        
                        for (_, mainCoord) in mainCoord.enumerated() {
                            let routePaths = mainCoord.map { leg -> RoutePathForStop in
                                let gmsPath = GMSMutablePath()
                                let coords = mainCoord.compactMap {$0}.map { coord -> CLLocationCoordinate2D in
                                    let coordinate = coord.compactMap({$0})
                                    return CLLocationCoordinate2D(
                                        latitude: coordinate[coordinate.startIndex],
                                        longitude: coordinate[coordinate.endIndex - 1])
                                }
                                coords.forEach { gmsPath.add($0) }
                                let routePath = RoutePathForStop(path: gmsPath, color: routeColor)
                                return routePath
                            }
                            routePathForStops.append(contentsOf: routePaths)
                        }
                        
                    }
                }
                return routePathForStops
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    func getColorForSelectedPath() -> UIColor {
        
        var routeColor: UIColor = Colors.green
        if self.stopRouteModel != nil, let transportations = self.stopRouteModel.transportations, transportations.count > 0 {
            if let colorCodeFromAPI = stopRouteModel.routeColorIdentifier{
                
                return UIColor(hexString: colorCodeFromAPI)
            }
            let number = transportations[0].number ?? ""
            routeColor = getColorForSelectedPath(routeNumber: number)
        }
        return routeColor
    }
    
    
    func getColorForSelectedPath(routeNumber:String) -> UIColor {
        
        var routeColor: UIColor = Colors.green

            let number = routeNumber ?? ""
            switch number {
            case "7":
                routeColor = Colors.route7
            case "8":
                routeColor = Colors.route8
            case "9":
                routeColor = Colors.route9
            case "10":
                routeColor = Colors.route10
            case "11":
                routeColor = Colors.route11
            case "13":
                routeColor = Colors.route13
            case "16":
                routeColor = Colors.route16
            case "17":
                routeColor = Colors.route17
            case "150":
                routeColor = Colors.route150
            case "151":
                routeColor = Colors.route151
            case "160":
                routeColor = Colors.route160
            case "170":
                routeColor = Colors.route170
            case "180":
                routeColor = Colors.route180
            case "181":
                routeColor = Colors.route181
            case "230":
                routeColor = Colors.route230
            case "231":
                routeColor = Colors.route231
            case "250":
                routeColor = Colors.route250
            case "280":
                routeColor = Colors.route280
                case "341":
                routeColor = Colors.route341
            case "342":
                routeColor = Colors.route342
            case "350":
                routeColor = Colors.route350
            case "430":
                routeColor = Colors.route430
            case "540":
                routeColor = Colors.route540
            case "660":
                routeColor = Colors.route660
            case "680":
                routeColor = Colors.route680
            case "730":
                routeColor = Colors.route730
            case "928":
                routeColor = Colors.route928
            case "940":
                routeColor = Colors.route940
            case "941":
                routeColor = Colors.route941
            case "951":
                routeColor = Colors.route951
            case "952":
                routeColor = Colors.route952
            case "953":
                routeColor = Colors.route953
            case "984":
                routeColor = Colors.route984
                
            default:
                break
            }
        
        return routeColor
    }
    
    
    func getBusStopsForSelectedRoute() -> [LocationSequence] {
        if self.stopRouteModel != nil {
            if let transportations = stopRouteModel.transportations, transportations.count > 0 {
                
                var northStops: [LocationSequence] = []
                transportations.forEach { route in
                    if let sequence = route.locationSequence {
                        northStops += sequence
                    }
                }
            
                return northStops
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    func getBusStopIDSelectedBus(isRouteSelected: Bool, marker: GMSMarker) -> String {
        
        var busStopID = ""
        
        switch isRouteSelected {
        case true:
            if self.stopRouteModel != nil {
                if let transportations = self.stopRouteModel.transportations, transportations.count > 0 {
                    
                    var locationSequence: [LocationSequence] = []
                    transportations.forEach { route in
                        if let sequence = route.locationSequence {
                            locationSequence += sequence
                        }
                    }
                    
                    let firstIndex = locationSequence.firstIndex { busStopLocation in
                        if let lat = busStopLocation.coord.first, let long = busStopLocation.coord.last, marker.position.latitude == lat, marker.position.longitude == long {
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    if let firstIndex = firstIndex {
                        busStopID = locationSequence[firstIndex].id ?? ""
                    }
                    
                }
            }
        case false:
            if ServiceManager.sharedInstance.stopListItemData != nil && ServiceManager.sharedInstance.stopListItemData?.count ?? 0 > 0 {
                
                guard let busModel:StopsItem = ServiceManager.sharedInstance.stopListItemData?.filter({$0.stop_lat == "\(marker.position.latitude)" && $0.stop_lon == "\(marker.position.longitude)"}).last else{
                    return ""
                }
               busStopID = "\(Int(busModel.record_id ?? 0/100))"
                
            }
        }
            
            
        return busStopID
        
    }
    
    func getBusStationName(isRouteSelected: Bool, marker: GMSMarker) -> String {
       // ServiceManager.sharedInstance.stopListItemData
        var busStationName: String = ""
        
        switch isRouteSelected {
        case true:
            if self.stopRouteModel != nil {
                if let transportations = self.stopRouteModel.transportations, transportations.count > 0 {
                    
                    var locationSequence: [LocationSequence] = []
                    transportations.forEach { route in
                        if let sequence = route.locationSequence {
                            locationSequence += sequence
                        }
                    }
                    
                    let firstIndex = locationSequence.firstIndex { busStopLocation in
                        if let lat = busStopLocation.coord.first, let long = busStopLocation.coord.last, marker.position.latitude == lat, marker.position.longitude == long {
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    if let firstIndex = firstIndex {
                        
                        var dissambledName = locationSequence[firstIndex].parent?.name ?? emptyString
//                           if currentLanguage == .arabic {
//                            dissambledName = returnArabicNameForSelectedRoute(name: dissambledName, marker: marker)
//                        }
                        
                        busStationName = "\(Constants.busStation.localized): \(dissambledName)"
                    }
                    
                }
            }
        case false:
            if ServiceManager.sharedInstance.stopListItemData?.count ?? 0 > 0 && ServiceManager.sharedInstance.stopListItemData != nil {
                guard let busModel:StopsItem = ServiceManager.sharedInstance.stopListItemData?.filter({$0.stop_lat == "\(marker.position.latitude)" && $0.stop_lon == "\(marker.position.longitude)"}).last else{
                    return ""
                }
                busStationName = busModel.translation ?? ""
            }
            
        }
        return busStationName
        
    }
   /*
    func returnArabicNameForSelectedRoute(name: String, marker: GMSMarker) -> String {
        var arabicName = name
        if arabicName.isArabic == false {
            if self.busStopModelList != nil && busStopModelList.count > 0 {
                
                let busModel:StopsItem = busStopModelList.filter({$0.stop_lat == "\(marker.position.latitude)" && $0.stop_lon == "\(marker.position.longitude)"}).last!
                arabicName = busModel.translation ?? ""
                
            }
        }
        return arabicName
    }
   */
    func getNextBusDetailInfo(nextBusInfo: [NextBusInfoModel]) -> [NextBusInfoModel] {
        
        var tempNextBusModel: [NextBusInfoModel] = []
        nextBusInfo.forEach { model in
            if tempNextBusModel.contains(where: {$0.name ?? "" == model.name ?? ""}) {
                if tempNextBusModel.filter({$0.name ?? "" == model.name ?? ""}).count < 2 {
                    let timeValue = model.departureTimePlanned?.toDate(timeZone: .AST,language: .english)?.toString(withFormat: "hh:mm a", timeZone: .AST) ?? emptyString
                    var updateModel = model
                    updateModel.departureTimePlanned = timeValue
                    tempNextBusModel.append(updateModel)
                } else {
                    // Do Some
                }
            } else {
                let timeValueDate = model.departureTimePlanned?.toDate(timeZone: .AST,language: .english)
                let timeValue = timeValueDate?.toString(withFormat: "hh:mm a", timeZone: .AST) ?? emptyString
                print("timeValueDate",timeValueDate)
                print("timeValue",timeValue)
                var updateModel = model
                updateModel.departureTimePlanned = timeValue
                tempNextBusModel.append(updateModel)
            }
        }
        
        tempNextBusModel = tempNextBusModel.sorted(by: {$0.name ?? "" < $1.name ?? ""})
        
        return tempNextBusModel
    }
    
    func loadJson(filename fileName: String) -> BusStopModel? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(BusStopModel.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
        
    }
    
}


// MARK: - Welcome
struct BusStopModel: Codable {
    let serverInfo: ServerInfo?
    let version: String?
    let locations: [BusStopLocation]?
}

// MARK: - Location
struct BusStopLocation: Codable {
    let id: String?
    let isGlobalID: Bool?
    let name: String?
    let type: String?
    let coord: [Double]?
    let parent: LocationParent?
    let properties: Properties?

    enum CodingKeys: String, CodingKey {
        case id
        case isGlobalID = "isGlobalId"
        case name, type, coord, parent, properties
    }
}

// MARK: - LocationParent
struct LocationParent: Codable {
    let id: String?
    let isGlobalID: Bool?
    let disassembledName: DisassembledName?
    let name: String?
    let type: String?
    let parent: BusStopParentParent?

    enum CodingKeys: String, CodingKey {
        case id
        case isGlobalID = "isGlobalId"
        case disassembledName, name, type, parent
    }
}

struct DisassembledName: Codable {
    let en, ar: String
    
    func getDissambledName() -> String? {
        return currentLanguage == .arabic ? ar: en
    }
}

// MARK: - ParentParent
struct BusStopParentParent: Codable {
    let id: String?
    let name: String?
    let type: String?
}


// MARK: - Properties
struct Properties: Codable {
    let distance: Int?
    let stopGlobalID, stoppointGlobalID, stopNameWithPlace: String?
    let stopAreaName: String?
    let stopPointReferedName, stopPointReferedNamewithplace, identifier: String?

    enum CodingKeys: String, CodingKey {
        case distance
        case stopGlobalID = "STOP_GLOBAL_ID"
        case stoppointGlobalID = "STOPPOINT_GLOBAL_ID"
        case stopNameWithPlace = "STOP_NAME_WITH_PLACE"
        case stopAreaName = "STOP_AREA_NAME"
        case stopPointReferedName = "STOP_POINT_REFERED_NAME"
        case stopPointReferedNamewithplace = "STOP_POINT_REFERED_NAMEWITHPLACE"
        case identifier = "IDENTIFIER"
    }
}

// MARK: - ServerInfo
struct ServerInfo: Codable {
    let controllerVersion, serverID, virtDir, serverTime: String?
    let calcTime: Double?
}


var requestJsonIs =
"""
{
  "serverInfo": {
    "controllerVersion": "10.4.28.9",
    "serverID": "EFA-1",
    "virtDir": "efa",
    "serverTime": "2023-03-07T16:35:20",
    "calcTime": 82.997
  },
  "version": "10.5.17.3",
  "locations": [
    {
      "id": "12820002",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 19 (BRT)",
      "type": "platform",
      "coord": [
        24.64145,
        46.75985
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 19 B",
      "parent": {
        "id": "128200",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 19 B",
        "name": "Riyadh, Ali Ibn Abi Talib 19 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 716,
        "STOP_GLOBAL_ID": "128200",
        "STOPPOINT_GLOBAL_ID": "12820002",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 19 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 19 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 19 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12320001",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 18 (BRT)",
      "type": "platform",
      "coord": [
        24.65357,
        46.75473
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 18 A",
      "parent": {
        "id": "123200",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 18 A",
        "name": "Riyadh, Ali Ibn Abi Talib 18 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 874,
        "STOP_GLOBAL_ID": "123200",
        "STOPPOINT_GLOBAL_ID": "12320001",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 18 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 18 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 18 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12820001",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 19 (BRT)",
      "type": "platform",
      "coord": [
        24.63997,
        46.76015
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 19 A",
      "parent": {
        "id": "128200",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 19 A",
        "name": "Riyadh, Ali Ibn Abi Talib 19 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 900,
        "STOP_GLOBAL_ID": "128200",
        "STOPPOINT_GLOBAL_ID": "12820001",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 19 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 19 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 19 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12320002",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 18 (BRT)",
      "type": "platform",
      "coord": [
        24.6547,
        46.75431
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 18 B",
      "parent": {
        "id": "123200",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 18 B",
        "name": "Riyadh, Ali Ibn Abi Talib 18 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 1020,
        "STOP_GLOBAL_ID": "123200",
        "STOPPOINT_GLOBAL_ID": "12320002",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 18 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 18 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 18 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14420001",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 20 (BRT)",
      "type": "platform",
      "coord": [
        24.63394,
        46.76196
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 20 A",
      "parent": {
        "id": "144200",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 20 A",
        "name": "Riyadh, Ali Ibn Abi Talib 20 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 1665,
        "STOP_GLOBAL_ID": "144200",
        "STOPPOINT_GLOBAL_ID": "14420001",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 20 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 20 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 20 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14420002",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 20 (BRT)",
      "type": "platform",
      "coord": [
        24.63257,
        46.76246
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 20 B",
      "parent": {
        "id": "144200",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 20 B",
        "name": "Riyadh, Ali Ibn Abi Talib 20 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 1842,
        "STOP_GLOBAL_ID": "144200",
        "STOPPOINT_GLOBAL_ID": "14420002",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 20 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 20 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 20 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12320101",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 17 (BRT)",
      "type": "platform",
      "coord": [
        24.66339,
        46.74967
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 17 A",
      "parent": {
        "id": "123201",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 17 A",
        "name": "Riyadh, Ali Ibn Abi Talib 17 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2203,
        "STOP_GLOBAL_ID": "123201",
        "STOPPOINT_GLOBAL_ID": "12320101",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 17 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 17 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 17 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12320102",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib 17 (BRT)",
      "type": "platform",
      "coord": [
        24.66472,
        46.74906
      ],
      "name": "Riyadh, Ali Ibn Abi Talib 17 B",
      "parent": {
        "id": "123201",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib 17 B",
        "name": "Riyadh, Ali Ibn Abi Talib 17 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2379,
        "STOP_GLOBAL_ID": "123201",
        "STOPPOINT_GLOBAL_ID": "12320102",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib 17 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib 17 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib 17 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12120001",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 16 (BRT)",
      "type": "platform",
      "coord": [
        24.66085,
        46.74129
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 16 A",
      "parent": {
        "id": "121200",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 16 A",
        "name": "Riyadh, Salahuddin Al Ayubi 16 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2502,
        "STOP_GLOBAL_ID": "121200",
        "STOPPOINT_GLOBAL_ID": "12120001",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 16 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 16 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 16 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12120002",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 16 (BRT)",
      "type": "platform",
      "coord": [
        24.66096,
        46.74128
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 16 B",
      "parent": {
        "id": "121200",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 16 B",
        "name": "Riyadh, Salahuddin Al Ayubi 16 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2511,
        "STOP_GLOBAL_ID": "121200",
        "STOPPOINT_GLOBAL_ID": "12120002",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 16 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 16 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 16 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12123502",
      "isGlobalId": true,
      "name": "Al Dharan 01",
      "type": "platform",
      "coord": [
        24.65348,
        46.73485
      ],
      "name": "Riyadh, Al Dharan 201",
      "parent": {
        "id": "121235",
        "isGlobalId": true,
        "disassembledName": "Al Dharan 201",
        "name": "Riyadh, Al Dharan 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2676,
        "STOP_GLOBAL_ID": "121235",
        "STOPPOINT_GLOBAL_ID": "12123502",
        "STOP_NAME_WITH_PLACE": "Al Dharan 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Dharan 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Dharan 201",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12720201",
      "isGlobalId": true,
      "name": "Al Kharj 01",
      "type": "platform",
      "coord": [
        24.63581,
        46.73703
      ],
      "name": "Riyadh, Al Kharj 101",
      "parent": {
        "id": "127202",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 101",
        "name": "Riyadh, Al Kharj 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2689,
        "STOP_GLOBAL_ID": "127202",
        "STOPPOINT_GLOBAL_ID": "12720201",
        "STOP_NAME_WITH_PLACE": "Al Kharj 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 101",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12123501",
      "isGlobalId": true,
      "name": "Al Dharan 01",
      "type": "platform",
      "coord": [
        24.65323,
        46.73448
      ],
      "name": "Riyadh, Al Dharan 101",
      "parent": {
        "id": "121235",
        "isGlobalId": true,
        "disassembledName": "Al Dharan 101",
        "name": "Riyadh, Al Dharan 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2707,
        "STOP_GLOBAL_ID": "121235",
        "STOPPOINT_GLOBAL_ID": "12123501",
        "STOP_NAME_WITH_PLACE": "Al Dharan 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Dharan 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Dharan 101",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12720202",
      "isGlobalId": true,
      "name": "Al Kharj 01",
      "type": "platform",
      "coord": [
        24.63417,
        46.7377
      ],
      "name": "Riyadh, Al Kharj 201",
      "parent": {
        "id": "127202",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 201",
        "name": "Riyadh, Al Kharj 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2735,
        "STOP_GLOBAL_ID": "127202",
        "STOPPOINT_GLOBAL_ID": "12720202",
        "STOP_NAME_WITH_PLACE": "Al Kharj 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 201",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12123301",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 08",
      "type": "platform",
      "coord": [
        24.6605,
        46.73725
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 108",
      "parent": {
        "id": "121233",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 108",
        "name": "Riyadh, Salahuddin Al Ayubi 108",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2824,
        "STOP_GLOBAL_ID": "121233",
        "STOPPOINT_GLOBAL_ID": "12123301",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 108",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 108",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14420101",
      "isGlobalId": true,
      "name": "Ali Ibn Abi Talib A",
      "type": "platform",
      "coord": [
        24.62485,
        46.76545
      ],
      "name": "Riyadh, Ali Ibn Abi Talib A",
      "parent": {
        "id": "144201",
        "isGlobalId": true,
        "disassembledName": "Ali Ibn Abi Talib A",
        "name": "Riyadh, Ali Ibn Abi Talib A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 2843,
        "STOP_GLOBAL_ID": "144201",
        "STOPPOINT_GLOBAL_ID": "14420101",
        "STOP_NAME_WITH_PLACE": "Ali Ibn Abi Talib A",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ali Ibn Abi Talib A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ali Ibn Abi Talib A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14320303",
      "isGlobalId": true,
      "name": "Al Kharj 02",
      "type": "platform",
      "coord": [
        24.62873,
        46.7396
      ],
      "name": "Riyadh, Al Kharj 102",
      "parent": {
        "id": "143203",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 102",
        "name": "Riyadh, Al Kharj 102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3020,
        "STOP_GLOBAL_ID": "143203",
        "STOPPOINT_GLOBAL_ID": "14320303",
        "STOP_NAME_WITH_PLACE": "Al Kharj 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 102",
        "IDENTIFIER": "3"
      }
    },
    {
      "id": "14320302",
      "isGlobalId": true,
      "name": "Al Kharj 02",
      "type": "platform",
      "coord": [
        24.62817,
        46.74023
      ],
      "name": "Riyadh, Al Kharj 202",
      "parent": {
        "id": "143203",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 202",
        "name": "Riyadh, Al Kharj 202",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3025,
        "STOP_GLOBAL_ID": "143203",
        "STOPPOINT_GLOBAL_ID": "14320302",
        "STOP_NAME_WITH_PLACE": "Al Kharj 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 202",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 202",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12123401",
      "isGlobalId": true,
      "name": "Al-Malaz 03",
      "type": "platform",
      "coord": [
        24.66628,
        46.74007
      ],
      "name": "Riyadh, Al-Malaz 503",
      "parent": {
        "id": "121234",
        "isGlobalId": true,
        "disassembledName": "Al-Malaz 503",
        "name": "Riyadh, Al-Malaz 503",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3078,
        "STOP_GLOBAL_ID": "121234",
        "STOPPOINT_GLOBAL_ID": "12123401",
        "STOP_NAME_WITH_PLACE": "Al-Malaz 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Malaz 503",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Malaz 503",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12520301",
      "isGlobalId": true,
      "name": "Omar Bin Al Khatab 03",
      "type": "platform",
      "coord": [
        24.64785,
        46.729
      ],
      "name": "Riyadh, Omar Bin Al Khatab 303",
      "parent": {
        "id": "125203",
        "isGlobalId": true,
        "disassembledName": "Omar Bin Al Khatab 303",
        "name": "Riyadh, Omar Bin Al Khatab 303",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3209,
        "STOP_GLOBAL_ID": "125203",
        "STOPPOINT_GLOBAL_ID": "12520301",
        "STOP_NAME_WITH_PLACE": "Omar Bin Al Khatab 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Omar Bin Al Khatab 303",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Omar Bin Al Khatab 303",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14320202",
      "isGlobalId": true,
      "name": "Al Kharj 04",
      "type": "platform",
      "coord": [
        24.62295,
        46.74561
      ],
      "name": "Riyadh, Al Kharj 204",
      "parent": {
        "id": "143202",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 204",
        "name": "Riyadh, Al Kharj 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3244,
        "STOP_GLOBAL_ID": "143202",
        "STOPPOINT_GLOBAL_ID": "14320202",
        "STOP_NAME_WITH_PLACE": "Al Kharj 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 204",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12120102",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 15 (BRT)",
      "type": "platform",
      "coord": [
        24.66248,
        46.73395
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 15 B",
      "parent": {
        "id": "121201",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 15 B",
        "name": "Riyadh, Salahuddin Al Ayubi 15 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3263,
        "STOP_GLOBAL_ID": "121201",
        "STOPPOINT_GLOBAL_ID": "12120102",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 15 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 15 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 15 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12120101",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 15 (BRT)",
      "type": "platform",
      "coord": [
        24.66243,
        46.73385
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 15 A",
      "parent": {
        "id": "121201",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 15 A",
        "name": "Riyadh, Salahuddin Al Ayubi 15 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3269,
        "STOP_GLOBAL_ID": "121201",
        "STOPPOINT_GLOBAL_ID": "12120101",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 15 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 15 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 15 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12123101",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 07",
      "type": "platform",
      "coord": [
        24.66248,
        46.73354
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 107",
      "parent": {
        "id": "121231",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 107",
        "name": "Riyadh, Salahuddin Al Ayubi 107",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3301,
        "STOP_GLOBAL_ID": "121231",
        "STOPPOINT_GLOBAL_ID": "12123101",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 107",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 107",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14320401",
      "isGlobalId": true,
      "name": "Al Kharj 03",
      "type": "platform",
      "coord": [
        24.62444,
        46.74156
      ],
      "name": "Riyadh, Al Kharj 103",
      "parent": {
        "id": "143204",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 103",
        "name": "Riyadh, Al Kharj 103",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3303,
        "STOP_GLOBAL_ID": "143204",
        "STOPPOINT_GLOBAL_ID": "14320401",
        "STOP_NAME_WITH_PLACE": "Al Kharj 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 103",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 103",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14320201",
      "isGlobalId": true,
      "name": "Al Kharj 04",
      "type": "platform",
      "coord": [
        24.62314,
        46.74336
      ],
      "name": "Riyadh, Al Kharj 104",
      "parent": {
        "id": "143202",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 104",
        "name": "Riyadh, Al Kharj 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3336,
        "STOP_GLOBAL_ID": "143202",
        "STOPPOINT_GLOBAL_ID": "14320201",
        "STOP_NAME_WITH_PLACE": "Al Kharj 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 104",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "13020401",
      "isGlobalId": true,
      "name": "Abi Ayoub Ansari 02",
      "type": "platform",
      "coord": [
        24.63896,
        46.7288
      ],
      "name": "Riyadh, Abi Ayoub Ansari 302",
      "parent": {
        "id": "130204",
        "isGlobalId": true,
        "disassembledName": "Abi Ayoub Ansari 302",
        "name": "Riyadh, Abi Ayoub Ansari 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3377,
        "STOP_GLOBAL_ID": "130204",
        "STOPPOINT_GLOBAL_ID": "13020401",
        "STOP_NAME_WITH_PLACE": "Abi Ayoub Ansari 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Abi Ayoub Ansari 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Abi Ayoub Ansari 302",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12520302",
      "isGlobalId": true,
      "name": "Omar Bin Al Khatab 03",
      "type": "platform",
      "coord": [
        24.64845,
        46.72744
      ],
      "name": "Riyadh, Omar Bin Al Khatab 403",
      "parent": {
        "id": "125203",
        "isGlobalId": true,
        "disassembledName": "Omar Bin Al Khatab 403",
        "name": "Riyadh, Omar Bin Al Khatab 403",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3386,
        "STOP_GLOBAL_ID": "125203",
        "STOPPOINT_GLOBAL_ID": "12520302",
        "STOP_NAME_WITH_PLACE": "Omar Bin Al Khatab 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Omar Bin Al Khatab 403",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Omar Bin Al Khatab 403",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14321001",
      "isGlobalId": true,
      "name": "Al Kharj 05",
      "type": "platform",
      "coord": [
        24.61959,
        46.75117
      ],
      "name": "Riyadh, Al Kharj 205",
      "parent": {
        "id": "143210",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 205",
        "name": "Riyadh, Al Kharj 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3437,
        "STOP_GLOBAL_ID": "143210",
        "STOPPOINT_GLOBAL_ID": "14321001",
        "STOP_NAME_WITH_PLACE": "Al Kharj 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 205",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14321201",
      "isGlobalId": true,
      "name": "Al Kharj 06",
      "type": "platform",
      "coord": [
        24.61771,
        46.75345
      ],
      "name": "Riyadh, Al Kharj 106",
      "parent": {
        "id": "143212",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 106",
        "name": "Riyadh, Al Kharj 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3619,
        "STOP_GLOBAL_ID": "143212",
        "STOPPOINT_GLOBAL_ID": "14321201",
        "STOP_NAME_WITH_PLACE": "Al Kharj 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 106",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14321101",
      "isGlobalId": true,
      "name": "Al Kharj 07",
      "type": "platform",
      "coord": [
        24.61671,
        46.75558
      ],
      "name": "Riyadh, Al Kharj 207",
      "parent": {
        "id": "143211",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 207",
        "name": "Riyadh, Al Kharj 207",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3718,
        "STOP_GLOBAL_ID": "143211",
        "STOPPOINT_GLOBAL_ID": "14321101",
        "STOP_NAME_WITH_PLACE": "Al Kharj 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 207",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 207",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14321102",
      "isGlobalId": true,
      "name": "Al Kharj 07",
      "type": "platform",
      "coord": [
        24.61553,
        46.75674
      ],
      "name": "Riyadh, Al Kharj 107",
      "parent": {
        "id": "143211",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 107",
        "name": "Riyadh, Al Kharj 107",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3855,
        "STOP_GLOBAL_ID": "143211",
        "STOPPOINT_GLOBAL_ID": "14321102",
        "STOP_NAME_WITH_PLACE": "Al Kharj 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 107",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 107",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12123201",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 06",
      "type": "platform",
      "coord": [
        24.66663,
        46.73069
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 106",
      "parent": {
        "id": "121232",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 106",
        "name": "Riyadh, Salahuddin Al Ayubi 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3859,
        "STOP_GLOBAL_ID": "121232",
        "STOPPOINT_GLOBAL_ID": "12123201",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 106",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12120202",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 14 (BRT)",
      "type": "platform",
      "coord": [
        24.66714,
        46.73071
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 14 B",
      "parent": {
        "id": "121202",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 14 B",
        "name": "Riyadh, Salahuddin Al Ayubi 14 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3897,
        "STOP_GLOBAL_ID": "121202",
        "STOPPOINT_GLOBAL_ID": "12120202",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 14 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 14 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 14 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12120201",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 14 (BRT)",
      "type": "platform",
      "coord": [
        24.66708,
        46.73061
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 14 A",
      "parent": {
        "id": "121202",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 14 A",
        "name": "Riyadh, Salahuddin Al Ayubi 14 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3901,
        "STOP_GLOBAL_ID": "121202",
        "STOPPOINT_GLOBAL_ID": "12120201",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 14 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 14 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 14 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12520201",
      "isGlobalId": true,
      "name": "Omar Bin Al Khatab 02",
      "type": "platform",
      "coord": [
        24.64972,
        46.722410000000007
      ],
      "name": "Riyadh, Omar Bin Al Khatab 402",
      "parent": {
        "id": "125202",
        "isGlobalId": true,
        "disassembledName": "Omar Bin Al Khatab 402",
        "name": "Riyadh, Omar Bin Al Khatab 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3955,
        "STOP_GLOBAL_ID": "125202",
        "STOPPOINT_GLOBAL_ID": "12520201",
        "STOP_NAME_WITH_PLACE": "Omar Bin Al Khatab 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Omar Bin Al Khatab 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Omar Bin Al Khatab 402",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12520202",
      "isGlobalId": true,
      "name": "Omar Bin Al Khatab 02",
      "type": "platform",
      "coord": [
        24.64958,
        46.72222
      ],
      "name": "Riyadh, Omar Bin Al Khatab 302",
      "parent": {
        "id": "125202",
        "isGlobalId": true,
        "disassembledName": "Omar Bin Al Khatab 302",
        "name": "Riyadh, Omar Bin Al Khatab 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 3974,
        "STOP_GLOBAL_ID": "125202",
        "STOPPOINT_GLOBAL_ID": "12520202",
        "STOP_NAME_WITH_PLACE": "Omar Bin Al Khatab 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Omar Bin Al Khatab 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Omar Bin Al Khatab 302",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12122202",
      "isGlobalId": true,
      "name": "Al Ahsa' 07",
      "type": "platform",
      "coord": [
        24.67301,
        46.73604
      ],
      "name": "Riyadh, Al Ahsa' 107",
      "parent": {
        "id": "121222",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 107",
        "name": "Riyadh, Al Ahsa' 107",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4003,
        "STOP_GLOBAL_ID": "121222",
        "STOPPOINT_GLOBAL_ID": "12122202",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 107",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 107",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12122201",
      "isGlobalId": true,
      "name": "Al Ahsa' 07",
      "type": "platform",
      "coord": [
        24.67344,
        46.73633
      ],
      "name": "Riyadh, Al Ahsa' 207",
      "parent": {
        "id": "121222",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 207",
        "name": "Riyadh, Al Ahsa' 207",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4025,
        "STOP_GLOBAL_ID": "121222",
        "STOPPOINT_GLOBAL_ID": "12122201",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 207",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 207",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "13020301",
      "isGlobalId": true,
      "name": "Abi Ayoub Ansari 01",
      "type": "platform",
      "coord": [
        24.6383,
        46.72249
      ],
      "name": "Riyadh, Abi Ayoub Ansari 301",
      "parent": {
        "id": "130203",
        "isGlobalId": true,
        "disassembledName": "Abi Ayoub Ansari 301",
        "name": "Riyadh, Abi Ayoub Ansari 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4074,
        "STOP_GLOBAL_ID": "130203",
        "STOPPOINT_GLOBAL_ID": "13020301",
        "STOP_NAME_WITH_PLACE": "Abi Ayoub Ansari 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Abi Ayoub Ansari 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Abi Ayoub Ansari 301",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14220401",
      "isGlobalId": true,
      "name": "Ammar Bin Yasir 02",
      "type": "platform",
      "coord": [
        24.6209,
        46.73471
      ],
      "name": "Riyadh, Ammar Bin Yasir 402",
      "parent": {
        "id": "142204",
        "isGlobalId": true,
        "disassembledName": "Ammar Bin Yasir 402",
        "name": "Riyadh, Ammar Bin Yasir 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4103,
        "STOP_GLOBAL_ID": "142204",
        "STOPPOINT_GLOBAL_ID": "14220401",
        "STOP_NAME_WITH_PLACE": "Ammar Bin Yasir 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ammar Bin Yasir 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ammar Bin Yasir 402",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12122401",
      "isGlobalId": true,
      "name": "Al Ahsa' 06",
      "type": "platform",
      "coord": [
        24.67594,
        46.73541
      ],
      "name": "Riyadh, Al Ahsa' 106",
      "parent": {
        "id": "121224",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 106",
        "name": "Riyadh, Al Ahsa' 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4334,
        "STOP_GLOBAL_ID": "121224",
        "STOPPOINT_GLOBAL_ID": "12122401",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 106",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12122402",
      "isGlobalId": true,
      "name": "Al Ahsa' 06",
      "type": "platform",
      "coord": [
        24.67626,
        46.73571
      ],
      "name": "Riyadh, Al Ahsa' 206",
      "parent": {
        "id": "121224",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 206",
        "name": "Riyadh, Al Ahsa' 206",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4347,
        "STOP_GLOBAL_ID": "121224",
        "STOPPOINT_GLOBAL_ID": "12122402",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 206",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 206",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12420302",
      "isGlobalId": true,
      "name": "Al Batha 01",
      "type": "platform",
      "coord": [
        24.64214,
        46.717
      ],
      "name": "Riyadh, Al Batha 101",
      "parent": {
        "id": "124203",
        "isGlobalId": true,
        "disassembledName": "Al Batha 101",
        "name": "Riyadh, Al Batha 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4582,
        "STOP_GLOBAL_ID": "124203",
        "STOPPOINT_GLOBAL_ID": "12420302",
        "STOP_NAME_WITH_PLACE": "Al Batha 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 101",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12520001",
      "isGlobalId": true,
      "name": "Omar Bin Al Khatab 01",
      "type": "platform",
      "coord": [
        24.65111,
        46.71676
      ],
      "name": "Riyadh, Omar Bin Al Khatab 401",
      "parent": {
        "id": "125200",
        "isGlobalId": true,
        "disassembledName": "Omar Bin Al Khatab 401",
        "name": "Riyadh, Omar Bin Al Khatab 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4598,
        "STOP_GLOBAL_ID": "125200",
        "STOPPOINT_GLOBAL_ID": "12520001",
        "STOP_NAME_WITH_PLACE": "Omar Bin Al Khatab 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Omar Bin Al Khatab 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Omar Bin Al Khatab 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12420301",
      "isGlobalId": true,
      "name": "Al Batha 01",
      "type": "platform",
      "coord": [
        24.64358,
        46.71661
      ],
      "name": "Riyadh, Al Batha 201",
      "parent": {
        "id": "124203",
        "isGlobalId": true,
        "disassembledName": "Al Batha 201",
        "name": "Riyadh, Al Batha 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4606,
        "STOP_GLOBAL_ID": "124203",
        "STOPPOINT_GLOBAL_ID": "12420301",
        "STOP_NAME_WITH_PLACE": "Al Batha 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 201",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12120303",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 13 (BRT)",
      "type": "platform",
      "coord": [
        24.67268,
        46.72756
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 105",
      "parent": {
        "id": "121203",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 105",
        "name": "Riyadh, Salahuddin Al Ayubi 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4608,
        "STOP_GLOBAL_ID": "121203",
        "STOPPOINT_GLOBAL_ID": "12120303",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 13 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 105",
        "IDENTIFIER": "3"
      }
    },
    {
      "id": "12120801",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 05",
      "type": "platform",
      "coord": [
        24.67268,
        46.72756
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 105",
      "parent": {
        "id": "121208",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 105",
        "name": "Riyadh, Salahuddin Al Ayubi 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4608,
        "STOP_GLOBAL_ID": "121208",
        "STOPPOINT_GLOBAL_ID": "12120801",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 105",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12120302",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 13 (BRT)",
      "type": "platform",
      "coord": [
        24.67305,
        46.72779
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 13 B",
      "parent": {
        "id": "121203",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 13 B",
        "name": "Riyadh, Salahuddin Al Ayubi 13 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4620,
        "STOP_GLOBAL_ID": "121203",
        "STOPPOINT_GLOBAL_ID": "12120302",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 13 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 13 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 13 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12120301",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 13 (BRT)",
      "type": "platform",
      "coord": [
        24.67302,
        46.72768
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 13 A",
      "parent": {
        "id": "121203",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 13 A",
        "name": "Riyadh, Salahuddin Al Ayubi 13 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4628,
        "STOP_GLOBAL_ID": "121203",
        "STOPPOINT_GLOBAL_ID": "12120301",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 13 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 13 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 13 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12520101",
      "isGlobalId": true,
      "name": "King Abdulaziz 15",
      "type": "platform",
      "coord": [
        24.65047,
        46.7161
      ],
      "name": "Riyadh, King Abdulaziz 215",
      "parent": {
        "id": "125201",
        "isGlobalId": true,
        "disassembledName": "King Abdulaziz 215",
        "name": "Riyadh, King Abdulaziz 215",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4663,
        "STOP_GLOBAL_ID": "125201",
        "STOPPOINT_GLOBAL_ID": "12520101",
        "STOP_NAME_WITH_PLACE": "King Abdulaziz 15",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdulaziz 215",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdulaziz 215",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12122501",
      "isGlobalId": true,
      "name": "Al Ahsa' 05",
      "type": "platform",
      "coord": [
        24.67881,
        46.73479
      ],
      "name": "Riyadh, Al Ahsa' 105",
      "parent": {
        "id": "121225",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 105",
        "name": "Riyadh, Al Ahsa' 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4664,
        "STOP_GLOBAL_ID": "121225",
        "STOPPOINT_GLOBAL_ID": "12122501",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 105",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12122502",
      "isGlobalId": true,
      "name": "Al Ahsa' 05",
      "type": "platform",
      "coord": [
        24.6791,
        46.7351
      ],
      "name": "Riyadh, Al Ahsa' 205",
      "parent": {
        "id": "121225",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 205",
        "name": "Riyadh, Al Ahsa' 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4674,
        "STOP_GLOBAL_ID": "121225",
        "STOPPOINT_GLOBAL_ID": "12122502",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 205",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14220301",
      "isGlobalId": true,
      "name": "Ammar Bin Yasir 01",
      "type": "platform",
      "coord": [
        24.619,
        46.729
      ],
      "name": "Riyadh, Ammar Bin Yasir 401",
      "parent": {
        "id": "142203",
        "isGlobalId": true,
        "disassembledName": "Ammar Bin Yasir 401",
        "name": "Riyadh, Ammar Bin Yasir 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4695,
        "STOP_GLOBAL_ID": "142203",
        "STOPPOINT_GLOBAL_ID": "14220301",
        "STOP_NAME_WITH_PLACE": "Ammar Bin Yasir 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ammar Bin Yasir 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ammar Bin Yasir 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "13020001",
      "isGlobalId": true,
      "name": "Al Batha 02",
      "type": "platform",
      "coord": [
        24.63481,
        46.71725
      ],
      "name": "Riyadh, Al Batha 202",
      "parent": {
        "id": "130200",
        "isGlobalId": true,
        "disassembledName": "Al Batha 202",
        "name": "Riyadh, Al Batha 202",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4756,
        "STOP_GLOBAL_ID": "130200",
        "STOPPOINT_GLOBAL_ID": "13020001",
        "STOP_NAME_WITH_PLACE": "Al Batha 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 202",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 202",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12420102",
      "isGlobalId": true,
      "name": "King Faisal 08 (Rd)",
      "type": "platform",
      "coord": [
        24.64071,
        46.71483
      ],
      "name": "Riyadh, King Faisal 208",
      "parent": {
        "id": "124201",
        "isGlobalId": true,
        "disassembledName": "King Faisal 208",
        "name": "Riyadh, King Faisal 208",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4847,
        "STOP_GLOBAL_ID": "124201",
        "STOPPOINT_GLOBAL_ID": "12420102",
        "STOP_NAME_WITH_PLACE": "King Faisal 08 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Faisal 208",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Faisal 208",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "13020002",
      "isGlobalId": true,
      "name": "Al Batha 02",
      "type": "platform",
      "coord": [
        24.63401,
        46.71651
      ],
      "name": "Riyadh, Al Batha 102",
      "parent": {
        "id": "130200",
        "isGlobalId": true,
        "disassembledName": "Al Batha 102",
        "name": "Riyadh, Al Batha 102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4866,
        "STOP_GLOBAL_ID": "130200",
        "STOPPOINT_GLOBAL_ID": "13020002",
        "STOP_NAME_WITH_PLACE": "Al Batha 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 102",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12420101",
      "isGlobalId": true,
      "name": "King Faisal 08 (Rd)",
      "type": "platform",
      "coord": [
        24.64048,
        46.71466
      ],
      "name": "Riyadh, King Faisal 108",
      "parent": {
        "id": "124201",
        "isGlobalId": true,
        "disassembledName": "King Faisal 108",
        "name": "Riyadh, King Faisal 108",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4870,
        "STOP_GLOBAL_ID": "124201",
        "STOPPOINT_GLOBAL_ID": "12420101",
        "STOP_NAME_WITH_PLACE": "King Faisal 08 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Faisal 108",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Faisal 108",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12123601",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 04",
      "type": "platform",
      "coord": [
        24.67541,
        46.72697
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 104",
      "parent": {
        "id": "121236",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 104",
        "name": "Riyadh, Salahuddin Al Ayubi 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4888,
        "STOP_GLOBAL_ID": "121236",
        "STOPPOINT_GLOBAL_ID": "12123601",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 104",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "13820102",
      "isGlobalId": true,
      "name": "Al Batha 04",
      "type": "platform",
      "coord": [
        24.62766,
        46.71921
      ],
      "name": "Riyadh, Al Batha 204",
      "parent": {
        "id": "138201",
        "isGlobalId": true,
        "disassembledName": "Al Batha 204",
        "name": "Riyadh, Al Batha 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4906,
        "STOP_GLOBAL_ID": "138201",
        "STOPPOINT_GLOBAL_ID": "13820102",
        "STOP_NAME_WITH_PLACE": "Al Batha 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 204",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "13820101",
      "isGlobalId": true,
      "name": "Al Batha 04",
      "type": "platform",
      "coord": [
        24.62755,
        46.71893
      ],
      "name": "Riyadh, Al Batha 104",
      "parent": {
        "id": "138201",
        "isGlobalId": true,
        "disassembledName": "Al Batha 104",
        "name": "Riyadh, Al Batha 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4941,
        "STOP_GLOBAL_ID": "138201",
        "STOPPOINT_GLOBAL_ID": "13820101",
        "STOP_NAME_WITH_PLACE": "Al Batha 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 104",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12920302",
      "isGlobalId": true,
      "name": "King Faisal 10 (Rd)",
      "type": "platform",
      "coord": [
        24.63418,
        46.71521
      ],
      "name": "Riyadh, King Faisal 210",
      "parent": {
        "id": "129203",
        "isGlobalId": true,
        "disassembledName": "King Faisal 210",
        "name": "Riyadh, King Faisal 210",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 4996,
        "STOP_GLOBAL_ID": "129203",
        "STOPPOINT_GLOBAL_ID": "12920302",
        "STOP_NAME_WITH_PLACE": "King Faisal 10 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Faisal 210",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Faisal 210",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12920301",
      "isGlobalId": true,
      "name": "King Faisal 10 (Rd)",
      "type": "platform",
      "coord": [
        24.63362,
        46.71507
      ],
      "name": "Riyadh, King Faisal 110",
      "parent": {
        "id": "129203",
        "isGlobalId": true,
        "disassembledName": "King Faisal 110",
        "name": "Riyadh, King Faisal 110",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5032,
        "STOP_GLOBAL_ID": "129203",
        "STOPPOINT_GLOBAL_ID": "12920301",
        "STOP_NAME_WITH_PLACE": "King Faisal 10 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Faisal 110",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Faisal 110",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12021302",
      "isGlobalId": true,
      "name": "Al-Muraba 10",
      "type": "platform",
      "coord": [
        24.65235,
        46.71289
      ],
      "name": "Riyadh, Al-Muraba 610",
      "parent": {
        "id": "120213",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 610",
        "name": "Riyadh, Al-Muraba 610",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5044,
        "STOP_GLOBAL_ID": "120213",
        "STOPPOINT_GLOBAL_ID": "12021302",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 610",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 610",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11820802",
      "isGlobalId": true,
      "name": "Al Ahsa' 04",
      "type": "platform",
      "coord": [
        24.68211,
        46.73411
      ],
      "name": "Riyadh, Al Ahsa' 104",
      "parent": {
        "id": "118208",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 104",
        "name": "Riyadh, Al Ahsa' 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5046,
        "STOP_GLOBAL_ID": "118208",
        "STOPPOINT_GLOBAL_ID": "11820802",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 104",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11820801",
      "isGlobalId": true,
      "name": "Al Ahsa' 04",
      "type": "platform",
      "coord": [
        24.68241,
        46.73442
      ],
      "name": "Riyadh, Al Ahsa' 204",
      "parent": {
        "id": "118208",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 204",
        "name": "Riyadh, Al Ahsa' 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5059,
        "STOP_GLOBAL_ID": "118208",
        "STOPPOINT_GLOBAL_ID": "11820801",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 204",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12021301",
      "isGlobalId": true,
      "name": "Al-Muraba 10",
      "type": "platform",
      "coord": [
        24.65211,
        46.71269
      ],
      "name": "Riyadh, Al-Muraba 510",
      "parent": {
        "id": "120213",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 510",
        "name": "Riyadh, Al-Muraba 510",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5062,
        "STOP_GLOBAL_ID": "120213",
        "STOPPOINT_GLOBAL_ID": "12021301",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 510",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 510",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12012102",
      "isGlobalId": true,
      "name": "Al-Muraba 11",
      "type": "platform",
      "coord": [
        24.65848,
        46.7134
      ],
      "name": "Riyadh, Al-Muraba 611",
      "parent": {
        "id": "120121",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 611",
        "name": "Riyadh, Al-Muraba 611",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5140,
        "STOP_GLOBAL_ID": "120121",
        "STOPPOINT_GLOBAL_ID": "12012102",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 11",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 611",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 611",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22521803",
      "isGlobalId": true,
      "name": "Al Kharj 09",
      "type": "platform",
      "coord": [
        24.60726,
        46.77422
      ],
      "name": "Riyadh, Al Kharj 109V",
      "parent": {
        "id": "225218",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 109V",
        "name": "Riyadh, Al Kharj 109V",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5198,
        "STOP_GLOBAL_ID": "225218",
        "STOPPOINT_GLOBAL_ID": "22521803",
        "STOP_NAME_WITH_PLACE": "Al Kharj 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 109V",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 109V",
        "IDENTIFIER": "3"
      }
    },
    {
      "id": "22521801",
      "isGlobalId": true,
      "name": "Al Kharj 09",
      "type": "platform",
      "coord": [
        24.60726,
        46.77422
      ],
      "name": "Riyadh, Al Kharj 109",
      "parent": {
        "id": "225218",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 109",
        "name": "Riyadh, Al Kharj 109",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5198,
        "STOP_GLOBAL_ID": "225218",
        "STOPPOINT_GLOBAL_ID": "22521801",
        "STOP_NAME_WITH_PLACE": "Al Kharj 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 109",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 109",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12021201",
      "isGlobalId": true,
      "name": "Al-Muraba 09",
      "type": "platform",
      "coord": [
        24.65547,
        46.71169
      ],
      "name": "Riyadh, Al-Muraba 609",
      "parent": {
        "id": "120212",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 609",
        "name": "Riyadh, Al-Muraba 609",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5238,
        "STOP_GLOBAL_ID": "120212",
        "STOPPOINT_GLOBAL_ID": "12021201",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 609",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 609",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22521802",
      "isGlobalId": true,
      "name": "Al Kharj 09",
      "type": "platform",
      "coord": [
        24.60676,
        46.77546
      ],
      "name": "Riyadh, Al Kharj 209",
      "parent": {
        "id": "225218",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 209",
        "name": "Riyadh, Al Kharj 209",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5305,
        "STOP_GLOBAL_ID": "225218",
        "STOPPOINT_GLOBAL_ID": "22521802",
        "STOP_NAME_WITH_PLACE": "Al Kharj 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 209",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 209",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11820902",
      "isGlobalId": true,
      "name": "Al Ahsa' 03",
      "type": "platform",
      "coord": [
        24.68513,
        46.73388
      ],
      "name": "Riyadh, Al Ahsa' 203",
      "parent": {
        "id": "118209",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 203",
        "name": "Riyadh, Al Ahsa' 203",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5377,
        "STOP_GLOBAL_ID": "118209",
        "STOPPOINT_GLOBAL_ID": "11820902",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 203",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 203",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11820901",
      "isGlobalId": true,
      "name": "Al Ahsa' 03",
      "type": "platform",
      "coord": [
        24.68506,
        46.73352
      ],
      "name": "Riyadh, Al Ahsa' 103",
      "parent": {
        "id": "118209",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 103",
        "name": "Riyadh, Al Ahsa' 103",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5390,
        "STOP_GLOBAL_ID": "118209",
        "STOPPOINT_GLOBAL_ID": "11820901",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 103",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 103",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12021001",
      "isGlobalId": true,
      "name": "Al-Muraba 08",
      "type": "platform",
      "coord": [
        24.65768,
        46.71058
      ],
      "name": "Riyadh, Al-Muraba 508",
      "parent": {
        "id": "120210",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 508",
        "name": "Riyadh, Al-Muraba 508",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5418,
        "STOP_GLOBAL_ID": "120210",
        "STOPPOINT_GLOBAL_ID": "12021001",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 508",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 508",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11821301",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 03",
      "type": "platform",
      "coord": [
        24.68051,
        46.72583
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 103",
      "parent": {
        "id": "118213",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 103",
        "name": "Riyadh, Salahuddin Al Ayubi 103",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5433,
        "STOP_GLOBAL_ID": "118213",
        "STOPPOINT_GLOBAL_ID": "11821301",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 103",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 103",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11820002",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 12 (BRT)",
      "type": "platform",
      "coord": [
        24.68127,
        46.72596
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 12 B",
      "parent": {
        "id": "118200",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 12 B",
        "name": "Riyadh, Salahuddin Al Ayubi 12 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5495,
        "STOP_GLOBAL_ID": "118200",
        "STOPPOINT_GLOBAL_ID": "11820002",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 12 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 12 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 12 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11820001",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 12 (BRT)",
      "type": "platform",
      "coord": [
        24.68124,
        46.72583
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 12 A",
      "parent": {
        "id": "118200",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 12 A",
        "name": "Riyadh, Salahuddin Al Ayubi 12 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5501,
        "STOP_GLOBAL_ID": "118200",
        "STOPPOINT_GLOBAL_ID": "11820001",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 12 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 12 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 12 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14620303",
      "isGlobalId": true,
      "name": "Al Batha 07",
      "type": "platform",
      "coord": [
        24.61018,
        46.72842
      ],
      "name": "Riyadh, Al Batha 107",
      "parent": {
        "id": "146203",
        "isGlobalId": true,
        "disassembledName": "Al Batha 107",
        "name": "Riyadh, Al Batha 107",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5571,
        "STOP_GLOBAL_ID": "146203",
        "STOPPOINT_GLOBAL_ID": "14620303",
        "STOP_NAME_WITH_PLACE": "Al Batha 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 107",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 107",
        "IDENTIFIER": "3"
      }
    },
    {
      "id": "12920201",
      "isGlobalId": true,
      "name": "Ad-Dirah 05",
      "type": "platform",
      "coord": [
        24.6317,
        46.71063
      ],
      "name": "Riyadh, Ad-Dirah 605",
      "parent": {
        "id": "129202",
        "isGlobalId": true,
        "disassembledName": "Ad-Dirah 605",
        "name": "Riyadh, Ad-Dirah 605",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5576,
        "STOP_GLOBAL_ID": "129202",
        "STOPPOINT_GLOBAL_ID": "12920201",
        "STOP_NAME_WITH_PLACE": "Ad-Dirah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ad-Dirah 605",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ad-Dirah 605",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12920202",
      "isGlobalId": true,
      "name": "Ad-Dirah 05",
      "type": "platform",
      "coord": [
        24.63144,
        46.71051
      ],
      "name": "Riyadh, Ad-Dirah 505",
      "parent": {
        "id": "129202",
        "isGlobalId": true,
        "disassembledName": "Ad-Dirah 505",
        "name": "Riyadh, Ad-Dirah 505",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5600,
        "STOP_GLOBAL_ID": "129202",
        "STOPPOINT_GLOBAL_ID": "12920202",
        "STOP_NAME_WITH_PLACE": "Ad-Dirah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ad-Dirah 505",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ad-Dirah 505",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14620301",
      "isGlobalId": true,
      "name": "Al Batha 07",
      "type": "platform",
      "coord": [
        24.60874,
        46.72971
      ],
      "name": "Riyadh, Al Batha 207",
      "parent": {
        "id": "146203",
        "isGlobalId": true,
        "disassembledName": "Al Batha 207",
        "name": "Riyadh, Al Batha 207",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5634,
        "STOP_GLOBAL_ID": "146203",
        "STOPPOINT_GLOBAL_ID": "14620301",
        "STOP_NAME_WITH_PLACE": "Al Batha 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 207",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 207",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12021802",
      "isGlobalId": true,
      "name": "Al Washm 01",
      "type": "platform",
      "coord": [
        24.65153,
        46.70666
      ],
      "name": "Riyadh, Al Washm 301",
      "parent": {
        "id": "120218",
        "isGlobalId": true,
        "disassembledName": "Al Washm 301",
        "name": "Riyadh, Al Washm 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5721,
        "STOP_GLOBAL_ID": "120218",
        "STOPPOINT_GLOBAL_ID": "12021802",
        "STOP_NAME_WITH_PLACE": "Al Washm 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Washm 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Washm 301",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11821002",
      "isGlobalId": true,
      "name": "Al Ahsa' 02",
      "type": "platform",
      "coord": [
        24.68848,
        46.7332
      ],
      "name": "Riyadh, Al Ahsa' 202",
      "parent": {
        "id": "118210",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 202",
        "name": "Riyadh, Al Ahsa' 202",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5773,
        "STOP_GLOBAL_ID": "118210",
        "STOPPOINT_GLOBAL_ID": "11821002",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 202",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 202",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11821401",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 02",
      "type": "platform",
      "coord": [
        24.68385,
        46.72507
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 102",
      "parent": {
        "id": "118214",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 102",
        "name": "Riyadh, Salahuddin Al Ayubi 102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5801,
        "STOP_GLOBAL_ID": "118214",
        "STOPPOINT_GLOBAL_ID": "11821401",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 102",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11821001",
      "isGlobalId": true,
      "name": "Al Ahsa' 02",
      "type": "platform",
      "coord": [
        24.68863,
        46.73281
      ],
      "name": "Riyadh, Al Ahsa' 102",
      "parent": {
        "id": "118210",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 102",
        "name": "Riyadh, Al Ahsa' 102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5809,
        "STOP_GLOBAL_ID": "118210",
        "STOPPOINT_GLOBAL_ID": "11821001",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 102",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12021801",
      "isGlobalId": true,
      "name": "Al Washm 01",
      "type": "platform",
      "coord": [
        24.65153,
        46.70568
      ],
      "name": "Riyadh, Al Washm 401",
      "parent": {
        "id": "120218",
        "isGlobalId": true,
        "disassembledName": "Al Washm 401",
        "name": "Riyadh, Al Washm 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5830,
        "STOP_GLOBAL_ID": "120218",
        "STOPPOINT_GLOBAL_ID": "12021801",
        "STOP_NAME_WITH_PLACE": "Al Washm 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Washm 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Washm 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11820102",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 11 (BRT)",
      "type": "platform",
      "coord": [
        24.68434,
        46.72521
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 11 B",
      "parent": {
        "id": "118201",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 11 B",
        "name": "Riyadh, Salahuddin Al Ayubi 11 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5839,
        "STOP_GLOBAL_ID": "118201",
        "STOPPOINT_GLOBAL_ID": "11820102",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 11 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 11 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 11 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11820101",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 11 (BRT)",
      "type": "platform",
      "coord": [
        24.68432,
        46.7251
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 11 A",
      "parent": {
        "id": "118201",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 11 A",
        "name": "Riyadh, Salahuddin Al Ayubi 11 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5845,
        "STOP_GLOBAL_ID": "118201",
        "STOPPOINT_GLOBAL_ID": "11820101",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 11 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 11 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 11 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12020602",
      "isGlobalId": true,
      "name": "Al-Muraba 02",
      "type": "platform",
      "coord": [
        24.6655,
        46.70928
      ],
      "name": "Riyadh, Al-Muraba 602",
      "parent": {
        "id": "120206",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 602",
        "name": "Riyadh, Al-Muraba 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5859,
        "STOP_GLOBAL_ID": "120206",
        "STOPPOINT_GLOBAL_ID": "12020602",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 602",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "12020601",
      "isGlobalId": true,
      "name": "Al-Muraba 02",
      "type": "platform",
      "coord": [
        24.66497,
        46.70873
      ],
      "name": "Riyadh, Al-Muraba 502",
      "parent": {
        "id": "120206",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 502",
        "name": "Riyadh, Al-Muraba 502",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 5890,
        "STOP_GLOBAL_ID": "120206",
        "STOPPOINT_GLOBAL_ID": "12020601",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 502",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 502",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "21920302",
      "isGlobalId": true,
      "name": "Al Kharj 10",
      "type": "platform",
      "coord": [
        24.60304,
        46.78209
      ],
      "name": "Riyadh, Al Kharj 210",
      "parent": {
        "id": "219203",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 210",
        "name": "Riyadh, Al Kharj 210",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6024,
        "STOP_GLOBAL_ID": "219203",
        "STOPPOINT_GLOBAL_ID": "21920302",
        "STOP_NAME_WITH_PLACE": "Al Kharj 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 210",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 210",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11620101",
      "isGlobalId": true,
      "name": "Al-Muraba 06",
      "type": "platform",
      "coord": [
        24.6657,
        46.70772
      ],
      "name": "Riyadh, Al-Muraba 606",
      "parent": {
        "id": "116201",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 606",
        "name": "Riyadh, Al-Muraba 606",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6028,
        "STOP_GLOBAL_ID": "116201",
        "STOPPOINT_GLOBAL_ID": "11620101",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 606",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 606",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "21920301",
      "isGlobalId": true,
      "name": "Al Kharj 10",
      "type": "platform",
      "coord": [
        24.60277,
        46.78193
      ],
      "name": "Riyadh, Al Kharj 110",
      "parent": {
        "id": "219203",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 110",
        "name": "Riyadh, Al Kharj 110",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6046,
        "STOP_GLOBAL_ID": "219203",
        "STOPPOINT_GLOBAL_ID": "21920301",
        "STOP_NAME_WITH_PLACE": "Al Kharj 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 110",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 110",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11620102",
      "isGlobalId": true,
      "name": "Al-Muraba 06",
      "type": "platform",
      "coord": [
        24.66601,
        46.7073
      ],
      "name": "Riyadh, Al-Muraba 506",
      "parent": {
        "id": "116201",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 506",
        "name": "Riyadh, Al-Muraba 506",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6086,
        "STOP_GLOBAL_ID": "116201",
        "STOPPOINT_GLOBAL_ID": "11620102",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 506",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 506",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22520005",
      "isGlobalId": true,
      "name": "Transportation Center",
      "type": "platform",
      "coord": [
        24.59792,
        46.74848
      ],
      "name": "Riyadh, Transportation Center C",
      "parent": {
        "id": "225200",
        "isGlobalId": true,
        "disassembledName": "Transportation Center C",
        "name": "Riyadh, Transportation Center C",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6100,
        "STOP_GLOBAL_ID": "225200",
        "STOPPOINT_GLOBAL_ID": "22520005",
        "STOP_NAME_WITH_PLACE": "Transportation Center",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Transportation Center C",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Transportation Center C",
        "IDENTIFIER": "5"
      }
    },
    {
      "id": "14720401",
      "isGlobalId": true,
      "name": "Al Batha 08",
      "type": "platform",
      "coord": [
        24.60235,
        46.73286
      ],
      "name": "Riyadh, Al Batha 208",
      "parent": {
        "id": "147204",
        "isGlobalId": true,
        "disassembledName": "Al Batha 208",
        "name": "Riyadh, Al Batha 208",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6133,
        "STOP_GLOBAL_ID": "147204",
        "STOPPOINT_GLOBAL_ID": "14720401",
        "STOP_NAME_WITH_PLACE": "Al Batha 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 208",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 208",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14720402",
      "isGlobalId": true,
      "name": "Al Batha 08",
      "type": "platform",
      "coord": [
        24.60256,
        46.73237
      ],
      "name": "Riyadh, Al Batha 108",
      "parent": {
        "id": "147204",
        "isGlobalId": true,
        "disassembledName": "Al Batha 108",
        "name": "Riyadh, Al Batha 108",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6134,
        "STOP_GLOBAL_ID": "147204",
        "STOPPOINT_GLOBAL_ID": "14720402",
        "STOP_NAME_WITH_PLACE": "Al Batha 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 108",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 108",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11821102",
      "isGlobalId": true,
      "name": "Al Ahsa' 01",
      "type": "platform",
      "coord": [
        24.69163,
        46.73257
      ],
      "name": "Riyadh, Al Ahsa' 201",
      "parent": {
        "id": "118211",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 201",
        "name": "Riyadh, Al Ahsa' 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6147,
        "STOP_GLOBAL_ID": "118211",
        "STOPPOINT_GLOBAL_ID": "11821102",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 201",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22520004",
      "isGlobalId": true,
      "name": "Transportation Center",
      "type": "platform",
      "coord": [
        24.59764,
        46.74778
      ],
      "name": "Riyadh, Transportation Center B",
      "parent": {
        "id": "225200",
        "isGlobalId": true,
        "disassembledName": "Transportation Center B",
        "name": "Riyadh, Transportation Center B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6147,
        "STOP_GLOBAL_ID": "225200",
        "STOPPOINT_GLOBAL_ID": "22520004",
        "STOP_NAME_WITH_PLACE": "Transportation Center",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Transportation Center B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Transportation Center B",
        "IDENTIFIER": "4"
      }
    },
    {
      "id": "11821101",
      "isGlobalId": true,
      "name": "Al Ahsa' 01",
      "type": "platform",
      "coord": [
        24.69182,
        46.73218
      ],
      "name": "Riyadh, Al Ahsa' 101",
      "parent": {
        "id": "118211",
        "isGlobalId": true,
        "disassembledName": "Al Ahsa' 101",
        "name": "Riyadh, Al Ahsa' 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6187,
        "STOP_GLOBAL_ID": "118211",
        "STOPPOINT_GLOBAL_ID": "11821101",
        "STOP_NAME_WITH_PLACE": "Al Ahsa' 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Ahsa' 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Ahsa' 101",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22520001",
      "isGlobalId": true,
      "name": "Transportation Center",
      "type": "platform",
      "coord": [
        24.59736,
        46.74722
      ],
      "name": "Riyadh, Transportation Center",
      "parent": {
        "id": "225200",
        "isGlobalId": true,
        "disassembledName": "Transportation Center",
        "name": "Riyadh, Transportation Center",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6192,
        "STOP_GLOBAL_ID": "225200",
        "STOPPOINT_GLOBAL_ID": "22520001",
        "STOP_NAME_WITH_PLACE": "Transportation Center",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Transportation Center",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Transportation Center",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22520003",
      "isGlobalId": true,
      "name": "Transportation Center",
      "type": "platform",
      "coord": [
        24.59733,
        46.7472
      ],
      "name": "Riyadh, Transportation Center A",
      "parent": {
        "id": "225200",
        "isGlobalId": true,
        "disassembledName": "Transportation Center A",
        "name": "Riyadh, Transportation Center A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6196,
        "STOP_GLOBAL_ID": "225200",
        "STOPPOINT_GLOBAL_ID": "22520003",
        "STOP_NAME_WITH_PLACE": "Transportation Center",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Transportation Center A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Transportation Center A",
        "IDENTIFIER": "3"
      }
    },
    {
      "id": "22520501",
      "isGlobalId": true,
      "name": "Abi Saad Al Wazir 01",
      "type": "platform",
      "coord": [
        24.59686,
        46.74981
      ],
      "name": "Riyadh, Abi Saad Al Wazir 201",
      "parent": {
        "id": "225205",
        "isGlobalId": true,
        "disassembledName": "Abi Saad Al Wazir 201",
        "name": "Riyadh, Abi Saad Al Wazir 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6205,
        "STOP_GLOBAL_ID": "225205",
        "STOPPOINT_GLOBAL_ID": "22520501",
        "STOP_NAME_WITH_PLACE": "Abi Saad Al Wazir 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Abi Saad Al Wazir 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Abi Saad Al Wazir 201",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11821501",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 01",
      "type": "platform",
      "coord": [
        24.68831,
        46.72399
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 101",
      "parent": {
        "id": "118215",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 101",
        "name": "Riyadh, Salahuddin Al Ayubi 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6307,
        "STOP_GLOBAL_ID": "118215",
        "STOPPOINT_GLOBAL_ID": "11821501",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 101",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22520702",
      "isGlobalId": true,
      "name": "Al-Basala 02",
      "type": "platform",
      "coord": [
        24.59527,
        46.75404
      ],
      "name": "Riyadh, Al-Basala 402",
      "parent": {
        "id": "225207",
        "isGlobalId": true,
        "disassembledName": "Al-Basala 402",
        "name": "Riyadh, Al-Basala 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6348,
        "STOP_GLOBAL_ID": "225207",
        "STOPPOINT_GLOBAL_ID": "22520702",
        "STOP_NAME_WITH_PLACE": "Al-Basala 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Basala 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Basala 402",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22520701",
      "isGlobalId": true,
      "name": "Al-Basala 02",
      "type": "platform",
      "coord": [
        24.59525,
        46.75462
      ],
      "name": "Riyadh, Al-Basala 302",
      "parent": {
        "id": "225207",
        "isGlobalId": true,
        "disassembledName": "Al-Basala 302",
        "name": "Riyadh, Al-Basala 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6348,
        "STOP_GLOBAL_ID": "225207",
        "STOPPOINT_GLOBAL_ID": "22520701",
        "STOP_NAME_WITH_PLACE": "Al-Basala 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Basala 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Basala 302",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12020901",
      "isGlobalId": true,
      "name": "Al-Muraba 05",
      "type": "platform",
      "coord": [
        24.66952,
        46.70624
      ],
      "name": "Riyadh, Al-Muraba 605",
      "parent": {
        "id": "120209",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 605",
        "name": "Riyadh, Al-Muraba 605",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6369,
        "STOP_GLOBAL_ID": "120209",
        "STOPPOINT_GLOBAL_ID": "12020901",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 605",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 605",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16020001",
      "isGlobalId": true,
      "name": "Ash-Shomaisi 02",
      "type": "platform",
      "coord": [
        24.63092,
        46.70301
      ],
      "name": "Riyadh, Ash-Shomaisi 602",
      "parent": {
        "id": "160200",
        "isGlobalId": true,
        "disassembledName": "Ash-Shomaisi 602",
        "name": "Riyadh, Ash-Shomaisi 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6411,
        "STOP_GLOBAL_ID": "160200",
        "STOPPOINT_GLOBAL_ID": "16020001",
        "STOP_NAME_WITH_PLACE": "Ash-Shomaisi 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Shomaisi 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Shomaisi 602",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16320501",
      "isGlobalId": true,
      "name": "Ash-Shomaisi 05",
      "type": "platform",
      "coord": [
        24.62871,
        46.70354
      ],
      "name": "Riyadh, Ash-Shomaisi 505",
      "parent": {
        "id": "163205",
        "isGlobalId": true,
        "disassembledName": "Ash-Shomaisi 505",
        "name": "Riyadh, Ash-Shomaisi 505",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6444,
        "STOP_GLOBAL_ID": "163205",
        "STOPPOINT_GLOBAL_ID": "16320501",
        "STOP_NAME_WITH_PLACE": "Ash-Shomaisi 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Shomaisi 505",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Shomaisi 505",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14720201",
      "isGlobalId": true,
      "name": "Al Batha 09",
      "type": "platform",
      "coord": [
        24.59878,
        46.7343
      ],
      "name": "Riyadh, Al Batha 109",
      "parent": {
        "id": "147202",
        "isGlobalId": true,
        "disassembledName": "Al Batha 109",
        "name": "Riyadh, Al Batha 109",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6459,
        "STOP_GLOBAL_ID": "147202",
        "STOPPOINT_GLOBAL_ID": "14720201",
        "STOP_NAME_WITH_PLACE": "Al Batha 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 109",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 109",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "12020902",
      "isGlobalId": true,
      "name": "Al-Muraba 05",
      "type": "platform",
      "coord": [
        24.67074,
        46.7055
      ],
      "name": "Riyadh, Al-Muraba 505",
      "parent": {
        "id": "120209",
        "isGlobalId": true,
        "disassembledName": "Al-Muraba 505",
        "name": "Riyadh, Al-Muraba 505",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6508,
        "STOP_GLOBAL_ID": "120209",
        "STOPPOINT_GLOBAL_ID": "12020902",
        "STOP_NAME_WITH_PLACE": "Al-Muraba 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Muraba 505",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Muraba 505",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14620201",
      "isGlobalId": true,
      "name": "Al Faryan 03",
      "type": "platform",
      "coord": [
        24.6059,
        46.7207
      ],
      "name": "Riyadh, Al Faryan 203",
      "parent": {
        "id": "146202",
        "isGlobalId": true,
        "disassembledName": "Al Faryan 203",
        "name": "Riyadh, Al Faryan 203",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6511,
        "STOP_GLOBAL_ID": "146202",
        "STOPPOINT_GLOBAL_ID": "14620201",
        "STOP_NAME_WITH_PLACE": "Al Faryan 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Faryan 203",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Faryan 203",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14620202",
      "isGlobalId": true,
      "name": "Al Faryan 03",
      "type": "platform",
      "coord": [
        24.60623,
        46.7201
      ],
      "name": "Riyadh, Al Faryan 103",
      "parent": {
        "id": "146202",
        "isGlobalId": true,
        "disassembledName": "Al Faryan 103",
        "name": "Riyadh, Al Faryan 103",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6523,
        "STOP_GLOBAL_ID": "146202",
        "STOPPOINT_GLOBAL_ID": "14620202",
        "STOP_NAME_WITH_PLACE": "Al Faryan 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Faryan 103",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Faryan 103",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14520101",
      "isGlobalId": true,
      "name": "Al-Yamamah 02",
      "type": "platform",
      "coord": [
        24.60706,
        46.71846
      ],
      "name": "Riyadh, Al-Yamamah 602",
      "parent": {
        "id": "145201",
        "isGlobalId": true,
        "disassembledName": "Al-Yamamah 602",
        "name": "Riyadh, Al-Yamamah 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6566,
        "STOP_GLOBAL_ID": "145201",
        "STOPPOINT_GLOBAL_ID": "14520101",
        "STOP_NAME_WITH_PLACE": "Al-Yamamah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Yamamah 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Yamamah 602",
        "IDENTIFIER": "4"
      }
    },
    {
      "id": "14720301",
      "isGlobalId": true,
      "name": "Al Batha 10",
      "type": "platform",
      "coord": [
        24.59674,
        46.73575
      ],
      "name": "Riyadh, Al Batha 210",
      "parent": {
        "id": "147203",
        "isGlobalId": true,
        "disassembledName": "Al Batha 210",
        "name": "Riyadh, Al Batha 210",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6626,
        "STOP_GLOBAL_ID": "147203",
        "STOPPOINT_GLOBAL_ID": "14720301",
        "STOP_NAME_WITH_PLACE": "Al Batha 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Batha 210",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Batha 210",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14520102",
      "isGlobalId": true,
      "name": "Al-Yamamah 02",
      "type": "platform",
      "coord": [
        24.60622,
        46.71737
      ],
      "name": "Riyadh, Al-Yamamah 502",
      "parent": {
        "id": "145201",
        "isGlobalId": true,
        "disassembledName": "Al-Yamamah 502",
        "name": "Riyadh, Al-Yamamah 502",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6724,
        "STOP_GLOBAL_ID": "145201",
        "STOPPOINT_GLOBAL_ID": "14520102",
        "STOP_NAME_WITH_PLACE": "Al-Yamamah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Yamamah 502",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Yamamah 502",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11820702",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 02",
      "type": "platform",
      "coord": [
        24.6937,
        46.72524
      ],
      "name": "Riyadh, Makkah Al Mukarramah 302",
      "parent": {
        "id": "118207",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 302",
        "name": "Riyadh, Makkah Al Mukarramah 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6773,
        "STOP_GLOBAL_ID": "118207",
        "STOPPOINT_GLOBAL_ID": "11820702",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 302",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "21920402",
      "isGlobalId": true,
      "name": "Al Kharj 11",
      "type": "platform",
      "coord": [
        24.5995,
        46.78905
      ],
      "name": "Riyadh, Al Kharj 211",
      "parent": {
        "id": "219204",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 211",
        "name": "Riyadh, Al Kharj 211",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6777,
        "STOP_GLOBAL_ID": "219204",
        "STOPPOINT_GLOBAL_ID": "21920402",
        "STOP_NAME_WITH_PLACE": "Al Kharj 11",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 211",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 211",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "21920401",
      "isGlobalId": true,
      "name": "Al Kharj 11",
      "type": "platform",
      "coord": [
        24.59928,
        46.78869
      ],
      "name": "Riyadh, Al Kharj 111",
      "parent": {
        "id": "219204",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 111",
        "name": "Riyadh, Al Kharj 111",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6779,
        "STOP_GLOBAL_ID": "219204",
        "STOPPOINT_GLOBAL_ID": "21920401",
        "STOP_NAME_WITH_PLACE": "Al Kharj 11",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 111",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 111",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11820202",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 10 (BRT)",
      "type": "platform",
      "coord": [
        24.69287,
        46.72319
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 10 A",
      "parent": {
        "id": "118202",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 10 A",
        "name": "Riyadh, Salahuddin Al Ayubi 10 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6813,
        "STOP_GLOBAL_ID": "118202",
        "STOPPOINT_GLOBAL_ID": "11820202",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 10 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 10 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 10 A",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11920501",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 03",
      "type": "platform",
      "coord": [
        24.70014,
        46.73965
      ],
      "name": "Riyadh, Makkah Al Mukarramah 303",
      "parent": {
        "id": "119205",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 303",
        "name": "Riyadh, Makkah Al Mukarramah 303",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6816,
        "STOP_GLOBAL_ID": "119205",
        "STOPPOINT_GLOBAL_ID": "11920501",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 303",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 303",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11820201",
      "isGlobalId": true,
      "name": "Salahuddin Al Ayubi 10 (BRT)",
      "type": "platform",
      "coord": [
        24.69306,
        46.72333
      ],
      "name": "Riyadh, Salahuddin Al Ayubi 10 B",
      "parent": {
        "id": "118202",
        "isGlobalId": true,
        "disassembledName": "Salahuddin Al Ayubi 10 B",
        "name": "Riyadh, Salahuddin Al Ayubi 10 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6825,
        "STOP_GLOBAL_ID": "118202",
        "STOPPOINT_GLOBAL_ID": "11820201",
        "STOP_NAME_WITH_PLACE": "Salahuddin Al Ayubi 10 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Salahuddin Al Ayubi 10 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Salahuddin Al Ayubi 10 B",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11820701",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 02",
      "type": "platform",
      "coord": [
        24.69416,
        46.72497
      ],
      "name": "Riyadh, Makkah Al Mukarramah 402",
      "parent": {
        "id": "118207",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 402",
        "name": "Riyadh, Makkah Al Mukarramah 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6836,
        "STOP_GLOBAL_ID": "118207",
        "STOPPOINT_GLOBAL_ID": "11820701",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 402",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11920502",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 03",
      "type": "platform",
      "coord": [
        24.70023,
        46.73862
      ],
      "name": "Riyadh, Makkah Al Mukarramah 403",
      "parent": {
        "id": "119205",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 403",
        "name": "Riyadh, Makkah Al Mukarramah 403",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6862,
        "STOP_GLOBAL_ID": "119205",
        "STOPPOINT_GLOBAL_ID": "11920502",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 403",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 403",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22520301",
      "isGlobalId": true,
      "name": "Al Haeer 01",
      "type": "platform",
      "coord": [
        24.59293,
        46.73812
      ],
      "name": "Riyadh, Al Haeer 101",
      "parent": {
        "id": "225203",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 101",
        "name": "Riyadh, Al Haeer 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6975,
        "STOP_GLOBAL_ID": "225203",
        "STOPPOINT_GLOBAL_ID": "22520301",
        "STOP_NAME_WITH_PLACE": "Al Haeer 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 101",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16320401",
      "isGlobalId": true,
      "name": "Ash-Shomaisi 04",
      "type": "platform",
      "coord": [
        24.62804,
        46.69865
      ],
      "name": "Riyadh, Ash-Shomaisi 504",
      "parent": {
        "id": "163204",
        "isGlobalId": true,
        "disassembledName": "Ash-Shomaisi 504",
        "name": "Riyadh, Ash-Shomaisi 504",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6983,
        "STOP_GLOBAL_ID": "163204",
        "STOPPOINT_GLOBAL_ID": "16320401",
        "STOP_NAME_WITH_PLACE": "Ash-Shomaisi 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Shomaisi 504",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Shomaisi 504",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14520201",
      "isGlobalId": true,
      "name": "Al-Yamamah 01",
      "type": "platform",
      "coord": [
        24.6061,
        46.71407
      ],
      "name": "Riyadh, Al-Yamamah 601",
      "parent": {
        "id": "145202",
        "isGlobalId": true,
        "disassembledName": "Al-Yamamah 601",
        "name": "Riyadh, Al-Yamamah 601",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6986,
        "STOP_GLOBAL_ID": "145202",
        "STOPPOINT_GLOBAL_ID": "14520201",
        "STOP_NAME_WITH_PLACE": "Al-Yamamah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Yamamah 601",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Yamamah 601",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22520302",
      "isGlobalId": true,
      "name": "Al Haeer 01",
      "type": "platform",
      "coord": [
        24.59255,
        46.73888
      ],
      "name": "Riyadh, Al Haeer 201",
      "parent": {
        "id": "225203",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 201",
        "name": "Riyadh, Al Haeer 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 6993,
        "STOP_GLOBAL_ID": "225203",
        "STOPPOINT_GLOBAL_ID": "22520302",
        "STOP_NAME_WITH_PLACE": "Al Haeer 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 201",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16020101",
      "isGlobalId": true,
      "name": "Ash-Shomaisi 01",
      "type": "platform",
      "coord": [
        24.63038,
        46.69754
      ],
      "name": "Riyadh, Ash-Shomaisi 601",
      "parent": {
        "id": "160201",
        "isGlobalId": true,
        "disassembledName": "Ash-Shomaisi 601",
        "name": "Riyadh, Ash-Shomaisi 601",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7012,
        "STOP_GLOBAL_ID": "160201",
        "STOPPOINT_GLOBAL_ID": "16020101",
        "STOP_NAME_WITH_PLACE": "Ash-Shomaisi 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Shomaisi 601",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Shomaisi 601",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14520202",
      "isGlobalId": true,
      "name": "Al-Yamamah 01",
      "type": "platform",
      "coord": [
        24.6059,
        46.71233
      ],
      "name": "Riyadh, Al-Yamamah 501",
      "parent": {
        "id": "145202",
        "isGlobalId": true,
        "disassembledName": "Al-Yamamah 501",
        "name": "Riyadh, Al-Yamamah 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7139,
        "STOP_GLOBAL_ID": "145202",
        "STOPPOINT_GLOBAL_ID": "14520202",
        "STOP_NAME_WITH_PLACE": "Al-Yamamah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Yamamah 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Yamamah 501",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14520002",
      "isGlobalId": true,
      "name": "Al Faryan 04",
      "type": "platform",
      "coord": [
        24.59794,
        46.72224
      ],
      "name": "Riyadh, Al Faryan 104",
      "parent": {
        "id": "145200",
        "isGlobalId": true,
        "disassembledName": "Al Faryan 104",
        "name": "Riyadh, Al Faryan 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7195,
        "STOP_GLOBAL_ID": "145200",
        "STOPPOINT_GLOBAL_ID": "14520002",
        "STOP_NAME_WITH_PLACE": "Al Faryan 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Faryan 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Faryan 104",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15820001",
      "isGlobalId": true,
      "name": "Al-Fakhiriyah 01",
      "type": "platform",
      "coord": [
        24.64358,
        46.69314
      ],
      "name": "Riyadh, Al-Fakhiriyah 601",
      "parent": {
        "id": "158200",
        "isGlobalId": true,
        "disassembledName": "Al-Fakhiriyah 601",
        "name": "Riyadh, Al-Fakhiriyah 601",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7211,
        "STOP_GLOBAL_ID": "158200",
        "STOPPOINT_GLOBAL_ID": "15820001",
        "STOP_NAME_WITH_PLACE": "Al-Fakhiriyah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Fakhiriyah 601",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Fakhiriyah 601",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15820002",
      "isGlobalId": true,
      "name": "Al-Fakhiriyah 01",
      "type": "platform",
      "coord": [
        24.64506,
        46.69296
      ],
      "name": "Riyadh, Al-Fakhiriyah 501",
      "parent": {
        "id": "158200",
        "isGlobalId": true,
        "disassembledName": "Al-Fakhiriyah 501",
        "name": "Riyadh, Al-Fakhiriyah 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7223,
        "STOP_GLOBAL_ID": "158200",
        "STOPPOINT_GLOBAL_ID": "15820002",
        "STOP_NAME_WITH_PLACE": "Al-Fakhiriyah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Fakhiriyah 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Fakhiriyah 501",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11922002",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 04",
      "type": "platform",
      "coord": [
        24.70529,
        46.74755
      ],
      "name": "Riyadh, Makkah Al Mukarramah 304",
      "parent": {
        "id": "119220",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 304",
        "name": "Riyadh, Makkah Al Mukarramah 304",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7231,
        "STOP_GLOBAL_ID": "119220",
        "STOPPOINT_GLOBAL_ID": "11922002",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 304",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 304",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14520001",
      "isGlobalId": true,
      "name": "Al Faryan 04",
      "type": "platform",
      "coord": [
        24.59706,
        46.72257
      ],
      "name": "Riyadh, Al Faryan 204",
      "parent": {
        "id": "145200",
        "isGlobalId": true,
        "disassembledName": "Al Faryan 204",
        "name": "Riyadh, Al Faryan 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7266,
        "STOP_GLOBAL_ID": "145200",
        "STOPPOINT_GLOBAL_ID": "14520001",
        "STOP_NAME_WITH_PLACE": "Al Faryan 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Faryan 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Faryan 204",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15920401",
      "isGlobalId": true,
      "name": "Olaishah 01",
      "type": "platform",
      "coord": [
        24.63962,
        46.6927
      ],
      "name": "Riyadh, Olaishah 501",
      "parent": {
        "id": "159204",
        "isGlobalId": true,
        "disassembledName": "Olaishah 501",
        "name": "Riyadh, Olaishah 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7304,
        "STOP_GLOBAL_ID": "159204",
        "STOPPOINT_GLOBAL_ID": "15920401",
        "STOP_NAME_WITH_PLACE": "Olaishah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaishah 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaishah 501",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11922001",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 04",
      "type": "platform",
      "coord": [
        24.706,
        46.74746
      ],
      "name": "Riyadh, Makkah Al Mukarramah 404",
      "parent": {
        "id": "119220",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 404",
        "name": "Riyadh, Makkah Al Mukarramah 404",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7319,
        "STOP_GLOBAL_ID": "119220",
        "STOPPOINT_GLOBAL_ID": "11922001",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 404",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 404",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11420301",
      "isGlobalId": true,
      "name": "Al-Olaya 13 (Dt)",
      "type": "platform",
      "coord": [
        24.67848,
        46.70188
      ],
      "name": "Riyadh, Al-Olaya 513",
      "parent": {
        "id": "114203",
        "isGlobalId": true,
        "disassembledName": "Al-Olaya 513",
        "name": "Riyadh, Al-Olaya 513",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7324,
        "STOP_GLOBAL_ID": "114203",
        "STOPPOINT_GLOBAL_ID": "11420301",
        "STOP_NAME_WITH_PLACE": "Al-Olaya 13 (Dt)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Olaya 513",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Olaya 513",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22520201",
      "isGlobalId": true,
      "name": "Al Haeer 02",
      "type": "platform",
      "coord": [
        24.58914,
        46.7411
      ],
      "name": "Riyadh, Al Haeer 102",
      "parent": {
        "id": "225202",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 102",
        "name": "Riyadh, Al Haeer 102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7326,
        "STOP_GLOBAL_ID": "225202",
        "STOPPOINT_GLOBAL_ID": "22520201",
        "STOP_NAME_WITH_PLACE": "Al Haeer 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 102",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14021801",
      "isGlobalId": true,
      "name": "Utayqah 16",
      "type": "platform",
      "coord": [
        24.60584,
        46.70928
      ],
      "name": "Riyadh, Utayqah 616",
      "parent": {
        "id": "140218",
        "isGlobalId": true,
        "disassembledName": "Utayqah 616",
        "name": "Riyadh, Utayqah 616",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7389,
        "STOP_GLOBAL_ID": "140218",
        "STOPPOINT_GLOBAL_ID": "14021801",
        "STOP_NAME_WITH_PLACE": "Utayqah 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Utayqah 616",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Utayqah 616",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16020301",
      "isGlobalId": true,
      "name": "Olaishah 02",
      "type": "platform",
      "coord": [
        24.63272,
        46.69261
      ],
      "name": "Riyadh, Olaishah 602",
      "parent": {
        "id": "160203",
        "isGlobalId": true,
        "disassembledName": "Olaishah 602",
        "name": "Riyadh, Olaishah 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7466,
        "STOP_GLOBAL_ID": "160203",
        "STOPPOINT_GLOBAL_ID": "16020301",
        "STOP_NAME_WITH_PLACE": "Olaishah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaishah 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaishah 602",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11420302",
      "isGlobalId": true,
      "name": "Al-Olaya 13 (Dt)",
      "type": "platform",
      "coord": [
        24.68038,
        46.70138
      ],
      "name": "Riyadh, Al-Olaya 613",
      "parent": {
        "id": "114203",
        "isGlobalId": true,
        "disassembledName": "Al-Olaya 613",
        "name": "Riyadh, Al-Olaya 613",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7495,
        "STOP_GLOBAL_ID": "114203",
        "STOPPOINT_GLOBAL_ID": "11420302",
        "STOP_NAME_WITH_PLACE": "Al-Olaya 13 (Dt)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Olaya 613",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Olaya 613",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14021802",
      "isGlobalId": true,
      "name": "Utayqah 16",
      "type": "platform",
      "coord": [
        24.60519,
        46.70848
      ],
      "name": "Riyadh, Utayqah 516",
      "parent": {
        "id": "140218",
        "isGlobalId": true,
        "disassembledName": "Utayqah 516",
        "name": "Riyadh, Utayqah 516",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7508,
        "STOP_GLOBAL_ID": "140218",
        "STOPPOINT_GLOBAL_ID": "14021802",
        "STOP_NAME_WITH_PLACE": "Utayqah 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Utayqah 516",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Utayqah 516",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22524901",
      "isGlobalId": true,
      "name": "Al Haeer 03",
      "type": "platform",
      "coord": [
        24.587,
        46.74307
      ],
      "name": "Riyadh, Al Haeer 203",
      "parent": {
        "id": "225249",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 203",
        "name": "Riyadh, Al Haeer 203",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7528,
        "STOP_GLOBAL_ID": "225249",
        "STOPPOINT_GLOBAL_ID": "22524901",
        "STOP_NAME_WITH_PLACE": "Al Haeer 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 203",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 203",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16320301",
      "isGlobalId": true,
      "name": "Ash-Shomaisi 03",
      "type": "platform",
      "coord": [
        24.62721,
        46.69326
      ],
      "name": "Riyadh, Ash-Shomaisi 503",
      "parent": {
        "id": "163203",
        "isGlobalId": true,
        "disassembledName": "Ash-Shomaisi 503",
        "name": "Riyadh, Ash-Shomaisi 503",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7584,
        "STOP_GLOBAL_ID": "163203",
        "STOPPOINT_GLOBAL_ID": "16320301",
        "STOP_NAME_WITH_PLACE": "Ash-Shomaisi 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Shomaisi 503",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Shomaisi 503",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22521201",
      "isGlobalId": true,
      "name": "An-Nasar 02",
      "type": "platform",
      "coord": [
        24.58511,
        46.75529
      ],
      "name": "Riyadh, An-Nasar 402",
      "parent": {
        "id": "225212",
        "isGlobalId": true,
        "disassembledName": "An-Nasar 402",
        "name": "Riyadh, An-Nasar 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7584,
        "STOP_GLOBAL_ID": "225212",
        "STOPPOINT_GLOBAL_ID": "22521201",
        "STOP_NAME_WITH_PLACE": "An-Nasar 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasar 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasar 402",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16020202",
      "isGlobalId": true,
      "name": "Olaishah 03",
      "type": "platform",
      "coord": [
        24.63005,
        46.69216
      ],
      "name": "Riyadh, Olaishah 503",
      "parent": {
        "id": "160202",
        "isGlobalId": true,
        "disassembledName": "Olaishah 503",
        "name": "Riyadh, Olaishah 503",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7597,
        "STOP_GLOBAL_ID": "160202",
        "STOPPOINT_GLOBAL_ID": "16020202",
        "STOP_NAME_WITH_PLACE": "Olaishah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaishah 503",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaishah 503",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11922102",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 05",
      "type": "platform",
      "coord": [
        24.70903,
        46.75361
      ],
      "name": "Riyadh, Makkah Al Mukarramah 305",
      "parent": {
        "id": "119221",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 305",
        "name": "Riyadh, Makkah Al Mukarramah 305",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7613,
        "STOP_GLOBAL_ID": "119221",
        "STOPPOINT_GLOBAL_ID": "11922102",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 305",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 305",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22521202",
      "isGlobalId": true,
      "name": "An-Nasar 02",
      "type": "platform",
      "coord": [
        24.58471,
        46.7556
      ],
      "name": "Riyadh, An-Nasar 302",
      "parent": {
        "id": "225212",
        "isGlobalId": true,
        "disassembledName": "An-Nasar 302",
        "name": "Riyadh, An-Nasar 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7632,
        "STOP_GLOBAL_ID": "225212",
        "STOPPOINT_GLOBAL_ID": "22521202",
        "STOP_NAME_WITH_PLACE": "An-Nasar 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasar 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasar 302",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11521702",
      "isGlobalId": true,
      "name": "King Abdulaziz 12",
      "type": "platform",
      "coord": [
        24.69758,
        46.71773
      ],
      "name": "Riyadh, King Abdulaziz 112",
      "parent": {
        "id": "115217",
        "isGlobalId": true,
        "disassembledName": "King Abdulaziz 112",
        "name": "Riyadh, King Abdulaziz 112",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7635,
        "STOP_GLOBAL_ID": "115217",
        "STOPPOINT_GLOBAL_ID": "11521702",
        "STOP_NAME_WITH_PLACE": "King Abdulaziz 12",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdulaziz 112",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdulaziz 112",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16320001",
      "isGlobalId": true,
      "name": "Olaishah 04",
      "type": "platform",
      "coord": [
        24.62831,
        46.69236
      ],
      "name": "Riyadh, Olaishah 604",
      "parent": {
        "id": "163200",
        "isGlobalId": true,
        "disassembledName": "Olaishah 604",
        "name": "Riyadh, Olaishah 604",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7637,
        "STOP_GLOBAL_ID": "163200",
        "STOPPOINT_GLOBAL_ID": "16320001",
        "STOP_NAME_WITH_PLACE": "Olaishah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaishah 604",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaishah 604",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15620001",
      "isGlobalId": true,
      "name": "An-Namuthajiyah 03",
      "type": "platform",
      "coord": [
        24.65219,
        46.68933
      ],
      "name": "Riyadh, An-Namuthajiyah 603",
      "parent": {
        "id": "156200",
        "isGlobalId": true,
        "disassembledName": "An-Namuthajiyah 603",
        "name": "Riyadh, An-Namuthajiyah 603",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7649,
        "STOP_GLOBAL_ID": "156200",
        "STOPPOINT_GLOBAL_ID": "15620001",
        "STOP_NAME_WITH_PLACE": "An-Namuthajiyah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Namuthajiyah 603",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Namuthajiyah 603",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15620002",
      "isGlobalId": true,
      "name": "An-Namuthajiyah 03",
      "type": "platform",
      "coord": [
        24.6519,
        46.68913
      ],
      "name": "Riyadh, An-Namuthajiyah 503",
      "parent": {
        "id": "156200",
        "isGlobalId": true,
        "disassembledName": "An-Namuthajiyah 503",
        "name": "Riyadh, An-Namuthajiyah 503",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7669,
        "STOP_GLOBAL_ID": "156200",
        "STOPPOINT_GLOBAL_ID": "15620002",
        "STOP_NAME_WITH_PLACE": "An-Namuthajiyah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Namuthajiyah 503",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Namuthajiyah 503",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11521201",
      "isGlobalId": true,
      "name": "Al-Olaya 12 (Dt)",
      "type": "platform",
      "coord": [
        24.6821,
        46.70011
      ],
      "name": "Riyadh, Al-Olaya 512",
      "parent": {
        "id": "115212",
        "isGlobalId": true,
        "disassembledName": "Al-Olaya 512",
        "name": "Riyadh, Al-Olaya 512",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7729,
        "STOP_GLOBAL_ID": "115212",
        "STOPPOINT_GLOBAL_ID": "11521201",
        "STOP_NAME_WITH_PLACE": "Al-Olaya 12 (Dt)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Olaya 512",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Olaya 512",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11521701",
      "isGlobalId": true,
      "name": "King Abdulaziz 12",
      "type": "platform",
      "coord": [
        24.69924,
        46.71808
      ],
      "name": "Riyadh, King Abdulaziz 212",
      "parent": {
        "id": "115217",
        "isGlobalId": true,
        "disassembledName": "King Abdulaziz 212",
        "name": "Riyadh, King Abdulaziz 212",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7779,
        "STOP_GLOBAL_ID": "115217",
        "STOPPOINT_GLOBAL_ID": "11521701",
        "STOP_NAME_WITH_PLACE": "King Abdulaziz 12",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdulaziz 212",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdulaziz 212",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "21920502",
      "isGlobalId": true,
      "name": "Al Kharj 12",
      "type": "platform",
      "coord": [
        24.59476,
        46.79801
      ],
      "name": "Riyadh, Al Kharj 212",
      "parent": {
        "id": "219205",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 212",
        "name": "Riyadh, Al Kharj 212",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7807,
        "STOP_GLOBAL_ID": "219205",
        "STOPPOINT_GLOBAL_ID": "21920502",
        "STOP_NAME_WITH_PLACE": "Al Kharj 12",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 212",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 212",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14620101",
      "isGlobalId": true,
      "name": "Al Faryan 05",
      "type": "platform",
      "coord": [
        24.59108,
        46.72361
      ],
      "name": "Riyadh, Al Faryan 205",
      "parent": {
        "id": "146201",
        "isGlobalId": true,
        "disassembledName": "Al Faryan 205",
        "name": "Riyadh, Al Faryan 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7835,
        "STOP_GLOBAL_ID": "146201",
        "STOPPOINT_GLOBAL_ID": "14620101",
        "STOP_NAME_WITH_PLACE": "Al Faryan 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Faryan 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Faryan 205",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11922201",
      "isGlobalId": true,
      "name": "Makkah Al Mukarramah 06",
      "type": "platform",
      "coord": [
        24.71102,
        46.75548
      ],
      "name": "Riyadh, Makkah Al Mukarramah 406",
      "parent": {
        "id": "119222",
        "isGlobalId": true,
        "disassembledName": "Makkah Al Mukarramah 406",
        "name": "Riyadh, Makkah Al Mukarramah 406",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7847,
        "STOP_GLOBAL_ID": "119222",
        "STOPPOINT_GLOBAL_ID": "11922201",
        "STOP_NAME_WITH_PLACE": "Makkah Al Mukarramah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Makkah Al Mukarramah 406",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Makkah Al Mukarramah 406",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14620001",
      "isGlobalId": true,
      "name": "Southern Ring 01",
      "type": "platform",
      "coord": [
        24.58921,
        46.72688
      ],
      "name": "Riyadh, Southern Ring 401",
      "parent": {
        "id": "146200",
        "isGlobalId": true,
        "disassembledName": "Southern Ring 401",
        "name": "Riyadh, Southern Ring 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7870,
        "STOP_GLOBAL_ID": "146200",
        "STOPPOINT_GLOBAL_ID": "14620001",
        "STOP_NAME_WITH_PLACE": "Southern Ring 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Southern Ring 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Southern Ring 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14620102",
      "isGlobalId": true,
      "name": "Al Faryan 05",
      "type": "platform",
      "coord": [
        24.59078,
        46.72341
      ],
      "name": "Riyadh, Al Faryan 105",
      "parent": {
        "id": "146201",
        "isGlobalId": true,
        "disassembledName": "Al Faryan 105",
        "name": "Riyadh, Al Faryan 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7878,
        "STOP_GLOBAL_ID": "146201",
        "STOPPOINT_GLOBAL_ID": "14620102",
        "STOP_NAME_WITH_PLACE": "Al Faryan 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Faryan 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Faryan 105",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22521302",
      "isGlobalId": true,
      "name": "An-Nasar 01",
      "type": "platform",
      "coord": [
        24.58281,
        46.75005
      ],
      "name": "Riyadh, An-Nasar 401",
      "parent": {
        "id": "225213",
        "isGlobalId": true,
        "disassembledName": "An-Nasar 401",
        "name": "Riyadh, An-Nasar 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7907,
        "STOP_GLOBAL_ID": "225213",
        "STOPPOINT_GLOBAL_ID": "22521302",
        "STOP_NAME_WITH_PLACE": "An-Nasar 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasar 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasar 401",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14620002",
      "isGlobalId": true,
      "name": "Southern Ring 01",
      "type": "platform",
      "coord": [
        24.58856,
        46.72748
      ],
      "name": "Riyadh, Southern Ring 301",
      "parent": {
        "id": "146200",
        "isGlobalId": true,
        "disassembledName": "Southern Ring 301",
        "name": "Riyadh, Southern Ring 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7912,
        "STOP_GLOBAL_ID": "146200",
        "STOPPOINT_GLOBAL_ID": "14620002",
        "STOP_NAME_WITH_PLACE": "Southern Ring 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Southern Ring 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Southern Ring 301",
        "IDENTIFIER": "3"
      }
    },
    {
      "id": "22520102",
      "isGlobalId": true,
      "name": "Al Haeer 04",
      "type": "platform",
      "coord": [
        24.58317,
        46.7456
      ],
      "name": "Riyadh, Al Haeer 204",
      "parent": {
        "id": "225201",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 204",
        "name": "Riyadh, Al Haeer 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7933,
        "STOP_GLOBAL_ID": "225201",
        "STOPPOINT_GLOBAL_ID": "22520102",
        "STOP_NAME_WITH_PLACE": "Al Haeer 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 204",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16120002",
      "isGlobalId": true,
      "name": "Al-Badeah 03",
      "type": "platform",
      "coord": [
        24.62599,
        46.6904
      ],
      "name": "Riyadh, Al-Badeah 503",
      "parent": {
        "id": "161200",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 503",
        "name": "Riyadh, Al-Badeah 503",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7933,
        "STOP_GLOBAL_ID": "161200",
        "STOPPOINT_GLOBAL_ID": "16120002",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 503",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 503",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15620101",
      "isGlobalId": true,
      "name": "An-Namuthajiyah 02",
      "type": "platform",
      "coord": [
        24.6565,
        46.68726
      ],
      "name": "Riyadh, An-Namuthajiyah 602",
      "parent": {
        "id": "156201",
        "isGlobalId": true,
        "disassembledName": "An-Namuthajiyah 602",
        "name": "Riyadh, An-Namuthajiyah 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7940,
        "STOP_GLOBAL_ID": "156201",
        "STOPPOINT_GLOBAL_ID": "15620101",
        "STOP_NAME_WITH_PLACE": "An-Namuthajiyah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Namuthajiyah 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Namuthajiyah 602",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24522201",
      "isGlobalId": true,
      "name": "Suwaidi Al Am 10",
      "type": "platform",
      "coord": [
        24.60403,
        46.70433
      ],
      "name": "Riyadh, Suwaidi Al Am 410",
      "parent": {
        "id": "245222",
        "isGlobalId": true,
        "disassembledName": "Suwaidi Al Am 410",
        "name": "Riyadh, Suwaidi Al Am 410",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7946,
        "STOP_GLOBAL_ID": "245222",
        "STOPPOINT_GLOBAL_ID": "24522201",
        "STOP_NAME_WITH_PLACE": "Suwaidi Al Am 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Suwaidi Al Am 410",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Suwaidi Al Am 410",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22521301",
      "isGlobalId": true,
      "name": "An-Nasar 01",
      "type": "platform",
      "coord": [
        24.58214,
        46.74974
      ],
      "name": "Riyadh, An-Nasar 301",
      "parent": {
        "id": "225213",
        "isGlobalId": true,
        "disassembledName": "An-Nasar 301",
        "name": "Riyadh, An-Nasar 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 7993,
        "STOP_GLOBAL_ID": "225213",
        "STOPPOINT_GLOBAL_ID": "22521301",
        "STOP_NAME_WITH_PLACE": "An-Nasar 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasar 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasar 301",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16120001",
      "isGlobalId": true,
      "name": "Al-Badeah 03",
      "type": "platform",
      "coord": [
        24.62595,
        46.68969
      ],
      "name": "Riyadh, Al-Badeah 603",
      "parent": {
        "id": "161200",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 603",
        "name": "Riyadh, Al-Badeah 603",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8009,
        "STOP_GLOBAL_ID": "161200",
        "STOPPOINT_GLOBAL_ID": "16120001",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 603",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 603",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22520101",
      "isGlobalId": true,
      "name": "Al Haeer 04",
      "type": "platform",
      "coord": [
        24.58258,
        46.74526
      ],
      "name": "Riyadh, Al Haeer 104",
      "parent": {
        "id": "225201",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 104",
        "name": "Riyadh, Al Haeer 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8011,
        "STOP_GLOBAL_ID": "225201",
        "STOPPOINT_GLOBAL_ID": "22520101",
        "STOP_NAME_WITH_PLACE": "Al Haeer 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 104",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "21920701",
      "isGlobalId": true,
      "name": "Al Kharj 13",
      "type": "platform",
      "coord": [
        24.59319,
        46.79986
      ],
      "name": "Riyadh, Al Kharj 113",
      "parent": {
        "id": "219207",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 113",
        "name": "Riyadh, Al Kharj 113",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8083,
        "STOP_GLOBAL_ID": "219207",
        "STOPPOINT_GLOBAL_ID": "21920701",
        "STOP_NAME_WITH_PLACE": "Al Kharj 13",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 113",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 113",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15520001",
      "isGlobalId": true,
      "name": "An-Namuthajiyah 01",
      "type": "platform",
      "coord": [
        24.65896,
        46.68572
      ],
      "name": "Riyadh, An-Namuthajiyah 501",
      "parent": {
        "id": "155200",
        "isGlobalId": true,
        "disassembledName": "An-Namuthajiyah 501",
        "name": "Riyadh, An-Namuthajiyah 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8157,
        "STOP_GLOBAL_ID": "155200",
        "STOPPOINT_GLOBAL_ID": "15520001",
        "STOP_NAME_WITH_PLACE": "An-Namuthajiyah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Namuthajiyah 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Namuthajiyah 501",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16420001",
      "isGlobalId": true,
      "name": "Suwaidi Al Am 09",
      "type": "platform",
      "coord": [
        24.60261,
        46.70243
      ],
      "name": "Riyadh, Suwaidi Al Am 309",
      "parent": {
        "id": "164200",
        "isGlobalId": true,
        "disassembledName": "Suwaidi Al Am 309",
        "name": "Riyadh, Suwaidi Al Am 309",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8220,
        "STOP_GLOBAL_ID": "164200",
        "STOPPOINT_GLOBAL_ID": "16420001",
        "STOP_NAME_WITH_PLACE": "Suwaidi Al Am 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Suwaidi Al Am 309",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Suwaidi Al Am 309",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16420002",
      "isGlobalId": true,
      "name": "Suwaidi Al Am 09",
      "type": "platform",
      "coord": [
        24.60274,
        46.702
      ],
      "name": "Riyadh, Suwaidi Al Am 409",
      "parent": {
        "id": "164200",
        "isGlobalId": true,
        "disassembledName": "Suwaidi Al Am 409",
        "name": "Riyadh, Suwaidi Al Am 409",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8245,
        "STOP_GLOBAL_ID": "164200",
        "STOPPOINT_GLOBAL_ID": "16420002",
        "STOP_NAME_WITH_PLACE": "Suwaidi Al Am 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Suwaidi Al Am 409",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Suwaidi Al Am 409",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15520102",
      "isGlobalId": true,
      "name": "King Saud 01",
      "type": "platform",
      "coord": [
        24.66021,
        46.68424
      ],
      "name": "Riyadh, King Saud 301",
      "parent": {
        "id": "155201",
        "isGlobalId": true,
        "disassembledName": "King Saud 301",
        "name": "Riyadh, King Saud 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8348,
        "STOP_GLOBAL_ID": "155201",
        "STOPPOINT_GLOBAL_ID": "15520102",
        "STOP_NAME_WITH_PLACE": "King Saud 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Saud 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Saud 301",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16121102",
      "isGlobalId": true,
      "name": "Al-Badeah 09",
      "type": "platform",
      "coord": [
        24.62399,
        46.6859
      ],
      "name": "Riyadh, Al-Badeah 609",
      "parent": {
        "id": "161211",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 609",
        "name": "Riyadh, Al-Badeah 609",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8487,
        "STOP_GLOBAL_ID": "161211",
        "STOPPOINT_GLOBAL_ID": "16121102",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 609",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 609",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16121101",
      "isGlobalId": true,
      "name": "Al-Badeah 09",
      "type": "platform",
      "coord": [
        24.62364,
        46.68582
      ],
      "name": "Riyadh, Al-Badeah 509",
      "parent": {
        "id": "161211",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 509",
        "name": "Riyadh, Al-Badeah 509",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8509,
        "STOP_GLOBAL_ID": "161211",
        "STOPPOINT_GLOBAL_ID": "16121101",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 509",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 509",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15520101",
      "isGlobalId": true,
      "name": "King Saud 01",
      "type": "platform",
      "coord": [
        24.65947,
        46.68261
      ],
      "name": "Riyadh, King Saud 401",
      "parent": {
        "id": "155201",
        "isGlobalId": true,
        "disassembledName": "King Saud 401",
        "name": "Riyadh, King Saud 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8510,
        "STOP_GLOBAL_ID": "155201",
        "STOPPOINT_GLOBAL_ID": "15520101",
        "STOP_NAME_WITH_PLACE": "King Saud 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Saud 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Saud 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15920002",
      "isGlobalId": true,
      "name": "Al-Badeah 02",
      "type": "platform",
      "coord": [
        24.62553,
        46.68509
      ],
      "name": "Riyadh, Al-Badeah 602",
      "parent": {
        "id": "159200",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 602",
        "name": "Riyadh, Al-Badeah 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8512,
        "STOP_GLOBAL_ID": "159200",
        "STOPPOINT_GLOBAL_ID": "15920002",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 602",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15920001",
      "isGlobalId": true,
      "name": "Al-Badeah 02",
      "type": "platform",
      "coord": [
        24.62533,
        46.68481
      ],
      "name": "Riyadh, Al-Badeah 502",
      "parent": {
        "id": "159200",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 502",
        "name": "Riyadh, Al-Badeah 502",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8549,
        "STOP_GLOBAL_ID": "159200",
        "STOPPOINT_GLOBAL_ID": "15920001",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 502",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 502",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15220102",
      "isGlobalId": true,
      "name": "Takhassusi 20",
      "type": "platform",
      "coord": [
        24.6655,
        46.6829
      ],
      "name": "Riyadh, Takhassusi 220",
      "parent": {
        "id": "152201",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 220",
        "name": "Riyadh, Takhassusi 220",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8641,
        "STOP_GLOBAL_ID": "152201",
        "STOPPOINT_GLOBAL_ID": "15220102",
        "STOP_NAME_WITH_PLACE": "Takhassusi 20",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 220",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 220",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "21920602",
      "isGlobalId": true,
      "name": "Al Kharj 14",
      "type": "platform",
      "coord": [
        24.5907,
        46.8048
      ],
      "name": "Riyadh, Al Kharj 214",
      "parent": {
        "id": "219206",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 214",
        "name": "Riyadh, Al Kharj 214",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8654,
        "STOP_GLOBAL_ID": "219206",
        "STOPPOINT_GLOBAL_ID": "21920602",
        "STOP_NAME_WITH_PLACE": "Al Kharj 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 214",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 214",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22525001",
      "isGlobalId": true,
      "name": "Al Haeer 05",
      "type": "platform",
      "coord": [
        24.57632,
        46.74943
      ],
      "name": "Riyadh, Al Haeer 205",
      "parent": {
        "id": "225250",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 205",
        "name": "Riyadh, Al Haeer 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8705,
        "STOP_GLOBAL_ID": "225250",
        "STOPPOINT_GLOBAL_ID": "22525001",
        "STOP_NAME_WITH_PLACE": "Al Haeer 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 205",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24520102",
      "isGlobalId": true,
      "name": "Suwaidi Al Am 08",
      "type": "platform",
      "coord": [
        24.60144,
        46.69746
      ],
      "name": "Riyadh, Suwaidi Al Am 408",
      "parent": {
        "id": "245201",
        "isGlobalId": true,
        "disassembledName": "Suwaidi Al Am 408",
        "name": "Riyadh, Suwaidi Al Am 408",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8733,
        "STOP_GLOBAL_ID": "245201",
        "STOPPOINT_GLOBAL_ID": "24520102",
        "STOP_NAME_WITH_PLACE": "Suwaidi Al Am 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Suwaidi Al Am 408",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Suwaidi Al Am 408",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11424701",
      "isGlobalId": true,
      "name": "Olaya 18 (Rd)",
      "type": "platform",
      "coord": [
        24.68335,
        46.69021
      ],
      "name": "Riyadh, Olaya 118",
      "parent": {
        "id": "114247",
        "isGlobalId": true,
        "disassembledName": "Olaya 118",
        "name": "Riyadh, Olaya 118",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8744,
        "STOP_GLOBAL_ID": "114247",
        "STOPPOINT_GLOBAL_ID": "11424701",
        "STOP_NAME_WITH_PLACE": "Olaya 18 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 118",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 118",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11520402",
      "isGlobalId": true,
      "name": "As-Sulaimanyah 08",
      "type": "platform",
      "coord": [
        24.70542,
        46.71265
      ],
      "name": "Riyadh, As-Sulaimanyah 508",
      "parent": {
        "id": "115204",
        "isGlobalId": true,
        "disassembledName": "As-Sulaimanyah 508",
        "name": "Riyadh, As-Sulaimanyah 508",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8746,
        "STOP_GLOBAL_ID": "115204",
        "STOPPOINT_GLOBAL_ID": "11520402",
        "STOP_NAME_WITH_PLACE": "As-Sulaimanyah 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "As-Sulaimanyah 508",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, As-Sulaimanyah 508",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11424702",
      "isGlobalId": true,
      "name": "Olaya 18 (Rd)",
      "type": "platform",
      "coord": [
        24.68377,
        46.6904
      ],
      "name": "Riyadh, Olaya 218",
      "parent": {
        "id": "114247",
        "isGlobalId": true,
        "disassembledName": "Olaya 218",
        "name": "Riyadh, Olaya 218",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8752,
        "STOP_GLOBAL_ID": "114247",
        "STOPPOINT_GLOBAL_ID": "11424702",
        "STOP_NAME_WITH_PLACE": "Olaya 18 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 218",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 218",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16121001",
      "isGlobalId": true,
      "name": "Al-Badeah 08",
      "type": "platform",
      "coord": [
        24.62266,
        46.68368
      ],
      "name": "Riyadh, Al-Badeah 608",
      "parent": {
        "id": "161210",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 608",
        "name": "Riyadh, Al-Badeah 608",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8775,
        "STOP_GLOBAL_ID": "161210",
        "STOPPOINT_GLOBAL_ID": "16121001",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 608",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 608",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15220101",
      "isGlobalId": true,
      "name": "Takhassusi 20",
      "type": "platform",
      "coord": [
        24.66702,
        46.68184
      ],
      "name": "Riyadh, Takhassusi 120",
      "parent": {
        "id": "152201",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 120",
        "name": "Riyadh, Takhassusi 120",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8805,
        "STOP_GLOBAL_ID": "152201",
        "STOPPOINT_GLOBAL_ID": "15220101",
        "STOP_NAME_WITH_PLACE": "Takhassusi 20",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 120",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 120",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16121002",
      "isGlobalId": true,
      "name": "Al-Badeah 08",
      "type": "platform",
      "coord": [
        24.62198,
        46.68292
      ],
      "name": "Riyadh, Al-Badeah 508",
      "parent": {
        "id": "161210",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 508",
        "name": "Riyadh, Al-Badeah 508",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8882,
        "STOP_GLOBAL_ID": "161210",
        "STOPPOINT_GLOBAL_ID": "16121002",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 508",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 508",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24520101",
      "isGlobalId": true,
      "name": "Suwaidi Al Am 08",
      "type": "platform",
      "coord": [
        24.60065,
        46.69631
      ],
      "name": "Riyadh, Suwaidi Al Am 308",
      "parent": {
        "id": "245201",
        "isGlobalId": true,
        "disassembledName": "Suwaidi Al Am 308",
        "name": "Riyadh, Suwaidi Al Am 308",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8893,
        "STOP_GLOBAL_ID": "245201",
        "STOPPOINT_GLOBAL_ID": "24520101",
        "STOP_NAME_WITH_PLACE": "Suwaidi Al Am 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Suwaidi Al Am 308",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Suwaidi Al Am 308",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24620202",
      "isGlobalId": true,
      "name": "Sultanah 05 (Rd)",
      "type": "platform",
      "coord": [
        24.60782,
        46.6902
      ],
      "name": "Riyadh, Sultanah 205",
      "parent": {
        "id": "246202",
        "isGlobalId": true,
        "disassembledName": "Sultanah 205",
        "name": "Riyadh, Sultanah 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8926,
        "STOP_GLOBAL_ID": "246202",
        "STOPPOINT_GLOBAL_ID": "24620202",
        "STOP_NAME_WITH_PLACE": "Sultanah 05 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 205",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24620102",
      "isGlobalId": true,
      "name": "Sultanah 06 (Rd)",
      "type": "platform",
      "coord": [
        24.60347,
        46.69349
      ],
      "name": "Riyadh, Sultanah 206",
      "parent": {
        "id": "246201",
        "isGlobalId": true,
        "disassembledName": "Sultanah 206",
        "name": "Riyadh, Sultanah 206",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8927,
        "STOP_GLOBAL_ID": "246201",
        "STOPPOINT_GLOBAL_ID": "24620102",
        "STOP_NAME_WITH_PLACE": "Sultanah 06 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 206",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 206",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "21920801",
      "isGlobalId": true,
      "name": "Al Kharj 15",
      "type": "platform",
      "coord": [
        24.58901,
        46.80648
      ],
      "name": "Riyadh, Al Kharj 115",
      "parent": {
        "id": "219208",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 115",
        "name": "Riyadh, Al Kharj 115",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8932,
        "STOP_GLOBAL_ID": "219208",
        "STOPPOINT_GLOBAL_ID": "21920801",
        "STOP_NAME_WITH_PLACE": "Al Kharj 15",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 115",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 115",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24620201",
      "isGlobalId": true,
      "name": "Sultanah 05 (Rd)",
      "type": "platform",
      "coord": [
        24.60693,
        46.69063
      ],
      "name": "Riyadh, Sultanah 105",
      "parent": {
        "id": "246202",
        "isGlobalId": true,
        "disassembledName": "Sultanah 105",
        "name": "Riyadh, Sultanah 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8945,
        "STOP_GLOBAL_ID": "246202",
        "STOPPOINT_GLOBAL_ID": "24620201",
        "STOP_NAME_WITH_PLACE": "Sultanah 05 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 105",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11520401",
      "isGlobalId": true,
      "name": "As-Sulaimanyah 08",
      "type": "platform",
      "coord": [
        24.70626,
        46.71076
      ],
      "name": "Riyadh, As-Sulaimanyah 608",
      "parent": {
        "id": "115204",
        "isGlobalId": true,
        "disassembledName": "As-Sulaimanyah 608",
        "name": "Riyadh, As-Sulaimanyah 608",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8952,
        "STOP_GLOBAL_ID": "115204",
        "STOPPOINT_GLOBAL_ID": "11520401",
        "STOP_NAME_WITH_PLACE": "As-Sulaimanyah 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "As-Sulaimanyah 608",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, As-Sulaimanyah 608",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16120402",
      "isGlobalId": true,
      "name": "Al-Badeah 01",
      "type": "platform",
      "coord": [
        24.62527,
        46.68099
      ],
      "name": "Riyadh, Al-Badeah 501",
      "parent": {
        "id": "161204",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 501",
        "name": "Riyadh, Al-Badeah 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8956,
        "STOP_GLOBAL_ID": "161204",
        "STOPPOINT_GLOBAL_ID": "16120402",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 501",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16120401",
      "isGlobalId": true,
      "name": "Al-Badeah 01",
      "type": "platform",
      "coord": [
        24.62546,
        46.68083
      ],
      "name": "Riyadh, Al-Badeah 601",
      "parent": {
        "id": "161204",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 601",
        "name": "Riyadh, Al-Badeah 601",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8967,
        "STOP_GLOBAL_ID": "161204",
        "STOPPOINT_GLOBAL_ID": "16120401",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 601",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 601",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24620101",
      "isGlobalId": true,
      "name": "Sultanah 06 (Rd)",
      "type": "platform",
      "coord": [
        24.60257,
        46.69377
      ],
      "name": "Riyadh, Sultanah 106",
      "parent": {
        "id": "246201",
        "isGlobalId": true,
        "disassembledName": "Sultanah 106",
        "name": "Riyadh, Sultanah 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 8968,
        "STOP_GLOBAL_ID": "246201",
        "STOPPOINT_GLOBAL_ID": "24620101",
        "STOP_NAME_WITH_PLACE": "Sultanah 06 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 106",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24620302",
      "isGlobalId": true,
      "name": "Sultanah 04 (Rd)",
      "type": "platform",
      "coord": [
        24.60898,
        46.68832
      ],
      "name": "Riyadh, Sultanah 104",
      "parent": {
        "id": "246203",
        "isGlobalId": true,
        "disassembledName": "Sultanah 104",
        "name": "Riyadh, Sultanah 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9029,
        "STOP_GLOBAL_ID": "246203",
        "STOPPOINT_GLOBAL_ID": "24620302",
        "STOP_NAME_WITH_PLACE": "Sultanah 04 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 104",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22521401",
      "isGlobalId": true,
      "name": "Al Haeer 06",
      "type": "platform",
      "coord": [
        24.57344,
        46.75075
      ],
      "name": "Riyadh, Al Haeer 106",
      "parent": {
        "id": "225214",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 106",
        "name": "Riyadh, Al Haeer 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9042,
        "STOP_GLOBAL_ID": "225214",
        "STOPPOINT_GLOBAL_ID": "22521401",
        "STOP_NAME_WITH_PLACE": "Al Haeer 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 106",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16120902",
      "isGlobalId": true,
      "name": "Al-Badeah 07",
      "type": "platform",
      "coord": [
        24.62129,
        46.68128
      ],
      "name": "Riyadh, Al-Badeah 607",
      "parent": {
        "id": "161209",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 607",
        "name": "Riyadh, Al-Badeah 607",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9083,
        "STOP_GLOBAL_ID": "161209",
        "STOPPOINT_GLOBAL_ID": "16120902",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 607",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 607",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24620301",
      "isGlobalId": true,
      "name": "Sultanah 04 (Rd)",
      "type": "platform",
      "coord": [
        24.60938,
        46.68736
      ],
      "name": "Riyadh, Sultanah 204",
      "parent": {
        "id": "246203",
        "isGlobalId": true,
        "disassembledName": "Sultanah 204",
        "name": "Riyadh, Sultanah 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9096,
        "STOP_GLOBAL_ID": "246203",
        "STOPPOINT_GLOBAL_ID": "24620301",
        "STOP_NAME_WITH_PLACE": "Sultanah 04 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 204",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15720001",
      "isGlobalId": true,
      "name": "Amr Bin Al Aas 01",
      "type": "platform",
      "coord": [
        24.6344,
        46.67714
      ],
      "name": "Riyadh, Amr Bin Al Aas 401",
      "parent": {
        "id": "157200",
        "isGlobalId": true,
        "disassembledName": "Amr Bin Al Aas 401",
        "name": "Riyadh, Amr Bin Al Aas 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9113,
        "STOP_GLOBAL_ID": "157200",
        "STOPPOINT_GLOBAL_ID": "15720001",
        "STOP_NAME_WITH_PLACE": "Amr Bin Al Aas 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Amr Bin Al Aas 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Amr Bin Al Aas 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16120901",
      "isGlobalId": true,
      "name": "Al-Badeah 07",
      "type": "platform",
      "coord": [
        24.62092,
        46.68109
      ],
      "name": "Riyadh, Al-Badeah 507",
      "parent": {
        "id": "161209",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 507",
        "name": "Riyadh, Al-Badeah 507",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9118,
        "STOP_GLOBAL_ID": "161209",
        "STOPPOINT_GLOBAL_ID": "16120901",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 507",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 507",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15520202",
      "isGlobalId": true,
      "name": "An-Nasiriyah 02",
      "type": "platform",
      "coord": [
        24.65487,
        46.67608
      ],
      "name": "Riyadh, An-Nasiriyah 602",
      "parent": {
        "id": "155202",
        "isGlobalId": true,
        "disassembledName": "An-Nasiriyah 602",
        "name": "Riyadh, An-Nasiriyah 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9149,
        "STOP_GLOBAL_ID": "155202",
        "STOPPOINT_GLOBAL_ID": "15520202",
        "STOP_NAME_WITH_PLACE": "An-Nasiriyah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasiriyah 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasiriyah 602",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15520201",
      "isGlobalId": true,
      "name": "An-Nasiriyah 02",
      "type": "platform",
      "coord": [
        24.65432,
        46.67582
      ],
      "name": "Riyadh, An-Nasiriyah 502",
      "parent": {
        "id": "155202",
        "isGlobalId": true,
        "disassembledName": "An-Nasiriyah 502",
        "name": "Riyadh, An-Nasiriyah 502",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9171,
        "STOP_GLOBAL_ID": "155202",
        "STOPPOINT_GLOBAL_ID": "15520201",
        "STOP_NAME_WITH_PLACE": "An-Nasiriyah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasiriyah 502",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasiriyah 502",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15221101",
      "isGlobalId": true,
      "name": "Takhassusi 19",
      "type": "platform",
      "coord": [
        24.67176,
        46.67993
      ],
      "name": "Riyadh, Takhassusi 219",
      "parent": {
        "id": "152211",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 219",
        "name": "Riyadh, Takhassusi 219",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9185,
        "STOP_GLOBAL_ID": "152211",
        "STOPPOINT_GLOBAL_ID": "15221101",
        "STOP_NAME_WITH_PLACE": "Takhassusi 19",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 219",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 219",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22521501",
      "isGlobalId": true,
      "name": "Al Haeer 07",
      "type": "platform",
      "coord": [
        24.57146,
        46.75236
      ],
      "name": "Riyadh, Al Haeer 207",
      "parent": {
        "id": "225215",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 207",
        "name": "Riyadh, Al Haeer 207",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9269,
        "STOP_GLOBAL_ID": "225215",
        "STOPPOINT_GLOBAL_ID": "22521501",
        "STOP_NAME_WITH_PLACE": "Al Haeer 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 207",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 207",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16120102",
      "isGlobalId": true,
      "name": "Sultanah 03 (Rd)",
      "type": "platform",
      "coord": [
        24.61219,
        46.683839999999999
      ],
      "name": "Riyadh, Sultanah 203",
      "parent": {
        "id": "161201",
        "isGlobalId": true,
        "disassembledName": "Sultanah 203",
        "name": "Riyadh, Sultanah 203",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9273,
        "STOP_GLOBAL_ID": "161201",
        "STOPPOINT_GLOBAL_ID": "16120102",
        "STOP_NAME_WITH_PLACE": "Sultanah 03 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 203",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 203",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15920202",
      "isGlobalId": true,
      "name": "Ar-Rafeah 06",
      "type": "platform",
      "coord": [
        24.63206,
        46.6759
      ],
      "name": "Riyadh, Ar-Rafeah 606",
      "parent": {
        "id": "159202",
        "isGlobalId": true,
        "disassembledName": "Ar-Rafeah 606",
        "name": "Riyadh, Ar-Rafeah 606",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9301,
        "STOP_GLOBAL_ID": "159202",
        "STOPPOINT_GLOBAL_ID": "15920202",
        "STOP_NAME_WITH_PLACE": "Ar-Rafeah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ar-Rafeah 606",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ar-Rafeah 606",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16120101",
      "isGlobalId": true,
      "name": "Sultanah 03 (Rd)",
      "type": "platform",
      "coord": [
        24.61232,
        46.6834
      ],
      "name": "Riyadh, Sultanah 103",
      "parent": {
        "id": "161201",
        "isGlobalId": true,
        "disassembledName": "Sultanah 103",
        "name": "Riyadh, Sultanah 103",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9309,
        "STOP_GLOBAL_ID": "161201",
        "STOPPOINT_GLOBAL_ID": "16120101",
        "STOP_NAME_WITH_PLACE": "Sultanah 03 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Sultanah 103",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Sultanah 103",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15920201",
      "isGlobalId": true,
      "name": "Ar-Rafeah 06",
      "type": "platform",
      "coord": [
        24.63113,
        46.67597
      ],
      "name": "Riyadh, Ar-Rafeah 506",
      "parent": {
        "id": "159202",
        "isGlobalId": true,
        "disassembledName": "Ar-Rafeah 506",
        "name": "Riyadh, Ar-Rafeah 506",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9316,
        "STOP_GLOBAL_ID": "159202",
        "STOPPOINT_GLOBAL_ID": "15920201",
        "STOP_NAME_WITH_PLACE": "Ar-Rafeah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ar-Rafeah 506",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ar-Rafeah 506",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "20320102",
      "isGlobalId": true,
      "name": "Khurais 01",
      "type": "platform",
      "coord": [
        24.7219,
        46.77431
      ],
      "name": "Riyadh, Khurais 301",
      "parent": {
        "id": "203201",
        "isGlobalId": true,
        "disassembledName": "Khurais 301",
        "name": "Riyadh, Khurais 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9358,
        "STOP_GLOBAL_ID": "203201",
        "STOPPOINT_GLOBAL_ID": "20320102",
        "STOP_NAME_WITH_PLACE": "Khurais 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Khurais 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Khurais 301",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11424902",
      "isGlobalId": true,
      "name": "Olaya 17 (Rd)",
      "type": "platform",
      "coord": [
        24.68911,
        46.68762
      ],
      "name": "Riyadh, Olaya 217",
      "parent": {
        "id": "114249",
        "isGlobalId": true,
        "disassembledName": "Olaya 217",
        "name": "Riyadh, Olaya 217",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9363,
        "STOP_GLOBAL_ID": "114249",
        "STOPPOINT_GLOBAL_ID": "11424902",
        "STOP_NAME_WITH_PLACE": "Olaya 17 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 217",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 217",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11424901",
      "isGlobalId": true,
      "name": "Olaya 17 (Rd)",
      "type": "platform",
      "coord": [
        24.68885,
        46.68742
      ],
      "name": "Riyadh, Olaya 117",
      "parent": {
        "id": "114249",
        "isGlobalId": true,
        "disassembledName": "Olaya 117",
        "name": "Riyadh, Olaya 117",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9364,
        "STOP_GLOBAL_ID": "114249",
        "STOPPOINT_GLOBAL_ID": "11424901",
        "STOP_NAME_WITH_PLACE": "Olaya 17 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 117",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 117",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15420001",
      "isGlobalId": true,
      "name": "Ar-Rafeah 07",
      "type": "platform",
      "coord": [
        24.62655,
        46.67672
      ],
      "name": "Riyadh, Ar-Rafeah 507",
      "parent": {
        "id": "154200",
        "isGlobalId": true,
        "disassembledName": "Ar-Rafeah 507",
        "name": "Riyadh, Ar-Rafeah 507",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9368,
        "STOP_GLOBAL_ID": "154200",
        "STOPPOINT_GLOBAL_ID": "15420001",
        "STOP_NAME_WITH_PLACE": "Ar-Rafeah 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ar-Rafeah 507",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ar-Rafeah 507",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15320002",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 01",
      "type": "platform",
      "coord": [
        24.65753,
        46.67439
      ],
      "name": "Riyadh, Ash-Sharafiyah 501",
      "parent": {
        "id": "153200",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 501",
        "name": "Riyadh, Ash-Sharafiyah 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9376,
        "STOP_GLOBAL_ID": "153200",
        "STOPPOINT_GLOBAL_ID": "15320002",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 501",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15320001",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 01",
      "type": "platform",
      "coord": [
        24.65679,
        46.6741
      ],
      "name": "Riyadh, Ash-Sharafiyah 601",
      "parent": {
        "id": "153200",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 601",
        "name": "Riyadh, Ash-Sharafiyah 601",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9396,
        "STOP_GLOBAL_ID": "153200",
        "STOPPOINT_GLOBAL_ID": "15320001",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 601",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 601",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15220401",
      "isGlobalId": true,
      "name": "Takhassusi 18",
      "type": "platform",
      "coord": [
        24.67432,
        46.67873
      ],
      "name": "Riyadh, Takhassusi 218",
      "parent": {
        "id": "152204",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 218",
        "name": "Riyadh, Takhassusi 218",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9418,
        "STOP_GLOBAL_ID": "152204",
        "STOPPOINT_GLOBAL_ID": "15220401",
        "STOP_NAME_WITH_PLACE": "Takhassusi 18",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 218",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 218",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16120802",
      "isGlobalId": true,
      "name": "Al-Badeah 06",
      "type": "platform",
      "coord": [
        24.61906,
        46.67786
      ],
      "name": "Riyadh, Al-Badeah 506",
      "parent": {
        "id": "161208",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 506",
        "name": "Riyadh, Al-Badeah 506",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9535,
        "STOP_GLOBAL_ID": "161208",
        "STOPPOINT_GLOBAL_ID": "16120802",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 506",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 506",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11420401",
      "isGlobalId": true,
      "name": "Takhassusi 17",
      "type": "platform",
      "coord": [
        24.67688,
        46.67848
      ],
      "name": "Riyadh, Takhassusi 217",
      "parent": {
        "id": "114204",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 217",
        "name": "Riyadh, Takhassusi 217",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9559,
        "STOP_GLOBAL_ID": "114204",
        "STOPPOINT_GLOBAL_ID": "11420401",
        "STOP_NAME_WITH_PLACE": "Takhassusi 17",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 217",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 217",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22525101",
      "isGlobalId": true,
      "name": "Al Haeer 08",
      "type": "platform",
      "coord": [
        24.569,
        46.75337
      ],
      "name": "Riyadh, Al Haeer 108",
      "parent": {
        "id": "225251",
        "isGlobalId": true,
        "disassembledName": "Al Haeer 108",
        "name": "Riyadh, Al Haeer 108",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9563,
        "STOP_GLOBAL_ID": "225251",
        "STOPPOINT_GLOBAL_ID": "22525101",
        "STOP_NAME_WITH_PLACE": "Al Haeer 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Haeer 108",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Haeer 108",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15320102",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 02",
      "type": "platform",
      "coord": [
        24.65604,
        46.67247
      ],
      "name": "Riyadh, Ash-Sharafiyah 502",
      "parent": {
        "id": "153201",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 502",
        "name": "Riyadh, Ash-Sharafiyah 502",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9564,
        "STOP_GLOBAL_ID": "153201",
        "STOPPOINT_GLOBAL_ID": "15320102",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 502",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 502",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22621902",
      "isGlobalId": true,
      "name": "Al Kharj 16",
      "type": "platform",
      "coord": [
        24.58545,
        46.81081
      ],
      "name": "Riyadh, Al Kharj 116",
      "parent": {
        "id": "226219",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 116",
        "name": "Riyadh, Al Kharj 116",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9571,
        "STOP_GLOBAL_ID": "226219",
        "STOPPOINT_GLOBAL_ID": "22621902",
        "STOP_NAME_WITH_PLACE": "Al Kharj 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 116",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 116",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16120801",
      "isGlobalId": true,
      "name": "Al-Badeah 06",
      "type": "platform",
      "coord": [
        24.61903,
        46.67739
      ],
      "name": "Riyadh, Al-Badeah 606",
      "parent": {
        "id": "161208",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 606",
        "name": "Riyadh, Al-Badeah 606",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9586,
        "STOP_GLOBAL_ID": "161208",
        "STOPPOINT_GLOBAL_ID": "16120801",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 606",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 606",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15520302",
      "isGlobalId": true,
      "name": "An-Nasiriyah 01",
      "type": "platform",
      "coord": [
        24.65156,
        46.67175
      ],
      "name": "Riyadh, An-Nasiriyah 501",
      "parent": {
        "id": "155203",
        "isGlobalId": true,
        "disassembledName": "An-Nasiriyah 501",
        "name": "Riyadh, An-Nasiriyah 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9596,
        "STOP_GLOBAL_ID": "155203",
        "STOPPOINT_GLOBAL_ID": "15520302",
        "STOP_NAME_WITH_PLACE": "An-Nasiriyah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasiriyah 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasiriyah 501",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15320101",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 02",
      "type": "platform",
      "coord": [
        24.65553,
        46.67211
      ],
      "name": "Riyadh, Ash-Sharafiyah 602",
      "parent": {
        "id": "153201",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 602",
        "name": "Riyadh, Ash-Sharafiyah 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9598,
        "STOP_GLOBAL_ID": "153201",
        "STOPPOINT_GLOBAL_ID": "15320101",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 602",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11420402",
      "isGlobalId": true,
      "name": "Takhassusi 17",
      "type": "platform",
      "coord": [
        24.6769,
        46.67811
      ],
      "name": "Riyadh, Takhassusi 117",
      "parent": {
        "id": "114204",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 117",
        "name": "Riyadh, Takhassusi 117",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9599,
        "STOP_GLOBAL_ID": "114204",
        "STOPPOINT_GLOBAL_ID": "11420402",
        "STOP_NAME_WITH_PLACE": "Takhassusi 17",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 117",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 117",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15520301",
      "isGlobalId": true,
      "name": "An-Nasiriyah 01",
      "type": "platform",
      "coord": [
        24.65184,
        46.67171
      ],
      "name": "Riyadh, An-Nasiriyah 601",
      "parent": {
        "id": "155203",
        "isGlobalId": true,
        "disassembledName": "An-Nasiriyah 601",
        "name": "Riyadh, An-Nasiriyah 601",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9603,
        "STOP_GLOBAL_ID": "155203",
        "STOPPOINT_GLOBAL_ID": "15520301",
        "STOP_NAME_WITH_PLACE": "An-Nasiriyah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "An-Nasiriyah 601",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, An-Nasiriyah 601",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "20320101",
      "isGlobalId": true,
      "name": "Khurais 01",
      "type": "platform",
      "coord": [
        24.72368,
        46.77587
      ],
      "name": "Riyadh, Khurais 401",
      "parent": {
        "id": "203201",
        "isGlobalId": true,
        "disassembledName": "Khurais 401",
        "name": "Riyadh, Khurais 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9607,
        "STOP_GLOBAL_ID": "203201",
        "STOPPOINT_GLOBAL_ID": "20320101",
        "STOP_NAME_WITH_PLACE": "Khurais 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Khurais 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Khurais 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15120202",
      "isGlobalId": true,
      "name": "King Khalid 06",
      "type": "platform",
      "coord": [
        24.66048,
        46.67276
      ],
      "name": "Riyadh, King Khalid 106",
      "parent": {
        "id": "151202",
        "isGlobalId": true,
        "disassembledName": "King Khalid 106",
        "name": "Riyadh, King Khalid 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9611,
        "STOP_GLOBAL_ID": "151202",
        "STOPPOINT_GLOBAL_ID": "15120202",
        "STOP_NAME_WITH_PLACE": "King Khalid 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 106",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22621901",
      "isGlobalId": true,
      "name": "Al Kharj 16",
      "type": "platform",
      "coord": [
        24.58546,
        46.8115
      ],
      "name": "Riyadh, Al Kharj 216",
      "parent": {
        "id": "226219",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 216",
        "name": "Riyadh, Al Kharj 216",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9618,
        "STOP_GLOBAL_ID": "226219",
        "STOPPOINT_GLOBAL_ID": "22621901",
        "STOP_NAME_WITH_PLACE": "Al Kharj 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 216",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 216",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15120201",
      "isGlobalId": true,
      "name": "King Khalid 06",
      "type": "platform",
      "coord": [
        24.66124,
        46.67224
      ],
      "name": "Riyadh, King Khalid 206",
      "parent": {
        "id": "151202",
        "isGlobalId": true,
        "disassembledName": "King Khalid 206",
        "name": "Riyadh, King Khalid 206",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9684,
        "STOP_GLOBAL_ID": "151202",
        "STOPPOINT_GLOBAL_ID": "15120201",
        "STOP_NAME_WITH_PLACE": "King Khalid 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 206",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 206",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15320302",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 04",
      "type": "platform",
      "coord": [
        24.65133,
        46.66979
      ],
      "name": "Riyadh, Ash-Sharafiyah 604",
      "parent": {
        "id": "153203",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 604",
        "name": "Riyadh, Ash-Sharafiyah 604",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9813,
        "STOP_GLOBAL_ID": "153203",
        "STOPPOINT_GLOBAL_ID": "15320302",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 604",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 604",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15320301",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 04",
      "type": "platform",
      "coord": [
        24.65119,
        46.66955
      ],
      "name": "Riyadh, Ash-Sharafiyah 504",
      "parent": {
        "id": "153203",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 504",
        "name": "Riyadh, Ash-Sharafiyah 504",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9838,
        "STOP_GLOBAL_ID": "153203",
        "STOPPOINT_GLOBAL_ID": "15320301",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 504",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 504",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15320201",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 03",
      "type": "platform",
      "coord": [
        24.65379,
        46.66965
      ],
      "name": "Riyadh, Ash-Sharafiyah 603",
      "parent": {
        "id": "153202",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 603",
        "name": "Riyadh, Ash-Sharafiyah 603",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9849,
        "STOP_GLOBAL_ID": "153202",
        "STOPPOINT_GLOBAL_ID": "15320201",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 603",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 603",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15320202",
      "isGlobalId": true,
      "name": "Ash-Sharafiyah 03",
      "type": "platform",
      "coord": [
        24.65394,
        46.66944
      ],
      "name": "Riyadh, Ash-Sharafiyah 503",
      "parent": {
        "id": "153202",
        "isGlobalId": true,
        "disassembledName": "Ash-Sharafiyah 503",
        "name": "Riyadh, Ash-Sharafiyah 503",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9875,
        "STOP_GLOBAL_ID": "153202",
        "STOPPOINT_GLOBAL_ID": "15320202",
        "STOP_NAME_WITH_PLACE": "Ash-Sharafiyah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ash-Sharafiyah 503",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ash-Sharafiyah 503",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11420501",
      "isGlobalId": true,
      "name": "Takhassusi 16",
      "type": "platform",
      "coord": [
        24.68088,
        46.6772
      ],
      "name": "Riyadh, Takhassusi 116",
      "parent": {
        "id": "114205",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 116",
        "name": "Riyadh, Takhassusi 116",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9887,
        "STOP_GLOBAL_ID": "114205",
        "STOPPOINT_GLOBAL_ID": "11420501",
        "STOP_NAME_WITH_PLACE": "Takhassusi 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 116",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 116",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11420502",
      "isGlobalId": true,
      "name": "Takhassusi 16",
      "type": "platform",
      "coord": [
        24.68215,
        46.67694
      ],
      "name": "Riyadh, Takhassusi 216",
      "parent": {
        "id": "114205",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 216",
        "name": "Riyadh, Takhassusi 216",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 9979,
        "STOP_GLOBAL_ID": "114205",
        "STOPPOINT_GLOBAL_ID": "11420502",
        "STOP_NAME_WITH_PLACE": "Takhassusi 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 216",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 216",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16121202",
      "isGlobalId": true,
      "name": "Al-Badeah 05",
      "type": "platform",
      "coord": [
        24.61459,
        46.67531
      ],
      "name": "Riyadh, Al-Badeah 605",
      "parent": {
        "id": "161212",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 605",
        "name": "Riyadh, Al-Badeah 605",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10005,
        "STOP_GLOBAL_ID": "161212",
        "STOPPOINT_GLOBAL_ID": "16121202",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 605",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 605",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16121201",
      "isGlobalId": true,
      "name": "Al-Badeah 05",
      "type": "platform",
      "coord": [
        24.61477,
        46.67505
      ],
      "name": "Riyadh, Al-Badeah 505",
      "parent": {
        "id": "161212",
        "isGlobalId": true,
        "disassembledName": "Al-Badeah 505",
        "name": "Riyadh, Al-Badeah 505",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10023,
        "STOP_GLOBAL_ID": "161212",
        "STOPPOINT_GLOBAL_ID": "16121201",
        "STOP_NAME_WITH_PLACE": "Al-Badeah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Badeah 505",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Badeah 505",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15020202",
      "isGlobalId": true,
      "name": "King Khalid 05",
      "type": "platform",
      "coord": [
        24.66478,
        46.66768
      ],
      "name": "Riyadh, King Khalid 205",
      "parent": {
        "id": "150202",
        "isGlobalId": true,
        "disassembledName": "King Khalid 205",
        "name": "Riyadh, King Khalid 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10267,
        "STOP_GLOBAL_ID": "150202",
        "STOPPOINT_GLOBAL_ID": "15020202",
        "STOP_NAME_WITH_PLACE": "King Khalid 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 205",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15020201",
      "isGlobalId": true,
      "name": "King Khalid 05",
      "type": "platform",
      "coord": [
        24.66439,
        46.66759
      ],
      "name": "Riyadh, King Khalid 105",
      "parent": {
        "id": "150202",
        "isGlobalId": true,
        "disassembledName": "King Khalid 105",
        "name": "Riyadh, King Khalid 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10267,
        "STOP_GLOBAL_ID": "150202",
        "STOPPOINT_GLOBAL_ID": "15020201",
        "STOP_NAME_WITH_PLACE": "King Khalid 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 105",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11425002",
      "isGlobalId": true,
      "name": "Olaya 16 (Rd)",
      "type": "platform",
      "coord": [
        24.69744,
        46.6835
      ],
      "name": "Riyadh, Olaya 216",
      "parent": {
        "id": "114250",
        "isGlobalId": true,
        "disassembledName": "Olaya 216",
        "name": "Riyadh, Olaya 216",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10325,
        "STOP_GLOBAL_ID": "114250",
        "STOPPOINT_GLOBAL_ID": "11425002",
        "STOP_NAME_WITH_PLACE": "Olaya 16 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 216",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 216",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11425001",
      "isGlobalId": true,
      "name": "Olaya 16 (Rd)",
      "type": "platform",
      "coord": [
        24.69726,
        46.68318
      ],
      "name": "Riyadh, Olaya 116",
      "parent": {
        "id": "114250",
        "isGlobalId": true,
        "disassembledName": "Olaya 116",
        "name": "Riyadh, Olaya 116",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10340,
        "STOP_GLOBAL_ID": "114250",
        "STOPPOINT_GLOBAL_ID": "11425001",
        "STOP_NAME_WITH_PLACE": "Olaya 16 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 116",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 116",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11420601",
      "isGlobalId": true,
      "name": "Takhassusi 15",
      "type": "platform",
      "coord": [
        24.6871,
        46.6741
      ],
      "name": "Riyadh, Takhassusi 115",
      "parent": {
        "id": "114206",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 115",
        "name": "Riyadh, Takhassusi 115",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10534,
        "STOP_GLOBAL_ID": "114206",
        "STOPPOINT_GLOBAL_ID": "11420601",
        "STOP_NAME_WITH_PLACE": "Takhassusi 15",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 115",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 115",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15020301",
      "isGlobalId": true,
      "name": "King Khalid 04",
      "type": "platform",
      "coord": [
        24.66666,
        46.66531
      ],
      "name": "Riyadh, King Khalid 204",
      "parent": {
        "id": "150203",
        "isGlobalId": true,
        "disassembledName": "King Khalid 204",
        "name": "Riyadh, King Khalid 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10576,
        "STOP_GLOBAL_ID": "150203",
        "STOPPOINT_GLOBAL_ID": "15020301",
        "STOP_NAME_WITH_PLACE": "King Khalid 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 204",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15020302",
      "isGlobalId": true,
      "name": "King Khalid 04",
      "type": "platform",
      "coord": [
        24.66648,
        46.66509
      ],
      "name": "Riyadh, King Khalid 104",
      "parent": {
        "id": "150203",
        "isGlobalId": true,
        "disassembledName": "King Khalid 104",
        "name": "Riyadh, King Khalid 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10594,
        "STOP_GLOBAL_ID": "150203",
        "STOPPOINT_GLOBAL_ID": "15020302",
        "STOP_NAME_WITH_PLACE": "King Khalid 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 104",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22621602",
      "isGlobalId": true,
      "name": "Al Kharj 17",
      "type": "platform",
      "coord": [
        24.57955,
        46.81798
      ],
      "name": "Riyadh, Al Kharj 117",
      "parent": {
        "id": "226216",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 117",
        "name": "Riyadh, Al Kharj 117",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10633,
        "STOP_GLOBAL_ID": "226216",
        "STOPPOINT_GLOBAL_ID": "22621602",
        "STOP_NAME_WITH_PLACE": "Al Kharj 17",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 117",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 117",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11420602",
      "isGlobalId": true,
      "name": "Takhassusi 15",
      "type": "platform",
      "coord": [
        24.68918,
        46.67343
      ],
      "name": "Riyadh, Takhassusi 215",
      "parent": {
        "id": "114206",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 215",
        "name": "Riyadh, Takhassusi 215",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10721,
        "STOP_GLOBAL_ID": "114206",
        "STOPPOINT_GLOBAL_ID": "11420602",
        "STOP_NAME_WITH_PLACE": "Takhassusi 15",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 215",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 215",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22621601",
      "isGlobalId": true,
      "name": "Al Kharj 17",
      "type": "platform",
      "coord": [
        24.57918,
        46.81924
      ],
      "name": "Riyadh, Al Kharj 217",
      "parent": {
        "id": "226216",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 217",
        "name": "Riyadh, Al Kharj 217",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10758,
        "STOP_GLOBAL_ID": "226216",
        "STOPPOINT_GLOBAL_ID": "22621601",
        "STOP_NAME_WITH_PLACE": "Al Kharj 17",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 217",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 217",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11520001",
      "isGlobalId": true,
      "name": "King Abdulaziz 07 (BRT)",
      "type": "platform",
      "coord": [
        24.7154,
        46.69679
      ],
      "name": "Riyadh, King Abdulaziz 07 A",
      "parent": {
        "id": "115200",
        "isGlobalId": true,
        "disassembledName": "King Abdulaziz 07 A",
        "name": "Riyadh, King Abdulaziz 07 A",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10787,
        "STOP_GLOBAL_ID": "115200",
        "STOPPOINT_GLOBAL_ID": "11520001",
        "STOP_NAME_WITH_PLACE": "King Abdulaziz 07 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdulaziz 07 A",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdulaziz 07 A",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11520002",
      "isGlobalId": true,
      "name": "King Abdulaziz 07 (BRT)",
      "type": "platform",
      "coord": [
        24.71548,
        46.69689
      ],
      "name": "Riyadh, King Abdulaziz 07 B",
      "parent": {
        "id": "115200",
        "isGlobalId": true,
        "disassembledName": "King Abdulaziz 07 B",
        "name": "Riyadh, King Abdulaziz 07 B",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10788,
        "STOP_GLOBAL_ID": "115200",
        "STOPPOINT_GLOBAL_ID": "11520002",
        "STOP_NAME_WITH_PLACE": "King Abdulaziz 07 (BRT)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdulaziz 07 B",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdulaziz 07 B",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15020402",
      "isGlobalId": true,
      "name": "King Khalid 03",
      "type": "platform",
      "coord": [
        24.66834,
        46.66285
      ],
      "name": "Riyadh, King Khalid 103",
      "parent": {
        "id": "150204",
        "isGlobalId": true,
        "disassembledName": "King Khalid 103",
        "name": "Riyadh, King Khalid 103",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10889,
        "STOP_GLOBAL_ID": "150204",
        "STOPPOINT_GLOBAL_ID": "15020402",
        "STOP_NAME_WITH_PLACE": "King Khalid 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 103",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 103",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15020401",
      "isGlobalId": true,
      "name": "King Khalid 03",
      "type": "platform",
      "coord": [
        24.66876,
        46.66278
      ],
      "name": "Riyadh, King Khalid 203",
      "parent": {
        "id": "150204",
        "isGlobalId": true,
        "disassembledName": "King Khalid 203",
        "name": "Riyadh, King Khalid 203",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 10910,
        "STOP_GLOBAL_ID": "150204",
        "STOPPOINT_GLOBAL_ID": "15020401",
        "STOP_NAME_WITH_PLACE": "King Khalid 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 203",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 203",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11425101",
      "isGlobalId": true,
      "name": "Olaya 14 (Rd)",
      "type": "platform",
      "coord": [
        24.70447,
        46.67954
      ],
      "name": "Riyadh, Olaya 114",
      "parent": {
        "id": "114251",
        "isGlobalId": true,
        "disassembledName": "Olaya 114",
        "name": "Riyadh, Olaya 114",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 11202,
        "STOP_GLOBAL_ID": "114251",
        "STOPPOINT_GLOBAL_ID": "11425101",
        "STOP_NAME_WITH_PLACE": "Olaya 14 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 114",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 114",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17120601",
      "isGlobalId": true,
      "name": "Takhassusi 14",
      "type": "platform",
      "coord": [
        24.69366,
        46.67078
      ],
      "name": "Riyadh, Takhassusi 114",
      "parent": {
        "id": "171206",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 114",
        "name": "Riyadh, Takhassusi 114",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 11249,
        "STOP_GLOBAL_ID": "171206",
        "STOPPOINT_GLOBAL_ID": "17120601",
        "STOP_NAME_WITH_PLACE": "Takhassusi 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 114",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 114",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11420803",
      "isGlobalId": true,
      "name": "Takhassusi 13",
      "type": "platform",
      "coord": [
        24.69575,
        46.67012
      ],
      "name": "Riyadh, Takhassusi 213",
      "parent": {
        "id": "114208",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 213",
        "name": "Riyadh, Takhassusi 213",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 11443,
        "STOP_GLOBAL_ID": "114208",
        "STOPPOINT_GLOBAL_ID": "11420803",
        "STOP_NAME_WITH_PLACE": "Takhassusi 13",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 213",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 213",
        "IDENTIFIER": "3"
      }
    },
    {
      "id": "11420802",
      "isGlobalId": true,
      "name": "Takhassusi 13",
      "type": "platform",
      "coord": [
        24.69671,
        46.6692
      ],
      "name": "Riyadh, Takhassusi 113",
      "parent": {
        "id": "114208",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 113",
        "name": "Riyadh, Takhassusi 113",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 11592,
        "STOP_GLOBAL_ID": "114208",
        "STOPPOINT_GLOBAL_ID": "11420802",
        "STOP_NAME_WITH_PLACE": "Takhassusi 13",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 113",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 113",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24023002",
      "isGlobalId": true,
      "name": "Madina Munwarah 14",
      "type": "platform",
      "coord": [
        24.61026,
        46.66001
      ],
      "name": "Riyadh, Madina Munwarah 314",
      "parent": {
        "id": "240230",
        "isGlobalId": true,
        "disassembledName": "Madina Munwarah 314",
        "name": "Riyadh, Madina Munwarah 314",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 11780,
        "STOP_GLOBAL_ID": "240230",
        "STOPPOINT_GLOBAL_ID": "24023002",
        "STOP_NAME_WITH_PLACE": "Madina Munwarah 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Madina Munwarah 314",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Madina Munwarah 314",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24023001",
      "isGlobalId": true,
      "name": "Madina Munwarah 14",
      "type": "platform",
      "coord": [
        24.6102,
        46.65946
      ],
      "name": "Riyadh, Madina Munwarah 414",
      "parent": {
        "id": "240230",
        "isGlobalId": true,
        "disassembledName": "Madina Munwarah 414",
        "name": "Riyadh, Madina Munwarah 414",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 11840,
        "STOP_GLOBAL_ID": "240230",
        "STOPPOINT_GLOBAL_ID": "24023001",
        "STOP_NAME_WITH_PLACE": "Madina Munwarah 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Madina Munwarah 414",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Madina Munwarah 414",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11424301",
      "isGlobalId": true,
      "name": "Olaya 13 (Rd)",
      "type": "platform",
      "coord": [
        24.71102,
        46.67626
      ],
      "name": "Riyadh, Olaya 113",
      "parent": {
        "id": "114243",
        "isGlobalId": true,
        "disassembledName": "Olaya 113",
        "name": "Riyadh, Olaya 113",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 11996,
        "STOP_GLOBAL_ID": "114243",
        "STOPPOINT_GLOBAL_ID": "11424301",
        "STOP_NAME_WITH_PLACE": "Olaya 13 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 113",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 113",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11424201",
      "isGlobalId": true,
      "name": "Olaya 12 (Rd)",
      "type": "platform",
      "coord": [
        24.71212,
        46.67604
      ],
      "name": "Riyadh, Olaya 212",
      "parent": {
        "id": "114242",
        "isGlobalId": true,
        "disassembledName": "Olaya 212",
        "name": "Riyadh, Olaya 212",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12104,
        "STOP_GLOBAL_ID": "114242",
        "STOPPOINT_GLOBAL_ID": "11424201",
        "STOP_NAME_WITH_PLACE": "Olaya 12 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 212",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 212",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "11420902",
      "isGlobalId": true,
      "name": "Takhassusi 12",
      "type": "platform",
      "coord": [
        24.70211,
        46.66691
      ],
      "name": "Riyadh, Takhassusi 212",
      "parent": {
        "id": "114209",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 212",
        "name": "Riyadh, Takhassusi 212",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12164,
        "STOP_GLOBAL_ID": "114209",
        "STOPPOINT_GLOBAL_ID": "11420902",
        "STOP_NAME_WITH_PLACE": "Takhassusi 12",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 212",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 212",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11420901",
      "isGlobalId": true,
      "name": "Takhassusi 12",
      "type": "platform",
      "coord": [
        24.70196,
        46.66659
      ],
      "name": "Riyadh, Takhassusi 112",
      "parent": {
        "id": "114209",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 112",
        "name": "Riyadh, Takhassusi 112",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12184,
        "STOP_GLOBAL_ID": "114209",
        "STOPPOINT_GLOBAL_ID": "11420901",
        "STOP_NAME_WITH_PLACE": "Takhassusi 12",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 112",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 112",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020901",
      "isGlobalId": true,
      "name": "Umm Al Hamam 08",
      "type": "platform",
      "coord": [
        24.68036,
        46.65418
      ],
      "name": "Riyadh, Umm Al Hamam 108",
      "parent": {
        "id": "170209",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 108",
        "name": "Riyadh, Umm Al Hamam 108",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12238,
        "STOP_GLOBAL_ID": "170209",
        "STOPPOINT_GLOBAL_ID": "17020901",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 108",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 108",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020902",
      "isGlobalId": true,
      "name": "Umm Al Hamam 08",
      "type": "platform",
      "coord": [
        24.68138,
        46.65418
      ],
      "name": "Riyadh, Umm Al Hamam 208",
      "parent": {
        "id": "170209",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 208",
        "name": "Riyadh, Umm Al Hamam 208",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12281,
        "STOP_GLOBAL_ID": "170209",
        "STOPPOINT_GLOBAL_ID": "17020902",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 208",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 208",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "22222201",
      "isGlobalId": true,
      "name": "Al Kharj 18",
      "type": "platform",
      "coord": [
        24.57016,
        46.83126
      ],
      "name": "Riyadh, Al Kharj 118",
      "parent": {
        "id": "222222",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 118",
        "name": "Riyadh, Al Kharj 118",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12465,
        "STOP_GLOBAL_ID": "222222",
        "STOPPOINT_GLOBAL_ID": "22222201",
        "STOP_NAME_WITH_PLACE": "Al Kharj 18",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 118",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 118",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24022901",
      "isGlobalId": true,
      "name": "Madina Munwarah 13",
      "type": "platform",
      "coord": [
        24.60741,
        46.65462
      ],
      "name": "Riyadh, Madina Munwarah 413",
      "parent": {
        "id": "240229",
        "isGlobalId": true,
        "disassembledName": "Madina Munwarah 413",
        "name": "Riyadh, Madina Munwarah 413",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12468,
        "STOP_GLOBAL_ID": "240229",
        "STOPPOINT_GLOBAL_ID": "24022901",
        "STOP_NAME_WITH_PLACE": "Madina Munwarah 13",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Madina Munwarah 413",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Madina Munwarah 413",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020802",
      "isGlobalId": true,
      "name": "Umm Al Hamam 07",
      "type": "platform",
      "coord": [
        24.68452,
        46.65275
      ],
      "name": "Riyadh, Umm Al Hamam 207",
      "parent": {
        "id": "170208",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 207",
        "name": "Riyadh, Umm Al Hamam 207",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12567,
        "STOP_GLOBAL_ID": "170208",
        "STOPPOINT_GLOBAL_ID": "17020802",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 207",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 207",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020801",
      "isGlobalId": true,
      "name": "Umm Al Hamam 07",
      "type": "platform",
      "coord": [
        24.68443,
        46.65237
      ],
      "name": "Riyadh, Umm Al Hamam 107",
      "parent": {
        "id": "170208",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 107",
        "name": "Riyadh, Umm Al Hamam 107",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12602,
        "STOP_GLOBAL_ID": "170208",
        "STOPPOINT_GLOBAL_ID": "17020801",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 107",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 107",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24022902",
      "isGlobalId": true,
      "name": "Madina Munwarah 13",
      "type": "platform",
      "coord": [
        24.60617,
        46.6534
      ],
      "name": "Riyadh, Madina Munwarah 313",
      "parent": {
        "id": "240229",
        "isGlobalId": true,
        "disassembledName": "Madina Munwarah 313",
        "name": "Riyadh, Madina Munwarah 313",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12653,
        "STOP_GLOBAL_ID": "240229",
        "STOPPOINT_GLOBAL_ID": "24022902",
        "STOP_NAME_WITH_PLACE": "Madina Munwarah 13",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Madina Munwarah 313",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Madina Munwarah 313",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "11421001",
      "isGlobalId": true,
      "name": "Takhassusi 11",
      "type": "platform",
      "coord": [
        24.70637,
        46.66433
      ],
      "name": "Riyadh, Takhassusi 111",
      "parent": {
        "id": "114210",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 111",
        "name": "Riyadh, Takhassusi 111",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12696,
        "STOP_GLOBAL_ID": "114210",
        "STOPPOINT_GLOBAL_ID": "11421001",
        "STOP_NAME_WITH_PLACE": "Takhassusi 11",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 111",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 111",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "10920602",
      "isGlobalId": true,
      "name": "Olaya 11 (Rd)",
      "type": "platform",
      "coord": [
        24.71697,
        46.6736
      ],
      "name": "Riyadh, Olaya 211",
      "parent": {
        "id": "109206",
        "isGlobalId": true,
        "disassembledName": "Olaya 211",
        "name": "Riyadh, Olaya 211",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12703,
        "STOP_GLOBAL_ID": "109206",
        "STOPPOINT_GLOBAL_ID": "10920602",
        "STOP_NAME_WITH_PLACE": "Olaya 11 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 211",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 211",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020702",
      "isGlobalId": true,
      "name": "Umm Al Hamam 06",
      "type": "platform",
      "coord": [
        24.68621,
        46.65161
      ],
      "name": "Riyadh, Umm Al Hamam 106",
      "parent": {
        "id": "170207",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 106",
        "name": "Riyadh, Umm Al Hamam 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12761,
        "STOP_GLOBAL_ID": "170207",
        "STOPPOINT_GLOBAL_ID": "17020702",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 106",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020701",
      "isGlobalId": true,
      "name": "Umm Al Hamam 06",
      "type": "platform",
      "coord": [
        24.68666,
        46.65177
      ],
      "name": "Riyadh, Umm Al Hamam 206",
      "parent": {
        "id": "170207",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 206",
        "name": "Riyadh, Umm Al Hamam 206",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12766,
        "STOP_GLOBAL_ID": "170207",
        "STOPPOINT_GLOBAL_ID": "17020701",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 206",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 206",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "22220101",
      "isGlobalId": true,
      "name": "Al Kharj 19",
      "type": "platform",
      "coord": [
        24.56906,
        46.83451
      ],
      "name": "Riyadh, Al Kharj 219",
      "parent": {
        "id": "222201",
        "isGlobalId": true,
        "disassembledName": "Al Kharj 219",
        "name": "Riyadh, Al Kharj 219",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12805,
        "STOP_GLOBAL_ID": "222201",
        "STOPPOINT_GLOBAL_ID": "22220101",
        "STOP_NAME_WITH_PLACE": "Al Kharj 19",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Kharj 219",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Kharj 219",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "10920601",
      "isGlobalId": true,
      "name": "Olaya 11 (Rd)",
      "type": "platform",
      "coord": [
        24.71769,
        46.67287
      ],
      "name": "Riyadh, Olaya 111",
      "parent": {
        "id": "109206",
        "isGlobalId": true,
        "disassembledName": "Olaya 111",
        "name": "Riyadh, Olaya 111",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12823,
        "STOP_GLOBAL_ID": "109206",
        "STOPPOINT_GLOBAL_ID": "10920601",
        "STOP_NAME_WITH_PLACE": "Olaya 11 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 111",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 111",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "20920302",
      "isGlobalId": true,
      "name": "Hassan Bin Thabit 10",
      "type": "platform",
      "coord": [
        24.71648,
        46.84592
      ],
      "name": "Riyadh, Hassan Bin Thabit 210",
      "parent": {
        "id": "209203",
        "isGlobalId": true,
        "disassembledName": "Hassan Bin Thabit 210",
        "name": "Riyadh, Hassan Bin Thabit 210",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 12987,
        "STOP_GLOBAL_ID": "209203",
        "STOPPOINT_GLOBAL_ID": "20920302",
        "STOP_NAME_WITH_PLACE": "Hassan Bin Thabit 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hassan Bin Thabit 210",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hassan Bin Thabit 210",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16921001",
      "isGlobalId": true,
      "name": "Takhassusi 10",
      "type": "platform",
      "coord": [
        24.70911,
        46.66307
      ],
      "name": "Riyadh, Takhassusi 110",
      "parent": {
        "id": "169210",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 110",
        "name": "Riyadh, Takhassusi 110",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13005,
        "STOP_GLOBAL_ID": "169210",
        "STOPPOINT_GLOBAL_ID": "16921001",
        "STOP_NAME_WITH_PLACE": "Takhassusi 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 110",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 110",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "20920401",
      "isGlobalId": true,
      "name": "Hassan Bin Thabit 09",
      "type": "platform",
      "coord": [
        24.71889,
        46.84379
      ],
      "name": "Riyadh, Hassan Bin Thabit 109",
      "parent": {
        "id": "209204",
        "isGlobalId": true,
        "disassembledName": "Hassan Bin Thabit 109",
        "name": "Riyadh, Hassan Bin Thabit 109",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13007,
        "STOP_GLOBAL_ID": "209204",
        "STOPPOINT_GLOBAL_ID": "20920401",
        "STOP_NAME_WITH_PLACE": "Hassan Bin Thabit 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hassan Bin Thabit 109",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hassan Bin Thabit 109",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24022802",
      "isGlobalId": true,
      "name": "Madina Munwarah 12",
      "type": "platform",
      "coord": [
        24.60437,
        46.6503
      ],
      "name": "Riyadh, Madina Munwarah 312",
      "parent": {
        "id": "240228",
        "isGlobalId": true,
        "disassembledName": "Madina Munwarah 312",
        "name": "Riyadh, Madina Munwarah 312",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13057,
        "STOP_GLOBAL_ID": "240228",
        "STOPPOINT_GLOBAL_ID": "24022802",
        "STOP_NAME_WITH_PLACE": "Madina Munwarah 12",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Madina Munwarah 312",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Madina Munwarah 312",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020601",
      "isGlobalId": true,
      "name": "Umm Al Hamam 05",
      "type": "platform",
      "coord": [
        24.69035,
        46.6505
      ],
      "name": "Riyadh, Umm Al Hamam 105",
      "parent": {
        "id": "170206",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 105",
        "name": "Riyadh, Umm Al Hamam 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13073,
        "STOP_GLOBAL_ID": "170206",
        "STOPPOINT_GLOBAL_ID": "17020601",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 105",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16921002",
      "isGlobalId": true,
      "name": "Takhassusi 10",
      "type": "platform",
      "coord": [
        24.71014,
        46.66301
      ],
      "name": "Riyadh, Takhassusi 210",
      "parent": {
        "id": "169210",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 210",
        "name": "Riyadh, Takhassusi 210",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13084,
        "STOP_GLOBAL_ID": "169210",
        "STOPPOINT_GLOBAL_ID": "16921002",
        "STOP_NAME_WITH_PLACE": "Takhassusi 10",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 210",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 210",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "20820301",
      "isGlobalId": true,
      "name": "Hassan Bin Thabit 08",
      "type": "platform",
      "coord": [
        24.72277,
        46.84091
      ],
      "name": "Riyadh, Hassan Bin Thabit 108",
      "parent": {
        "id": "208203",
        "isGlobalId": true,
        "disassembledName": "Hassan Bin Thabit 108",
        "name": "Riyadh, Hassan Bin Thabit 108",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13105,
        "STOP_GLOBAL_ID": "208203",
        "STOPPOINT_GLOBAL_ID": "20820301",
        "STOP_NAME_WITH_PLACE": "Hassan Bin Thabit 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hassan Bin Thabit 108",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hassan Bin Thabit 108",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020602",
      "isGlobalId": true,
      "name": "Umm Al Hamam 05",
      "type": "platform",
      "coord": [
        24.6915,
        46.6506
      ],
      "name": "Riyadh, Umm Al Hamam 205",
      "parent": {
        "id": "170206",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 205",
        "name": "Riyadh, Umm Al Hamam 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13121,
        "STOP_GLOBAL_ID": "170206",
        "STOPPOINT_GLOBAL_ID": "17020602",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 205",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "20820302",
      "isGlobalId": true,
      "name": "Hassan Bin Thabit 08",
      "type": "platform",
      "coord": [
        24.72386,
        46.84046
      ],
      "name": "Riyadh, Hassan Bin Thabit 208",
      "parent": {
        "id": "208203",
        "isGlobalId": true,
        "disassembledName": "Hassan Bin Thabit 208",
        "name": "Riyadh, Hassan Bin Thabit 208",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13165,
        "STOP_GLOBAL_ID": "208203",
        "STOPPOINT_GLOBAL_ID": "20820302",
        "STOP_NAME_WITH_PLACE": "Hassan Bin Thabit 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hassan Bin Thabit 208",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hassan Bin Thabit 208",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24022801",
      "isGlobalId": true,
      "name": "Madina Munwarah 12",
      "type": "platform",
      "coord": [
        24.60406,
        46.64923
      ],
      "name": "Riyadh, Madina Munwarah 412",
      "parent": {
        "id": "240228",
        "isGlobalId": true,
        "disassembledName": "Madina Munwarah 412",
        "name": "Riyadh, Madina Munwarah 412",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13181,
        "STOP_GLOBAL_ID": "240228",
        "STOPPOINT_GLOBAL_ID": "24022801",
        "STOP_NAME_WITH_PLACE": "Madina Munwarah 12",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Madina Munwarah 412",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Madina Munwarah 412",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020501",
      "isGlobalId": true,
      "name": "Umm Al Hamam 04",
      "type": "platform",
      "coord": [
        24.69376,
        46.65023
      ],
      "name": "Riyadh, Umm Al Hamam 204",
      "parent": {
        "id": "170205",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 204",
        "name": "Riyadh, Umm Al Hamam 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13275,
        "STOP_GLOBAL_ID": "170205",
        "STOPPOINT_GLOBAL_ID": "17020501",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 204",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020502",
      "isGlobalId": true,
      "name": "Umm Al Hamam 04",
      "type": "platform",
      "coord": [
        24.69412,
        46.64981
      ],
      "name": "Riyadh, Umm Al Hamam 104",
      "parent": {
        "id": "170205",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 104",
        "name": "Riyadh, Umm Al Hamam 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13337,
        "STOP_GLOBAL_ID": "170205",
        "STOPPOINT_GLOBAL_ID": "17020502",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 104",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020301",
      "isGlobalId": true,
      "name": "Umm Al Hamam 01",
      "type": "platform",
      "coord": [
        24.70042,
        46.65319
      ],
      "name": "Riyadh, Umm Al Hamam 201",
      "parent": {
        "id": "170203",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 201",
        "name": "Riyadh, Umm Al Hamam 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13359,
        "STOP_GLOBAL_ID": "170203",
        "STOPPOINT_GLOBAL_ID": "17020301",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 201",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020302",
      "isGlobalId": true,
      "name": "Umm Al Hamam 01",
      "type": "platform",
      "coord": [
        24.70119,
        46.65362
      ],
      "name": "Riyadh, Umm Al Hamam 101",
      "parent": {
        "id": "170203",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 101",
        "name": "Riyadh, Umm Al Hamam 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13364,
        "STOP_GLOBAL_ID": "170203",
        "STOPPOINT_GLOBAL_ID": "17020302",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 101",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020401",
      "isGlobalId": true,
      "name": "Umm Al Hamam 02",
      "type": "platform",
      "coord": [
        24.69877,
        46.65118
      ],
      "name": "Riyadh, Umm Al Hamam 202",
      "parent": {
        "id": "170204",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 202",
        "name": "Riyadh, Umm Al Hamam 202",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13458,
        "STOP_GLOBAL_ID": "170204",
        "STOPPOINT_GLOBAL_ID": "17020401",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 202",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 202",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "15020802",
      "isGlobalId": true,
      "name": "Umm Al Hamam 03",
      "type": "platform",
      "coord": [
        24.69629,
        46.64951
      ],
      "name": "Riyadh, Umm Al Hamam 103",
      "parent": {
        "id": "150208",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 103",
        "name": "Riyadh, Umm Al Hamam 103",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13483,
        "STOP_GLOBAL_ID": "150208",
        "STOPPOINT_GLOBAL_ID": "15020802",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 103",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 103",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "15020801",
      "isGlobalId": true,
      "name": "Umm Al Hamam 03",
      "type": "platform",
      "coord": [
        24.69663,
        46.6497
      ],
      "name": "Riyadh, Umm Al Hamam 203",
      "parent": {
        "id": "150208",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 203",
        "name": "Riyadh, Umm Al Hamam 203",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13483,
        "STOP_GLOBAL_ID": "150208",
        "STOPPOINT_GLOBAL_ID": "15020801",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 203",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 203",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020402",
      "isGlobalId": true,
      "name": "Umm Al Hamam 02",
      "type": "platform",
      "coord": [
        24.69847,
        46.65035
      ],
      "name": "Riyadh, Umm Al Hamam 102",
      "parent": {
        "id": "170204",
        "isGlobalId": true,
        "disassembledName": "Umm Al Hamam 102",
        "name": "Riyadh, Umm Al Hamam 102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13523,
        "STOP_GLOBAL_ID": "170204",
        "STOPPOINT_GLOBAL_ID": "17020402",
        "STOP_NAME_WITH_PLACE": "Umm Al Hamam 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Umm Al Hamam 102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Umm Al Hamam 102",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "10920701",
      "isGlobalId": true,
      "name": "Olaya 10 (Rd)",
      "type": "platform",
      "coord": [
        24.72481,
        46.66927
      ],
      "name": "Riyadh, Olaya 110",
      "parent": {
        "id": "109207",
        "isGlobalId": true,
        "disassembledName": "Olaya 110",
        "name": "Riyadh, Olaya 110",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13713,
        "STOP_GLOBAL_ID": "109207",
        "STOPPOINT_GLOBAL_ID": "10920701",
        "STOP_NAME_WITH_PLACE": "Olaya 10 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 110",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 110",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020002",
      "isGlobalId": true,
      "name": "Al Urubah 04",
      "type": "platform",
      "coord": [
        24.70353,
        46.6514
      ],
      "name": "Riyadh, Al Urubah 404",
      "parent": {
        "id": "170200",
        "isGlobalId": true,
        "disassembledName": "Al Urubah 404",
        "name": "Riyadh, Al Urubah 404",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13722,
        "STOP_GLOBAL_ID": "170200",
        "STOPPOINT_GLOBAL_ID": "17020002",
        "STOP_NAME_WITH_PLACE": "Al Urubah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Urubah 404",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Urubah 404",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16920501",
      "isGlobalId": true,
      "name": "Takhassusi 09",
      "type": "platform",
      "coord": [
        24.71535,
        46.65994
      ],
      "name": "Riyadh, Takhassusi 109",
      "parent": {
        "id": "169205",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 109",
        "name": "Riyadh, Takhassusi 109",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13741,
        "STOP_GLOBAL_ID": "169205",
        "STOPPOINT_GLOBAL_ID": "16920501",
        "STOP_NAME_WITH_PLACE": "Takhassusi 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 109",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 109",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "10920702",
      "isGlobalId": true,
      "name": "Olaya 10 (Rd)",
      "type": "platform",
      "coord": [
        24.72531,
        46.66937
      ],
      "name": "Riyadh, Olaya 210",
      "parent": {
        "id": "109207",
        "isGlobalId": true,
        "disassembledName": "Olaya 210",
        "name": "Riyadh, Olaya 210",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13747,
        "STOP_GLOBAL_ID": "109207",
        "STOPPOINT_GLOBAL_ID": "10920702",
        "STOP_NAME_WITH_PLACE": "Olaya 10 (Rd)",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Olaya 210",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Olaya 210",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020001",
      "isGlobalId": true,
      "name": "Al Urubah 04",
      "type": "platform",
      "coord": [
        24.70173,
        46.64834
      ],
      "name": "Riyadh, Al Urubah 304",
      "parent": {
        "id": "170200",
        "isGlobalId": true,
        "disassembledName": "Al Urubah 304",
        "name": "Riyadh, Al Urubah 304",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13909,
        "STOP_GLOBAL_ID": "170200",
        "STOPPOINT_GLOBAL_ID": "17020001",
        "STOP_NAME_WITH_PLACE": "Al Urubah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Urubah 304",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Urubah 304",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16920502",
      "isGlobalId": true,
      "name": "Takhassusi 09",
      "type": "platform",
      "coord": [
        24.71709,
        46.6595
      ],
      "name": "Riyadh, Takhassusi 209",
      "parent": {
        "id": "169205",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 209",
        "name": "Riyadh, Takhassusi 209",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13910,
        "STOP_GLOBAL_ID": "169205",
        "STOPPOINT_GLOBAL_ID": "16920502",
        "STOP_NAME_WITH_PLACE": "Takhassusi 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 209",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 209",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24022401",
      "isGlobalId": true,
      "name": "Ayesha Bint Abi Bakr 04",
      "type": "platform",
      "coord": [
        24.60403,
        46.64146
      ],
      "name": "Riyadh, Ayesha Bint Abi Bakr 204",
      "parent": {
        "id": "240224",
        "isGlobalId": true,
        "disassembledName": "Ayesha Bint Abi Bakr 204",
        "name": "Riyadh, Ayesha Bint Abi Bakr 204",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 13980,
        "STOP_GLOBAL_ID": "240224",
        "STOPPOINT_GLOBAL_ID": "24022401",
        "STOP_NAME_WITH_PLACE": "Ayesha Bint Abi Bakr 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ayesha Bint Abi Bakr 204",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ayesha Bint Abi Bakr 204",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24022402",
      "isGlobalId": true,
      "name": "Ayesha Bint Abi Bakr 04",
      "type": "platform",
      "coord": [
        24.60345,
        46.64137
      ],
      "name": "Riyadh, Ayesha Bint Abi Bakr 104",
      "parent": {
        "id": "240224",
        "isGlobalId": true,
        "disassembledName": "Ayesha Bint Abi Bakr 104",
        "name": "Riyadh, Ayesha Bint Abi Bakr 104",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14017,
        "STOP_GLOBAL_ID": "240224",
        "STOPPOINT_GLOBAL_ID": "24022402",
        "STOP_NAME_WITH_PLACE": "Ayesha Bint Abi Bakr 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ayesha Bint Abi Bakr 104",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ayesha Bint Abi Bakr 104",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16920701",
      "isGlobalId": true,
      "name": "Takhassusi 08",
      "type": "platform",
      "coord": [
        24.71925,
        46.65819
      ],
      "name": "Riyadh, Takhassusi 208",
      "parent": {
        "id": "169207",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 208",
        "name": "Riyadh, Takhassusi 208",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14189,
        "STOP_GLOBAL_ID": "169207",
        "STOPPOINT_GLOBAL_ID": "16920701",
        "STOP_NAME_WITH_PLACE": "Takhassusi 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 208",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 208",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16920702",
      "isGlobalId": true,
      "name": "Takhassusi 08",
      "type": "platform",
      "coord": [
        24.71971,
        46.6574
      ],
      "name": "Riyadh, Takhassusi 108",
      "parent": {
        "id": "169207",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 108",
        "name": "Riyadh, Takhassusi 108",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14293,
        "STOP_GLOBAL_ID": "169207",
        "STOPPOINT_GLOBAL_ID": "16920702",
        "STOP_NAME_WITH_PLACE": "Takhassusi 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 108",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 108",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020101",
      "isGlobalId": true,
      "name": "Al Urubah 03",
      "type": "platform",
      "coord": [
        24.70018,
        46.64348
      ],
      "name": "Riyadh, Al Urubah 403",
      "parent": {
        "id": "170201",
        "isGlobalId": true,
        "disassembledName": "Al Urubah 403",
        "name": "Riyadh, Al Urubah 403",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14298,
        "STOP_GLOBAL_ID": "170201",
        "STOPPOINT_GLOBAL_ID": "17020101",
        "STOP_NAME_WITH_PLACE": "Al Urubah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Urubah 403",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Urubah 403",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "17020102",
      "isGlobalId": true,
      "name": "Al Urubah 03",
      "type": "platform",
      "coord": [
        24.69929,
        46.64263
      ],
      "name": "Riyadh, Al Urubah 303",
      "parent": {
        "id": "170201",
        "isGlobalId": true,
        "disassembledName": "Al Urubah 303",
        "name": "Riyadh, Al Urubah 303",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14333,
        "STOP_GLOBAL_ID": "170201",
        "STOPPOINT_GLOBAL_ID": "17020102",
        "STOP_NAME_WITH_PLACE": "Al Urubah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Urubah 303",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Urubah 303",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "17020202",
      "isGlobalId": true,
      "name": "Al Urubah 02",
      "type": "platform",
      "coord": [
        24.69651,
        46.63604
      ],
      "name": "Riyadh, Al Urubah 302",
      "parent": {
        "id": "170202",
        "isGlobalId": true,
        "disassembledName": "Al Urubah 302",
        "name": "Riyadh, Al Urubah 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14851,
        "STOP_GLOBAL_ID": "170202",
        "STOPPOINT_GLOBAL_ID": "17020202",
        "STOP_NAME_WITH_PLACE": "Al Urubah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Urubah 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Urubah 302",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16920801",
      "isGlobalId": true,
      "name": "King Abdullah 09",
      "type": "platform",
      "coord": [
        24.72291,
        46.65334
      ],
      "name": "Riyadh, King Abdullah 309",
      "parent": {
        "id": "169208",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 309",
        "name": "Riyadh, King Abdullah 309",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14891,
        "STOP_GLOBAL_ID": "169208",
        "STOPPOINT_GLOBAL_ID": "16920801",
        "STOP_NAME_WITH_PLACE": "King Abdullah 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 309",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 309",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24022702",
      "isGlobalId": true,
      "name": "Ibnul-Jouzi 02",
      "type": "platform",
      "coord": [
        24.59816,
        46.63497
      ],
      "name": "Riyadh, Ibnul-Jouzi 302",
      "parent": {
        "id": "240227",
        "isGlobalId": true,
        "disassembledName": "Ibnul-Jouzi 302",
        "name": "Riyadh, Ibnul-Jouzi 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 14925,
        "STOP_GLOBAL_ID": "240227",
        "STOPPOINT_GLOBAL_ID": "24022702",
        "STOP_NAME_WITH_PLACE": "Ibnul-Jouzi 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ibnul-Jouzi 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ibnul-Jouzi 302",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "24022701",
      "isGlobalId": true,
      "name": "Ibnul-Jouzi 02",
      "type": "platform",
      "coord": [
        24.59793,
        46.63423
      ],
      "name": "Riyadh, Ibnul-Jouzi 402",
      "parent": {
        "id": "240227",
        "isGlobalId": true,
        "disassembledName": "Ibnul-Jouzi 402",
        "name": "Riyadh, Ibnul-Jouzi 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15012,
        "STOP_GLOBAL_ID": "240227",
        "STOPPOINT_GLOBAL_ID": "24022701",
        "STOP_NAME_WITH_PLACE": "Ibnul-Jouzi 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ibnul-Jouzi 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ibnul-Jouzi 402",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16720301",
      "isGlobalId": true,
      "name": "Takhassusi 07",
      "type": "platform",
      "coord": [
        24.72469,
        46.65347
      ],
      "name": "Riyadh, Takhassusi 107",
      "parent": {
        "id": "167203",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 107",
        "name": "Riyadh, Takhassusi 107",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15018,
        "STOP_GLOBAL_ID": "167203",
        "STOPPOINT_GLOBAL_ID": "16720301",
        "STOP_NAME_WITH_PLACE": "Takhassusi 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 107",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 107",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16921101",
      "isGlobalId": true,
      "name": "King Abdullah 08",
      "type": "platform",
      "coord": [
        24.72254,
        46.65086
      ],
      "name": "Riyadh, King Abdullah 408",
      "parent": {
        "id": "169211",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 408",
        "name": "Riyadh, King Abdullah 408",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15080,
        "STOP_GLOBAL_ID": "169211",
        "STOPPOINT_GLOBAL_ID": "16921101",
        "STOP_NAME_WITH_PLACE": "King Abdullah 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 408",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 408",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16820501",
      "isGlobalId": true,
      "name": "Al Urubah 01",
      "type": "platform",
      "coord": [
        24.69583,
        46.63315
      ],
      "name": "Riyadh, Al Urubah 401",
      "parent": {
        "id": "168205",
        "isGlobalId": true,
        "disassembledName": "Al Urubah 401",
        "name": "Riyadh, Al Urubah 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15111,
        "STOP_GLOBAL_ID": "168205",
        "STOPPOINT_GLOBAL_ID": "16820501",
        "STOP_NAME_WITH_PLACE": "Al Urubah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Urubah 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Urubah 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16720302",
      "isGlobalId": true,
      "name": "Takhassusi 07",
      "type": "platform",
      "coord": [
        24.72632,
        46.65282
      ],
      "name": "Riyadh, Takhassusi 207",
      "parent": {
        "id": "167203",
        "isGlobalId": true,
        "disassembledName": "Takhassusi 207",
        "name": "Riyadh, Takhassusi 207",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15200,
        "STOP_GLOBAL_ID": "167203",
        "STOPPOINT_GLOBAL_ID": "16720302",
        "STOP_NAME_WITH_PLACE": "Takhassusi 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Takhassusi 207",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Takhassusi 207",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14920102",
      "isGlobalId": true,
      "name": "Jeddah 14",
      "type": "platform",
      "coord": [
        24.66676,
        46.62235
      ],
      "name": "Riyadh, Jeddah 314",
      "parent": {
        "id": "149201",
        "isGlobalId": true,
        "disassembledName": "Jeddah 314",
        "name": "Riyadh, Jeddah 314",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15273,
        "STOP_GLOBAL_ID": "149201",
        "STOPPOINT_GLOBAL_ID": "14920102",
        "STOP_NAME_WITH_PLACE": "Jeddah 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Jeddah 314",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Jeddah 314",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "14920101",
      "isGlobalId": true,
      "name": "Jeddah 14",
      "type": "platform",
      "coord": [
        24.66762,
        46.62207
      ],
      "name": "Riyadh, Jeddah 414",
      "parent": {
        "id": "149201",
        "isGlobalId": true,
        "disassembledName": "Jeddah 414",
        "name": "Riyadh, Jeddah 414",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15320,
        "STOP_GLOBAL_ID": "149201",
        "STOPPOINT_GLOBAL_ID": "14920101",
        "STOP_NAME_WITH_PLACE": "Jeddah 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Jeddah 414",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Jeddah 414",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16820101",
      "isGlobalId": true,
      "name": "King Abdullah 07",
      "type": "platform",
      "coord": [
        24.7186,
        46.64305
      ],
      "name": "Riyadh, King Abdullah 307",
      "parent": {
        "id": "168201",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 307",
        "name": "Riyadh, King Abdullah 307",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15496,
        "STOP_GLOBAL_ID": "168201",
        "STOPPOINT_GLOBAL_ID": "16820101",
        "STOP_NAME_WITH_PLACE": "King Abdullah 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 307",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 307",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16820401",
      "isGlobalId": true,
      "name": "King Abdullah 06",
      "type": "platform",
      "coord": [
        24.71808,
        46.64042
      ],
      "name": "Riyadh, King Abdullah 406",
      "parent": {
        "id": "168204",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 406",
        "name": "Riyadh, King Abdullah 406",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15704,
        "STOP_GLOBAL_ID": "168204",
        "STOPPOINT_GLOBAL_ID": "16820401",
        "STOP_NAME_WITH_PLACE": "King Abdullah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 406",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 406",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16820201",
      "isGlobalId": true,
      "name": "King Abdullah 05",
      "type": "platform",
      "coord": [
        24.71683,
        46.63922
      ],
      "name": "Riyadh, King Abdullah 305",
      "parent": {
        "id": "168202",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 305",
        "name": "Riyadh, King Abdullah 305",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15732,
        "STOP_GLOBAL_ID": "168202",
        "STOPPOINT_GLOBAL_ID": "16820201",
        "STOP_NAME_WITH_PLACE": "King Abdullah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 305",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 305",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "14920001",
      "isGlobalId": true,
      "name": "Jeddah 13",
      "type": "platform",
      "coord": [
        24.66437,
        46.61739
      ],
      "name": "Riyadh, Jeddah 313",
      "parent": {
        "id": "149200",
        "isGlobalId": true,
        "disassembledName": "Jeddah 313",
        "name": "Riyadh, Jeddah 313",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15776,
        "STOP_GLOBAL_ID": "149200",
        "STOPPOINT_GLOBAL_ID": "14920001",
        "STOP_NAME_WITH_PLACE": "Jeddah 13",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Jeddah 313",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Jeddah 313",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16820202",
      "isGlobalId": true,
      "name": "King Abdullah 05",
      "type": "platform",
      "coord": [
        24.71748,
        46.639
      ],
      "name": "Riyadh, King Abdullah 405",
      "parent": {
        "id": "168202",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 405",
        "name": "Riyadh, King Abdullah 405",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15795,
        "STOP_GLOBAL_ID": "168202",
        "STOPPOINT_GLOBAL_ID": "16820202",
        "STOP_NAME_WITH_PLACE": "King Abdullah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 405",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 405",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16820302",
      "isGlobalId": true,
      "name": "King Khalid 02",
      "type": "platform",
      "coord": [
        24.69759,
        46.62704
      ],
      "name": "Riyadh, King Khalid 102",
      "parent": {
        "id": "168203",
        "isGlobalId": true,
        "disassembledName": "King Khalid 102",
        "name": "Riyadh, King Khalid 102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15822,
        "STOP_GLOBAL_ID": "168203",
        "STOPPOINT_GLOBAL_ID": "16820302",
        "STOP_NAME_WITH_PLACE": "King Khalid 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 102",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16820301",
      "isGlobalId": true,
      "name": "King Khalid 02",
      "type": "platform",
      "coord": [
        24.69955,
        46.62663
      ],
      "name": "Riyadh, King Khalid 202",
      "parent": {
        "id": "168203",
        "isGlobalId": true,
        "disassembledName": "King Khalid 202",
        "name": "Riyadh, King Khalid 202",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15959,
        "STOP_GLOBAL_ID": "168203",
        "STOPPOINT_GLOBAL_ID": "16820301",
        "STOP_NAME_WITH_PLACE": "King Khalid 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 202",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 202",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24022601",
      "isGlobalId": true,
      "name": "Ibnul-Jouzi 01",
      "type": "platform",
      "coord": [
        24.59345,
        46.62689
      ],
      "name": "Riyadh, Ibnul-Jouzi 401",
      "parent": {
        "id": "240226",
        "isGlobalId": true,
        "disassembledName": "Ibnul-Jouzi 401",
        "name": "Riyadh, Ibnul-Jouzi 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15981,
        "STOP_GLOBAL_ID": "240226",
        "STOPPOINT_GLOBAL_ID": "24022601",
        "STOP_NAME_WITH_PLACE": "Ibnul-Jouzi 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ibnul-Jouzi 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ibnul-Jouzi 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "24022602",
      "isGlobalId": true,
      "name": "Ibnul-Jouzi 01",
      "type": "platform",
      "coord": [
        24.59322,
        46.62696
      ],
      "name": "Riyadh, Ibnul-Jouzi 301",
      "parent": {
        "id": "240226",
        "isGlobalId": true,
        "disassembledName": "Ibnul-Jouzi 301",
        "name": "Riyadh, Ibnul-Jouzi 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 15986,
        "STOP_GLOBAL_ID": "240226",
        "STOPPOINT_GLOBAL_ID": "24022602",
        "STOP_NAME_WITH_PLACE": "Ibnul-Jouzi 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ibnul-Jouzi 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ibnul-Jouzi 301",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16620801",
      "isGlobalId": true,
      "name": "King Abdullah 04",
      "type": "platform",
      "coord": [
        24.71492,
        46.63488
      ],
      "name": "Riyadh, King Abdullah 304",
      "parent": {
        "id": "166208",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 304",
        "name": "Riyadh, King Abdullah 304",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16016,
        "STOP_GLOBAL_ID": "166208",
        "STOPPOINT_GLOBAL_ID": "16620801",
        "STOP_NAME_WITH_PLACE": "King Abdullah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 304",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 304",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16620802",
      "isGlobalId": true,
      "name": "King Abdullah 04",
      "type": "platform",
      "coord": [
        24.71505,
        46.63417
      ],
      "name": "Riyadh, King Abdullah 404",
      "parent": {
        "id": "166208",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 404",
        "name": "Riyadh, King Abdullah 404",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16092,
        "STOP_GLOBAL_ID": "166208",
        "STOPPOINT_GLOBAL_ID": "16620802",
        "STOP_NAME_WITH_PLACE": "King Abdullah 04",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 404",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 404",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16621502",
      "isGlobalId": true,
      "name": "King Abdullah 02",
      "type": "platform",
      "coord": [
        24.71117,
        46.63057
      ],
      "name": "Riyadh, King Abdullah 302",
      "parent": {
        "id": "166215",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 302",
        "name": "Riyadh, King Abdullah 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16200,
        "STOP_GLOBAL_ID": "166215",
        "STOPPOINT_GLOBAL_ID": "16621502",
        "STOP_NAME_WITH_PLACE": "King Abdullah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 302",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16621601",
      "isGlobalId": true,
      "name": "King Abdullah 03",
      "type": "platform",
      "coord": [
        24.71318,
        46.63182
      ],
      "name": "Riyadh, King Abdullah 403",
      "parent": {
        "id": "166216",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 403",
        "name": "Riyadh, King Abdullah 403",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16200,
        "STOP_GLOBAL_ID": "166216",
        "STOPPOINT_GLOBAL_ID": "16621601",
        "STOP_NAME_WITH_PLACE": "King Abdullah 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 403",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 403",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16621501",
      "isGlobalId": true,
      "name": "King Abdullah 02",
      "type": "platform",
      "coord": [
        24.71032,
        46.62903
      ],
      "name": "Riyadh, King Abdullah 402",
      "parent": {
        "id": "166215",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 402",
        "name": "Riyadh, King Abdullah 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16300,
        "STOP_GLOBAL_ID": "166215",
        "STOPPOINT_GLOBAL_ID": "16621501",
        "STOP_NAME_WITH_PLACE": "King Abdullah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 402",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16620401",
      "isGlobalId": true,
      "name": "King Abdullah 01",
      "type": "platform",
      "coord": [
        24.7084,
        46.62785
      ],
      "name": "Riyadh, King Abdullah 301",
      "parent": {
        "id": "166204",
        "isGlobalId": true,
        "disassembledName": "King Abdullah 301",
        "name": "Riyadh, King Abdullah 301",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16305,
        "STOP_GLOBAL_ID": "166204",
        "STOPPOINT_GLOBAL_ID": "16620401",
        "STOP_NAME_WITH_PLACE": "King Abdullah 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Abdullah 301",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Abdullah 301",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23922201",
      "isGlobalId": true,
      "name": "Hamza Bin Abdulmuttalib 07",
      "type": "platform",
      "coord": [
        24.59048,
        46.62312
      ],
      "name": "Riyadh, Hamza Bin Abdulmuttalib 207",
      "parent": {
        "id": "239222",
        "isGlobalId": true,
        "disassembledName": "Hamza Bin Abdulmuttalib 207",
        "name": "Riyadh, Hamza Bin Abdulmuttalib 207",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16514,
        "STOP_GLOBAL_ID": "239222",
        "STOPPOINT_GLOBAL_ID": "23922201",
        "STOP_NAME_WITH_PLACE": "Hamza Bin Abdulmuttalib 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hamza Bin Abdulmuttalib 207",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hamza Bin Abdulmuttalib 207",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23922301",
      "isGlobalId": true,
      "name": "Hamza Bin Abdulmuttalib 06",
      "type": "platform",
      "coord": [
        24.5921,
        46.62192
      ],
      "name": "Riyadh, Hamza Bin Abdulmuttalib 206",
      "parent": {
        "id": "239223",
        "isGlobalId": true,
        "disassembledName": "Hamza Bin Abdulmuttalib 206",
        "name": "Riyadh, Hamza Bin Abdulmuttalib 206",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16554,
        "STOP_GLOBAL_ID": "239223",
        "STOPPOINT_GLOBAL_ID": "23922301",
        "STOP_NAME_WITH_PLACE": "Hamza Bin Abdulmuttalib 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hamza Bin Abdulmuttalib 206",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hamza Bin Abdulmuttalib 206",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23922202",
      "isGlobalId": true,
      "name": "Hamza Bin Abdulmuttalib 07",
      "type": "platform",
      "coord": [
        24.59052,
        46.62259
      ],
      "name": "Riyadh, Hamza Bin Abdulmuttalib 107",
      "parent": {
        "id": "239222",
        "isGlobalId": true,
        "disassembledName": "Hamza Bin Abdulmuttalib 107",
        "name": "Riyadh, Hamza Bin Abdulmuttalib 107",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16566,
        "STOP_GLOBAL_ID": "239222",
        "STOPPOINT_GLOBAL_ID": "23922202",
        "STOP_NAME_WITH_PLACE": "Hamza Bin Abdulmuttalib 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hamza Bin Abdulmuttalib 107",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hamza Bin Abdulmuttalib 107",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23922302",
      "isGlobalId": true,
      "name": "Hamza Bin Abdulmuttalib 06",
      "type": "platform",
      "coord": [
        24.59177,
        46.62173
      ],
      "name": "Riyadh, Hamza Bin Abdulmuttalib 106",
      "parent": {
        "id": "239223",
        "isGlobalId": true,
        "disassembledName": "Hamza Bin Abdulmuttalib 106",
        "name": "Riyadh, Hamza Bin Abdulmuttalib 106",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16590,
        "STOP_GLOBAL_ID": "239223",
        "STOPPOINT_GLOBAL_ID": "23922302",
        "STOP_NAME_WITH_PLACE": "Hamza Bin Abdulmuttalib 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hamza Bin Abdulmuttalib 106",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hamza Bin Abdulmuttalib 106",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23922402",
      "isGlobalId": true,
      "name": "Hamza Bin Abdulmuttalib 05",
      "type": "platform",
      "coord": [
        24.59494,
        46.61983
      ],
      "name": "Riyadh, Hamza Bin Abdulmuttalib 205",
      "parent": {
        "id": "239224",
        "isGlobalId": true,
        "disassembledName": "Hamza Bin Abdulmuttalib 205",
        "name": "Riyadh, Hamza Bin Abdulmuttalib 205",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16630,
        "STOP_GLOBAL_ID": "239224",
        "STOPPOINT_GLOBAL_ID": "23922402",
        "STOP_NAME_WITH_PLACE": "Hamza Bin Abdulmuttalib 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hamza Bin Abdulmuttalib 205",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hamza Bin Abdulmuttalib 205",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23922401",
      "isGlobalId": true,
      "name": "Hamza Bin Abdulmuttalib 05",
      "type": "platform",
      "coord": [
        24.59442,
        46.6198
      ],
      "name": "Riyadh, Hamza Bin Abdulmuttalib 105",
      "parent": {
        "id": "239224",
        "isGlobalId": true,
        "disassembledName": "Hamza Bin Abdulmuttalib 105",
        "name": "Riyadh, Hamza Bin Abdulmuttalib 105",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16658,
        "STOP_GLOBAL_ID": "239224",
        "STOPPOINT_GLOBAL_ID": "23922401",
        "STOP_NAME_WITH_PLACE": "Hamza Bin Abdulmuttalib 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Hamza Bin Abdulmuttalib 105",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Hamza Bin Abdulmuttalib 105",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25720102",
      "isGlobalId": true,
      "name": "Al-Khuzama 01",
      "type": "platform",
      "coord": [
        24.69833,
        46.61909
      ],
      "name": "Riyadh, Al-Khuzama 501",
      "parent": {
        "id": "257201",
        "isGlobalId": true,
        "disassembledName": "Al-Khuzama 501",
        "name": "Riyadh, Al-Khuzama 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 16674,
        "STOP_GLOBAL_ID": "257201",
        "STOPPOINT_GLOBAL_ID": "25720102",
        "STOP_NAME_WITH_PLACE": "Al-Khuzama 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al-Khuzama 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al-Khuzama 501",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "16621001",
      "isGlobalId": true,
      "name": "KSU 03",
      "type": "platform",
      "coord": [
        24.70969,
        46.62067
      ],
      "name": "Riyadh, KSU 503",
      "parent": {
        "id": "166210",
        "isGlobalId": true,
        "disassembledName": "KSU 503",
        "name": "Riyadh, KSU 503",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17090,
        "STOP_GLOBAL_ID": "166210",
        "STOPPOINT_GLOBAL_ID": "16621001",
        "STOP_NAME_WITH_PLACE": "KSU 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "KSU 503",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, KSU 503",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23923001",
      "isGlobalId": true,
      "name": "West Al-Uraija 02",
      "type": "platform",
      "coord": [
        24.59396,
        46.61536
      ],
      "name": "Riyadh, West Al-Uraija 602",
      "parent": {
        "id": "239230",
        "isGlobalId": true,
        "disassembledName": "West Al-Uraija 602",
        "name": "Riyadh, West Al-Uraija 602",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17136,
        "STOP_GLOBAL_ID": "239230",
        "STOPPOINT_GLOBAL_ID": "23923001",
        "STOP_NAME_WITH_PLACE": "West Al-Uraija 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "West Al-Uraija 602",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, West Al-Uraija 602",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "16621002",
      "isGlobalId": true,
      "name": "KSU 03",
      "type": "platform",
      "coord": [
        24.71116,
        46.61985
      ],
      "name": "Riyadh, KSU 603",
      "parent": {
        "id": "166210",
        "isGlobalId": true,
        "disassembledName": "KSU 603",
        "name": "Riyadh, KSU 603",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17253,
        "STOP_GLOBAL_ID": "166210",
        "STOPPOINT_GLOBAL_ID": "16621002",
        "STOP_NAME_WITH_PLACE": "KSU 03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "KSU 603",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, KSU 603",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23923002",
      "isGlobalId": true,
      "name": "West Al-Uraija 02",
      "type": "platform",
      "coord": [
        24.59293,
        46.61416
      ],
      "name": "Riyadh, West Al-Uraija 502",
      "parent": {
        "id": "239230",
        "isGlobalId": true,
        "disassembledName": "West Al-Uraija 502",
        "name": "Riyadh, West Al-Uraija 502",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17308,
        "STOP_GLOBAL_ID": "239230",
        "STOPPOINT_GLOBAL_ID": "23923002",
        "STOP_NAME_WITH_PLACE": "West Al-Uraija 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "West Al-Uraija 502",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, West Al-Uraija 502",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "25720201",
      "isGlobalId": true,
      "name": "King Khalid 01",
      "type": "platform",
      "coord": [
        24.71179,
        46.61612
      ],
      "name": "Riyadh, King Khalid 101",
      "parent": {
        "id": "257202",
        "isGlobalId": true,
        "disassembledName": "King Khalid 101",
        "name": "Riyadh, King Khalid 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17657,
        "STOP_GLOBAL_ID": "257202",
        "STOPPOINT_GLOBAL_ID": "25720201",
        "STOP_NAME_WITH_PLACE": "King Khalid 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "King Khalid 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, King Khalid 101",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23821501",
      "isGlobalId": true,
      "name": "Jeddah 02",
      "type": "platform",
      "coord": [
        24.65248,
        46.599
      ],
      "name": "Riyadh, Jeddah 302",
      "parent": {
        "id": "238215",
        "isGlobalId": true,
        "disassembledName": "Jeddah 302",
        "name": "Riyadh, Jeddah 302",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17692,
        "STOP_GLOBAL_ID": "238215",
        "STOPPOINT_GLOBAL_ID": "23821501",
        "STOP_NAME_WITH_PLACE": "Jeddah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Jeddah 302",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Jeddah 302",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23821502",
      "isGlobalId": true,
      "name": "Jeddah 02",
      "type": "platform",
      "coord": [
        24.65292,
        46.59801
      ],
      "name": "Riyadh, Jeddah 402",
      "parent": {
        "id": "238215",
        "isGlobalId": true,
        "disassembledName": "Jeddah 402",
        "name": "Riyadh, Jeddah 402",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17804,
        "STOP_GLOBAL_ID": "238215",
        "STOPPOINT_GLOBAL_ID": "23821502",
        "STOP_NAME_WITH_PLACE": "Jeddah 02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Jeddah 402",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Jeddah 402",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23920001",
      "isGlobalId": true,
      "name": "Ibn Al Muqaffa 01",
      "type": "platform",
      "coord": [
        24.58598,
        46.6122
      ],
      "name": "Riyadh, Ibn Al Muqaffa 201",
      "parent": {
        "id": "239200",
        "isGlobalId": true,
        "disassembledName": "Ibn Al Muqaffa 201",
        "name": "Riyadh, Ibn Al Muqaffa 201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17849,
        "STOP_GLOBAL_ID": "239200",
        "STOPPOINT_GLOBAL_ID": "23920001",
        "STOP_NAME_WITH_PLACE": "Ibn Al Muqaffa 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ibn Al Muqaffa 201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ibn Al Muqaffa 201",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25620001",
      "isGlobalId": true,
      "name": "Irqah 09",
      "type": "platform",
      "coord": [
        24.69285,
        46.60533
      ],
      "name": "Riyadh, Irqah 509",
      "parent": {
        "id": "256200",
        "isGlobalId": true,
        "disassembledName": "Irqah 509",
        "name": "Riyadh, Irqah 509",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17879,
        "STOP_GLOBAL_ID": "256200",
        "STOPPOINT_GLOBAL_ID": "25620001",
        "STOP_NAME_WITH_PLACE": "Irqah 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 509",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 509",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23920002",
      "isGlobalId": true,
      "name": "Ibn Al Muqaffa 01",
      "type": "platform",
      "coord": [
        24.58631,
        46.61168
      ],
      "name": "Riyadh, Ibn Al Muqaffa 101",
      "parent": {
        "id": "239200",
        "isGlobalId": true,
        "disassembledName": "Ibn Al Muqaffa 101",
        "name": "Riyadh, Ibn Al Muqaffa 101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17884,
        "STOP_GLOBAL_ID": "239200",
        "STOPPOINT_GLOBAL_ID": "23920002",
        "STOP_NAME_WITH_PLACE": "Ibn Al Muqaffa 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Ibn Al Muqaffa 101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Ibn Al Muqaffa 101",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "25620002",
      "isGlobalId": true,
      "name": "Irqah 09",
      "type": "platform",
      "coord": [
        24.69305,
        46.6051
      ],
      "name": "Riyadh, Irqah 609",
      "parent": {
        "id": "256200",
        "isGlobalId": true,
        "disassembledName": "Irqah 609",
        "name": "Riyadh, Irqah 609",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 17912,
        "STOP_GLOBAL_ID": "256200",
        "STOPPOINT_GLOBAL_ID": "25620002",
        "STOP_NAME_WITH_PLACE": "Irqah 09",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 609",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 609",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "25620102",
      "isGlobalId": true,
      "name": "Irqah 08",
      "type": "platform",
      "coord": [
        24.69198,
        46.60205
      ],
      "name": "Riyadh, Irqah 508",
      "parent": {
        "id": "256201",
        "isGlobalId": true,
        "disassembledName": "Irqah 508",
        "name": "Riyadh, Irqah 508",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18194,
        "STOP_GLOBAL_ID": "256201",
        "STOPPOINT_GLOBAL_ID": "25620102",
        "STOP_NAME_WITH_PLACE": "Irqah 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 508",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 508",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23920201",
      "isGlobalId": true,
      "name": "West Al-Uraija 01",
      "type": "platform",
      "coord": [
        24.5887,
        46.60716
      ],
      "name": "Riyadh, West Al-Uraija 501",
      "parent": {
        "id": "239202",
        "isGlobalId": true,
        "disassembledName": "West Al-Uraija 501",
        "name": "Riyadh, West Al-Uraija 501",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18227,
        "STOP_GLOBAL_ID": "239202",
        "STOPPOINT_GLOBAL_ID": "23920201",
        "STOP_NAME_WITH_PLACE": "West Al-Uraija 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "West Al-Uraija 501",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, West Al-Uraija 501",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25620101",
      "isGlobalId": true,
      "name": "Irqah 08",
      "type": "platform",
      "coord": [
        24.69212,
        46.60131
      ],
      "name": "Riyadh, Irqah 608",
      "parent": {
        "id": "256201",
        "isGlobalId": true,
        "disassembledName": "Irqah 608",
        "name": "Riyadh, Irqah 608",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18278,
        "STOP_GLOBAL_ID": "256201",
        "STOPPOINT_GLOBAL_ID": "25620101",
        "STOP_NAME_WITH_PLACE": "Irqah 08",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 608",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 608",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25620302",
      "isGlobalId": true,
      "name": "Irqah 07",
      "type": "platform",
      "coord": [
        24.69099,
        46.59812
      ],
      "name": "Riyadh, Irqah 507",
      "parent": {
        "id": "256203",
        "isGlobalId": true,
        "disassembledName": "Irqah 507",
        "name": "Riyadh, Irqah 507",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18576,
        "STOP_GLOBAL_ID": "256203",
        "STOPPOINT_GLOBAL_ID": "25620302",
        "STOP_NAME_WITH_PLACE": "Irqah 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 507",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 507",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "25620301",
      "isGlobalId": true,
      "name": "Irqah 07",
      "type": "platform",
      "coord": [
        24.69105,
        46.59709
      ],
      "name": "Riyadh, Irqah 607",
      "parent": {
        "id": "256203",
        "isGlobalId": true,
        "disassembledName": "Irqah 607",
        "name": "Riyadh, Irqah 607",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18688,
        "STOP_GLOBAL_ID": "256203",
        "STOPPOINT_GLOBAL_ID": "25620301",
        "STOP_NAME_WITH_PLACE": "Irqah 07",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 607",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 607",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23920102",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 18",
      "type": "platform",
      "coord": [
        24.58784,
        46.60223
      ],
      "name": "Riyadh, Bilal Bin Rabah 318",
      "parent": {
        "id": "239201",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 318",
        "name": "Riyadh, Bilal Bin Rabah 318",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18773,
        "STOP_GLOBAL_ID": "239201",
        "STOPPOINT_GLOBAL_ID": "23920102",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 18",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 318",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 318",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23820102",
      "isGlobalId": true,
      "name": "Al Rabeya 01",
      "type": "platform",
      "coord": [
        24.63891,
        46.58915
      ],
      "name": "Riyadh, Al Rabeya 401V",
      "parent": {
        "id": "238201",
        "isGlobalId": true,
        "disassembledName": "Al Rabeya 401V",
        "name": "Riyadh, Al Rabeya 401V",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18801,
        "STOP_GLOBAL_ID": "238201",
        "STOPPOINT_GLOBAL_ID": "23820102",
        "STOP_NAME_WITH_PLACE": "Al Rabeya 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Rabeya 401V",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Rabeya 401V",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23820101",
      "isGlobalId": true,
      "name": "Al Rabeya 01",
      "type": "platform",
      "coord": [
        24.63891,
        46.58915
      ],
      "name": "Riyadh, Al Rabeya 401",
      "parent": {
        "id": "238201",
        "isGlobalId": true,
        "disassembledName": "Al Rabeya 401",
        "name": "Riyadh, Al Rabeya 401",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18801,
        "STOP_GLOBAL_ID": "238201",
        "STOPPOINT_GLOBAL_ID": "23820101",
        "STOP_NAME_WITH_PLACE": "Al Rabeya 01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Al Rabeya 401",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Al Rabeya 401",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23920101",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 18",
      "type": "platform",
      "coord": [
        24.58785,
        46.60187
      ],
      "name": "Riyadh, Bilal Bin Rabah 418",
      "parent": {
        "id": "239201",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 418",
        "name": "Riyadh, Bilal Bin Rabah 418",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 18810,
        "STOP_GLOBAL_ID": "239201",
        "STOPPOINT_GLOBAL_ID": "23920101",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 18",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 418",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 418",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23922901",
      "isGlobalId": true,
      "name": "Western Ring  03",
      "type": "platform",
      "coord": [
        24.58673,
        46.5984
      ],
      "name": "Riyadh, Western Ring  203",
      "parent": {
        "id": "239229",
        "isGlobalId": true,
        "disassembledName": "Western Ring  203",
        "name": "Riyadh, Western Ring  203",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19219,
        "STOP_GLOBAL_ID": "239229",
        "STOPPOINT_GLOBAL_ID": "23922901",
        "STOP_NAME_WITH_PLACE": "Western Ring  03",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Western Ring  203",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Western Ring  203",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23920401",
      "isGlobalId": true,
      "name": "Western Ring  02",
      "type": "platform",
      "coord": [
        24.59056,
        46.59602
      ],
      "name": "Riyadh, Western Ring  202",
      "parent": {
        "id": "239204",
        "isGlobalId": true,
        "disassembledName": "Western Ring  202",
        "name": "Riyadh, Western Ring  202",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19291,
        "STOP_GLOBAL_ID": "239204",
        "STOPPOINT_GLOBAL_ID": "23920401",
        "STOP_NAME_WITH_PLACE": "Western Ring  02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Western Ring  202",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Western Ring  202",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25620401",
      "isGlobalId": true,
      "name": "Irqah 06",
      "type": "platform",
      "coord": [
        24.68945,
        46.59074
      ],
      "name": "Riyadh, Irqah 606",
      "parent": {
        "id": "256204",
        "isGlobalId": true,
        "disassembledName": "Irqah 606",
        "name": "Riyadh, Irqah 606",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19312,
        "STOP_GLOBAL_ID": "256204",
        "STOPPOINT_GLOBAL_ID": "25620401",
        "STOP_NAME_WITH_PLACE": "Irqah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 606",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 606",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25620402",
      "isGlobalId": true,
      "name": "Irqah 06",
      "type": "platform",
      "coord": [
        24.68901,
        46.59033
      ],
      "name": "Riyadh, Irqah 506",
      "parent": {
        "id": "256204",
        "isGlobalId": true,
        "disassembledName": "Irqah 506",
        "name": "Riyadh, Irqah 506",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19341,
        "STOP_GLOBAL_ID": "256204",
        "STOPPOINT_GLOBAL_ID": "25620402",
        "STOP_NAME_WITH_PLACE": "Irqah 06",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 506",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 506",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23920501",
      "isGlobalId": true,
      "name": "Western Ring  01",
      "type": "platform",
      "coord": [
        24.59856,
        46.59194
      ],
      "name": "Riyadh, Western Ring  201",
      "parent": {
        "id": "239205",
        "isGlobalId": true,
        "disassembledName": "Western Ring  201",
        "name": "Riyadh, Western Ring  201",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19394,
        "STOP_GLOBAL_ID": "239205",
        "STOPPOINT_GLOBAL_ID": "23920501",
        "STOP_NAME_WITH_PLACE": "Western Ring  01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Western Ring  201",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Western Ring  201",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "23920402",
      "isGlobalId": true,
      "name": "Western Ring  02",
      "type": "platform",
      "coord": [
        24.5897,
        46.59534
      ],
      "name": "Riyadh, Western Ring  102",
      "parent": {
        "id": "239204",
        "isGlobalId": true,
        "disassembledName": "Western Ring  102",
        "name": "Riyadh, Western Ring  102",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19399,
        "STOP_GLOBAL_ID": "239204",
        "STOPPOINT_GLOBAL_ID": "23920402",
        "STOP_NAME_WITH_PLACE": "Western Ring  02",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Western Ring  102",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Western Ring  102",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "25021101",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 17",
      "type": "platform",
      "coord": [
        24.58513,
        46.59733
      ],
      "name": "Riyadh, Bilal Bin Rabah 417",
      "parent": {
        "id": "250211",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 417",
        "name": "Riyadh, Bilal Bin Rabah 417",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19405,
        "STOP_GLOBAL_ID": "250211",
        "STOPPOINT_GLOBAL_ID": "25021101",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 17",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 417",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 417",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25021102",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 17",
      "type": "platform",
      "coord": [
        24.58447,
        46.59676
      ],
      "name": "Riyadh, Bilal Bin Rabah 317",
      "parent": {
        "id": "250211",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 317",
        "name": "Riyadh, Bilal Bin Rabah 317",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19494,
        "STOP_GLOBAL_ID": "250211",
        "STOPPOINT_GLOBAL_ID": "25021102",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 17",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 317",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 317",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "23920502",
      "isGlobalId": true,
      "name": "Western Ring  01",
      "type": "platform",
      "coord": [
        24.59771,
        46.59118
      ],
      "name": "Riyadh, Western Ring  101",
      "parent": {
        "id": "239205",
        "isGlobalId": true,
        "disassembledName": "Western Ring  101",
        "name": "Riyadh, Western Ring  101",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19507,
        "STOP_GLOBAL_ID": "239205",
        "STOPPOINT_GLOBAL_ID": "23920502",
        "STOP_NAME_WITH_PLACE": "Western Ring  01",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Western Ring  101",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Western Ring  101",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "25021001",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 16",
      "type": "platform",
      "coord": [
        24.58308,
        46.59391
      ],
      "name": "Riyadh, Bilal Bin Rabah 416",
      "parent": {
        "id": "250210",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 416",
        "name": "Riyadh, Bilal Bin Rabah 416",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19854,
        "STOP_GLOBAL_ID": "250210",
        "STOPPOINT_GLOBAL_ID": "25021001",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 416",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 416",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25021002",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 16",
      "type": "platform",
      "coord": [
        24.58258,
        46.59368
      ],
      "name": "Riyadh, Bilal Bin Rabah 316",
      "parent": {
        "id": "250210",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 316",
        "name": "Riyadh, Bilal Bin Rabah 316",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19901,
        "STOP_GLOBAL_ID": "250210",
        "STOPPOINT_GLOBAL_ID": "25021002",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 16",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 316",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 316",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "25620601",
      "isGlobalId": true,
      "name": "Irqah 05",
      "type": "platform",
      "coord": [
        24.68789,
        46.58459
      ],
      "name": "Riyadh, Irqah 605",
      "parent": {
        "id": "256206",
        "isGlobalId": true,
        "disassembledName": "Irqah 605",
        "name": "Riyadh, Irqah 605",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19923,
        "STOP_GLOBAL_ID": "256206",
        "STOPPOINT_GLOBAL_ID": "25620601",
        "STOP_NAME_WITH_PLACE": "Irqah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 605",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 605",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "25620602",
      "isGlobalId": true,
      "name": "Irqah 05",
      "type": "platform",
      "coord": [
        24.68736,
        46.58379
      ],
      "name": "Riyadh, Irqah 505",
      "parent": {
        "id": "256206",
        "isGlobalId": true,
        "disassembledName": "Irqah 505",
        "name": "Riyadh, Irqah 505",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 19993,
        "STOP_GLOBAL_ID": "256206",
        "STOPPOINT_GLOBAL_ID": "25620602",
        "STOP_NAME_WITH_PLACE": "Irqah 05",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Irqah 505",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Irqah 505",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "26022302",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 15",
      "type": "platform",
      "coord": [
        24.57924,
        46.58827
      ],
      "name": "Riyadh, Bilal Bin Rabah 315",
      "parent": {
        "id": "260223",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 315",
        "name": "Riyadh, Bilal Bin Rabah 315",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 20616,
        "STOP_GLOBAL_ID": "260223",
        "STOPPOINT_GLOBAL_ID": "26022302",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 15",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 315",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 315",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "26022301",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 15",
      "type": "platform",
      "coord": [
        24.57901,
        46.58728
      ],
      "name": "Riyadh, Bilal Bin Rabah 415",
      "parent": {
        "id": "260223",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 415",
        "name": "Riyadh, Bilal Bin Rabah 415",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 20729,
        "STOP_GLOBAL_ID": "260223",
        "STOPPOINT_GLOBAL_ID": "26022301",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 15",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 415",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 415",
        "IDENTIFIER": "1"
      }
    },
    {
      "id": "26022402",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 14",
      "type": "platform",
      "coord": [
        24.5781,
        46.58513
      ],
      "name": "Riyadh, Bilal Bin Rabah 314",
      "parent": {
        "id": "260224",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 314",
        "name": "Riyadh, Bilal Bin Rabah 314",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 20993,
        "STOP_GLOBAL_ID": "260224",
        "STOPPOINT_GLOBAL_ID": "26022402",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 314",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 314",
        "IDENTIFIER": "2"
      }
    },
    {
      "id": "26022401",
      "isGlobalId": true,
      "name": "Bilal Bin Rabah 14",
      "type": "platform",
      "coord": [
        24.57797,
        46.58414
      ],
      "name": "Riyadh, Bilal Bin Rabah 414",
      "parent": {
        "id": "260224",
        "isGlobalId": true,
        "disassembledName": "Bilal Bin Rabah 414",
        "name": "Riyadh, Bilal Bin Rabah 414",
        "type": "stop",
        "parent": {
          "id": "placeID:97001001:999",
          "name": "Riyadh",
          "type": "locality"
        }
      },
      "properties": {
        "distance": 21100,
        "STOP_GLOBAL_ID": "260224",
        "STOPPOINT_GLOBAL_ID": "26022401",
        "STOP_NAME_WITH_PLACE": "Bilal Bin Rabah 14",
        "STOP_AREA_NAME": "HoB",
        "STOP_POINT_REFERED_NAME": "Bilal Bin Rabah 414",
        "STOP_POINT_REFERED_NAMEWITHPLACE": "Riyadh, Bilal Bin Rabah 414",
        "IDENTIFIER": "1"
      }
    }
  ]
}
"""

