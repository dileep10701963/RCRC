//
//  PlacesOfInterestViewModel.swift
//  RCRC
//
//  Created by Errol on 25/06/21.
//

import Foundation
import GoogleMaps
import Alamofire

struct PlacesOfInterestViewModel {
    private let service: ServiceManager

    private var riyadhCenterCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
    }

    init(service: ServiceManager = ServiceManager.sharedInstance) {
        self.service = service
    }

    func fetchPlaces(location: CLLocationCoordinate2D?, pageToken: String?, text: String?, category: PlacesOfInterestCategory?, completion: @escaping (Result<PlacesOfInterestModel, Error>) -> Void) {
        let currentLocation = updateLocation(location)
        let endPoint = EndPoint(baseUrl: .googleMap, methodName: URLs.nearbyPlacesOfInterest, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = PlacesOfInterestRequest(key: Keys.googleApiKey, location: currentLocation.latitude.string + "," + currentLocation.longitude.string, type: category, pagetoken: pageToken, keyword: text)
        service.withRequest(endPoint: endPoint, params: parameters, res: PlacesOfInterestModel.self, completion: completion)
    }

    /// Checks if `Location is in Riyadh`.
    /// If yes, returns the location, else returns `Riyadh Center Coordinate`
    private func updateLocation(_ location: CLLocationCoordinate2D?) -> CLLocationCoordinate2D {
        if let location = location, isLocationInRiyadh(location) {
            return location
        }
        return riyadhCenterCoordinate
    }

    private func isLocationInRiyadh(_ location: CLLocationCoordinate2D) -> Bool {
        let path = GMSMutablePath()
        RiyadhPolygon.bound.forEach { path.add($0) }
        if GMSGeometryContainsLocation(location, path, true) {
            return true
        }
        return false
    }
}
