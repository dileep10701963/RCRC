//
//  SearchResultsViewModel.swift
//  RCRC
//
//  Created by Errol on 16/07/20.
//

import Foundation
import UIKit
import Alamofire
import GoogleMaps
import GooglePlaces

class SearchResultsViewModel: NSObject {

    static let shared = SearchResultsViewModel()
    var stopsItemData: [StopsItem]?
    var stopFinderResults: Observable<SearchResults?, Error?> = Observable(nil, nil)
    var searchText: String? {
        didSet {
            if let searchText = searchText {
                self.getStopList(input: searchText)
            }
        }
    }
    
    func getDoubleValue (stopItem: StopsItem) -> [Double] {
        if let lat = stopItem.stop_lat, let long = stopItem.stop_lon, let latitude = Double(lat), let longitude = Double(long) {
            return [latitude, longitude]
        } else {
            return [0.0, 0.0]
        }
    }
    
    func getStopList(endpoint: String = URLs.travelHistory, input: String, completionHandler : (() -> Void)? = nil) {
        
        if let stopArrayData = self.getStopsItem(), stopArrayData.count > 0 {
            self.stopFinderResults.error = nil
            let language = currentLanguage == .arabic ? "ar": "en"
            let stopItems = stopArrayData.filter({$0.language ?? "" == language}).sorted { $0.translation ?? "" < $1.translation ?? "" }
            
            if input == emptyString {
                let locationObjects = stopItems.compactMap { item in
                    Location(productClasses: nil, disassembledName: item.translation, id: self.getRecordID(recordID: item.record_id), coord: getDoubleValue(stopItem: item), parent: nil, properties: nil, isGlobalID: nil, type: Constants.stop, name: nil, matchQuality: nil)
                }
                
                if locationObjects.count > 0 {
                    
                    self.stopFinderResults.value = SearchResults(locations: locationObjects, systemMessages: [])
                }
                
            } else {
                let locationObjects = stopItems.filter({ item in
                    if let fieldName = item.translation, fieldName.lowercased().contains(input.lowercased()) {
                        return true
                    } else {
                        return false
                    }
                }).compactMap { item in
                    Location(productClasses: nil, disassembledName: item.translation, id: self.getRecordID(recordID: item.record_id), coord: getDoubleValue(stopItem: item), parent: nil, properties: nil, isGlobalID: nil, type: Constants.stop, name: nil, matchQuality: nil)
                }
                
                if locationObjects.count > 0 {
                    self.stopFinderResults.value = SearchResults(locations: locationObjects, systemMessages: [])
                } else {
                    self.stopFinderResults.value = SearchResults(locations: [], systemMessages: [])
                }
            }
            if let completionHandler = completionHandler {
                completionHandler()
            }
        } else {
            let langaugeCode = currentLanguage == .english ? Languages.english.rawValue : Languages.arabic.rawValue
            let endPoint = EndPoint(baseUrl: .busStopOnMap, methodName:URLs.listCord + "?language=\(langaugeCode)", method: .get, encoder: URLEncodedFormParameterEncoder.default)
            let parameters = DefaultParameters()
            
            ServiceManager.sharedInstance.withRequestDecodedResult(endPoint: endPoint, parameters: parameters, resultData: [StopsItem].self) { result in
                
                switch result {
                case .success(let modelData):
                    self.stopFinderResults.error = nil
                    self.stopsItemData = modelData
                    ServiceManager.sharedInstance.stopsItemData = modelData
                    
                    if let stopModelItems = modelData, stopModelItems.count > 0 {
                        
                        let language = currentLanguage == .arabic ? "ar": "en"
                        let stopItems = stopModelItems.filter({$0.language ?? "" == language}).sorted { $0.translation ?? "" < $1.translation ?? "" }
                        
                        if input == emptyString {
                            let locationObjects = stopItems.compactMap { item in
                                Location(productClasses: nil, disassembledName: item.translation, id: self.getRecordID(recordID: item.record_id), coord: self.getDoubleValue(stopItem: item), parent: nil, properties: nil, isGlobalID: nil, type: Constants.stop, name: nil, matchQuality: nil)
                            }
                            
                            if locationObjects.count > 0 {
                                self.stopFinderResults.value = SearchResults(locations: locationObjects, systemMessages: [])
                            }
                            
                        } else {
                            let locationObjects = stopItems.filter({ item in
                                if let fieldName = item.translation, fieldName.lowercased().contains(input.lowercased()) {
                                    return true
                                } else {
                                    return false
                                }
                            }).compactMap { item in
                                Location(productClasses: nil, disassembledName: item.translation, id: self.getRecordID(recordID: item.record_id), coord: self.getDoubleValue(stopItem: item), parent: nil, properties: nil, isGlobalID: nil, type: Constants.stop, name: nil, matchQuality: nil)
                            }
                            
                            if locationObjects.count > 0 {
                                self.stopFinderResults.value = SearchResults(locations: locationObjects, systemMessages: [])
                            } else {
                                self.stopFinderResults.value = SearchResults(locations: [], systemMessages: [])
                            }
                        }
                    } else {
                        self.stopFinderResults.error = NetworkError.invalidData
                    }
                    
                    if let completionHandler = completionHandler {
                        completionHandler()
                    }
                case .failure(let errr):
                    self.stopFinderResults.error = errr
                    print("Error-->", errr)
                    if let completionHandler = completionHandler {
                        completionHandler()
                    }
                }
            }
        }
        
    }
    
    private func getStopsItem() -> [StopsItem]? {
        if ServiceManager.sharedInstance.stopsItemData != nil {
            return ServiceManager.sharedInstance.stopsItemData
        } else {
            return self.stopsItemData
        }
    }
        
    func getRecordID(recordID: Int?) -> String {
        var recordID = "\(recordID ?? 0)"
        if recordID.count > 5 {
            recordID = String(recordID.prefix(6))
        }
        return recordID
    }
    
    
    /*
    func fetchResultWithGoogleAutoComplete(text: String, completionHandler : (() -> Void)? = nil) {
        let filter = GMSAutocompleteFilter()
        filter.countries = ["sa"]
        
        let northEastBound = CLLocationCoordinate2D(latitude: 25.1564724, longitude: 47.34695430000001)
        let southWestBound = CLLocationCoordinate2D(latitude: 24.2939113, longitude: 46.2981033)
        
        filter.locationRestriction = GMSPlaceRectangularLocationOption(CLLocationCoordinate2D(latitude: northEastBound.latitude, longitude: northEastBound.longitude), CLLocationCoordinate2D(latitude: southWestBound.latitude, longitude: southWestBound.longitude))
        
        filter.locationBias = GMSPlaceRectangularLocationOption(CLLocationCoordinate2D(latitude: northEastBound.latitude, longitude: northEastBound.longitude), CLLocationCoordinate2D(latitude: southWestBound.latitude, longitude: southWestBound.longitude))
        
        let placesClient: GMSPlacesClient = GMSPlacesClient.shared()
        placesClient.findAutocompletePredictions(fromQuery: text, filter: filter, sessionToken: nil) {[weak self] results, error in
            
            let locationValue = self?.stopFinderResults.value?.locations ?? []
            if let results = results, results.count > 0 {
                var placesOfInterestResults: [PlacesOfInterestResult] = []
                for result in results {
                    let name = result.attributedPrimaryText.string
                    let address = result.attributedFullText.string.replacingOccurrences(of: "\(name), ", with: "")
                    let placeResultModel = PlacesOfInterestResult(businessStatus: nil, icon: nil, geometry: nil, name: name, vicinity: address, placeID: result.placeID)
                    placesOfInterestResults.append(placeResultModel)
                }
                self?.stopFinderResults.value = SearchResults(locations: locationValue, systemMessages: [], googleLocations: placesOfInterestResults)
                if let completionHandler = completionHandler {
                    completionHandler()
                }
            }
            
            if let completionHandler = completionHandler {
                completionHandler()
            }
            
        }
    }
     */
    
    func fetchCoordinateForAutoCompleteResponse(placeID: String, completionHandler : @escaping (GMSPlace?) -> Void) {
        let placesClient: GMSPlacesClient = GMSPlacesClient.shared()
        placesClient.lookUpPlaceID(placeID) { response, error in
            if let response = response {
                completionHandler(response)
            } else {
                completionHandler(nil)
            }
        }
    }
    

    // StopFinder request with coordinates as input
    func reverseGeocode(endpoint: String = URLs.stopFinderUrl, input: CLLocationCoordinate2D, completion: @escaping((_ location: SearchResults?) -> Void)) {

        let request = SearchRequest(nameSf: "\(input.longitude):\(input.latitude):WGS84[DD.DDDDD]")
        let endPoint = EndPoint(baseUrl: .journeyPlanner, methodName: endpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: SearchResults.self) { result in
            if case let .success(result) = result {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    func setupRouteSelectionViewButtonText(leaveArrivePreferences: MPDateTimePickerSelection) -> (labelText: NSMutableAttributedString, buttonText: NSMutableAttributedString) {
        
        var valueText: String = Constants.now.localized
        if leaveArrivePreferences.availability == Constants.now.localized {
            valueText = Constants.now.localized
        } else if leaveArrivePreferences.availability == Constants.leave {
            valueText = self.getDateAndTime(preferences: leaveArrivePreferences)
        } else if leaveArrivePreferences.availability == Constants.arrive {
            valueText = self.getDateAndTime(preferences: leaveArrivePreferences)
        }
        
        let attachment = NSTextAttachment()
        attachment.image = Images.downArrowGreen
        let attachmentString = NSAttributedString(attachment: attachment)
        let valueAttrText = NSMutableAttributedString(string: "\(valueText) ", attributes: [NSAttributedString.Key.foregroundColor:Colors.newGreen, NSAttributedString.Key.font: Fonts.CodecRegular.sixteen])
        valueAttrText.append(attachmentString)
        
        var labelValue: String = Constants.leaveBy.localized
        if valueText == Constants.now.localized {
            labelValue = currentLanguage == .arabic ? "المغادرة": Constants.leaveBy.localized
        }
        
        if leaveArrivePreferences.availability == Constants.arrive {
            labelValue = Constants.arriveBy.localized
        }
        
        let labelAttrText = NSMutableAttributedString(string: "\(labelValue)", attributes: [NSAttributedString.Key.foregroundColor:Colors.black, NSAttributedString.Key.font: Fonts.CodecRegular.sixteen])
        return (labelAttrText, valueAttrText)
        
    }
    
    private func getDateAndTime(preferences: MPDateTimePickerSelection) -> String {
        let date = preferences.date
        let strDate = date.toString(withFormat: "dd-MM", timeZone: .AST)
        let preferenceTime = "\(preferences.hour):\(preferences.minute)"
        let timeIs = preferenceTime.toDate(withFormat: "H:mm",timeZone: .AST)
        var preferenceConverTime: String = ""
        if let time = timeIs {
            preferenceConverTime = time.toString(withFormat: "h:mm a", timeZone: .AST)
        }
        return "\(strDate) \(preferenceConverTime)"
    }
    
    func loadJson(filename fileName: String) -> StopsModel? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(StopsModel.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
        
    }
    
}

extension SearchResultsViewModel: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let count = stopFinderResults.value?.locations.count else {
            return 0
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: SearchResultsTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
        cell.stopResult = stopFinderResults.value?.locations[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        " "
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.searchResultsTableHeaderHeight
    }
}
