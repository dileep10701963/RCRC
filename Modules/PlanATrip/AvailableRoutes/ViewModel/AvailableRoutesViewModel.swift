//
//  AvailableRoutesViewModel.swift
//  RCRC
//
//  Created by Errol on 21/07/20.
//

import Foundation
import Alamofire
import GoogleMaps

/// Return 1 -> True,  0 -> False
extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}

final class AvailableRoutesViewModel: NSObject {

    func fetchTrips(origin: LocationData, destination: LocationData, searchPreferences: SelectedSearchPreferences?, travelPreference: TravelPreferenceModel?, completion: @escaping ([TripCellViewModel]) -> Void) {
        let searchPreferenceParameters = makeTripPreferenceRequestParameters(searchPreferences)
        let originRequestParameters = makeLocationRequestParameters(origin)
        let destinationRequestParameters = makeLocationRequestParameters(destination)
        let travelPreferenceRequestParameters = makeTravelPreferenceRequestParameters(travelPreference)

        let endPoint = EndPoint(baseUrl: .journeyPlanner, methodName: URLs.routeEndPoints, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        
        let issearchPreferenceNow = searchPreferences?.availability.localized == Constants.now.localized
        
        let parameters = AvailableRouteRequest(
            typeOrigin: originRequestParameters.type,
            nameOrigin: originRequestParameters.name,
            typeDestination: destinationRequestParameters.type,
            nameDestination: destinationRequestParameters.name,
            itdTripDateTimeDepArr: searchPreferenceParameters.option,
            itdDate: issearchPreferenceNow ? nil: searchPreferenceParameters.date,
            itdTime: issearchPreferenceNow ? nil: searchPreferenceParameters.time,
            alterNativeStops: travelPreferenceRequestParameters?.alterNativeStop,
            routePreferences: travelPreferenceRequestParameters?.routeType,
            maxWalkTime: travelPreferenceRequestParameters?.maxWalkTime,
            walkingSpeed: travelPreferenceRequestParameters?.walkSpeed,
            excludedMeans: travelPreferenceRequestParameters?.transportMethodCode
            
        )

        performRequest(service: ServiceManager.sharedInstance,
                       endPoint: endPoint,
                       parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            let cellViewModels = self.handleResult(result)
            completion(cellViewModels)
        }
    }

    func handleResult(_ result: Result<Trip, Error>) -> [TripCellViewModel] {
        switch result {
        case .success(let trip):
            if let journeys = trip.journeys, journeys.isNotEmpty {
                let cellViewModels = journeys.map { journey -> TripCellViewModel in
                    TripCellViewModel(journey: journey)
                }
                return cellViewModels
            } else {
                return []
            }
        case .failure:
            return []
        }
    }

    func performRequest(service: ServiceManager, endPoint: EndPoint, parameters: AvailableRouteRequest, completion: @escaping (Result<Trip, Error>) -> Void) {

        service.withRequest(endPoint: endPoint,
                            params: parameters,
                            res: Trip.self) { result in
            completion(result)
        }
    }
    
    /// Make Request Parameters based on selected travel preference
    ///  Default:-  routeType: LEASTTIME, maxWalkTime: 15, walkSpeed: normal, alterNativeStop: 1
    func makeTravelPreferenceRequestParameters(_ travelPreferences: TravelPreferenceModel?) -> (alterNativeStop: Int, routeType: String, maxWalkTime: String, walkSpeed: String, transportMethodCode: Int?)? {
        if let travelPreferences = travelPreferences {
            let routePreference = travelPreferences.routePreference?.apiValue ?? "LEASTTIME"
            let maxWalkTime = "15"
            let walkSpeed = travelPreferences.walkSpeed?.rawValue.lowercased() ?? "normal"
            let transportCode: Int? = travelPreferences.busTransport == false ? 5: nil
            let alternativeStopBoolValue: Bool = travelPreferences.alternativeStopsPreference ?? true
            let alternativeStop = alternativeStopBoolValue.intValue
            return(alternativeStop, routePreference, maxWalkTime, walkSpeed, transportCode)
        } else {
            return nil
        }
    }

    /// Make Request Parameters based on selected trip preference
    /// Options: Now/ Leave/ Arrive
    /// Default is Now
    /// - Returns: arr / dep  |  yyyyMMdd (99991231) | hhmm (22:22)
    func makeTripPreferenceRequestParameters(_ searchPreferences: SelectedSearchPreferences?) -> (option: String, date: String, time: String) {
        let isArriveSelected = searchPreferences?.availability == Constants.arrive
        let mainOption = isArriveSelected ? Constants.arrival : Constants.departure
        let date = searchPreferences?.date.dateString ?? Date().dateString
        let time = String(format: Constants.timeDoubleDigitFormat,
                          arguments: [searchPreferences?.hour.toInt() ?? Date().hour, searchPreferences?.minute.toInt() ?? Date().minute])
        return (mainOption, date, time)
    }

    func makeLocationRequestParameters(_ location: LocationData) -> (name: String, type: String) {
        guard let type = location.type else { return ("", "") }
        switch type {
        case .stop:
            guard let name = location.id else { return ("", "") }
            return (name, Constants.stopParameter)

        case .coordinate:
            guard let latitude = location.coordinate?.latitude,
                  let longitude = location.coordinate?.longitude else { return ("", "") }
            return ("\(longitude):\(latitude):\(Constants.coordinateFormat)", Constants.coordinateParameter)
        }
    }
}

// MARK: - Favorite Route Implementation
extension AvailableRoutesViewModel {

    func saveRoute(source: LocationData, destination: LocationData) {
        let routeToSave = FavoriteRoute(sourceType: source.type?.rawValue,
                                        destinationType: destination.type?.rawValue,
                                        sourceId: source.id,
                                        destinationId: destination.id,
                                        sourceAddress: source.subAddress,
                                        destinationAddress: destination.subAddress,
                                        sourceLatitude: source.coordinate?.latitude.string,
                                        destinationLatitude: destination.coordinate?.latitude.string,
                                        sourceLongitude: source.coordinate?.longitude.string,
                                        destinationLongitude: destination.coordinate?.longitude.string)
        
        if let availableFavRoute = FavoriteRouteDataRepository.shared.fetchAll(), availableFavRoute.filter({$0 == routeToSave}).isNotEmpty {
            return
        }
        
        FavoriteRouteDataRepository.shared.create(record: routeToSave)
    }
    
    func isSourceAndDestinationSame(source: LocationData, destination: LocationData) -> Bool {
        return source == destination
    }

    func isRouteFavorite(source: LocationData, destination: LocationData) -> Bool {
        let routeToCheck = FavoriteRoute(sourceType: source.type?.rawValue,
                                         destinationType: destination.type?.rawValue,
                                         sourceId: source.id,
                                         destinationId: destination.id,
                                         sourceAddress: source.subAddress,
                                         destinationAddress: destination.subAddress,
                                         sourceLatitude: source.coordinate?.latitude.string,
                                         destinationLatitude: destination.coordinate?.latitude.string,
                                         sourceLongitude: source.coordinate?.longitude.string,
                                         destinationLongitude: destination.coordinate?.longitude.string)
        if let savedData = FavoriteRouteDataRepository.shared.fetchAll(), savedData.filter({
            return $0 == routeToCheck
        }).isNotEmpty {
            return true
        }
        return false
    }

    func removeRoute(source: LocationData, destination: LocationData) {
        let routeToRemove = FavoriteRoute(sourceType: source.type?.rawValue,
                                        destinationType: destination.type?.rawValue,
                                        sourceId: source.id,
                                        destinationId: destination.id,
                                        sourceAddress: source.subAddress,
                                        destinationAddress: destination.subAddress,
                                        sourceLatitude: source.coordinate?.latitude.string,
                                        destinationLatitude: destination.coordinate?.latitude.string,
                                        sourceLongitude: source.coordinate?.longitude.string,
                                        destinationLongitude: destination.coordinate?.longitude.string)
        if isRouteFavorite(source: source, destination: destination) {
            FavoriteRouteDataRepository.shared.delete(record: routeToRemove)
        }
    }
}
