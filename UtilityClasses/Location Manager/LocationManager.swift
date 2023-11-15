//
//  LocationManager.swift
//  RCRC
//
//  Created by Ganesh Shinde on 05/08/20.
//

import UIKit
import CoreLocation
import GoogleMaps

struct CurrentLocation {
    var id: String?
    var address: String?
    var subAddress: String?
    var coordinate: CLLocationCoordinate2D?
}

class LocationManager: NSObject {

    static let SharedInstance = LocationManager()
    private var locationManager: CLLocationManager?
    var updateCurrentLocation: ((_ location: CLLocation?) -> Void)?
    var path: GMSPath!
    
    var riyadhCenterCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
    }
    
    var locationStatus: CLAuthorizationStatus {
        if let locationManager = locationManager {
            if #available(iOS 14.0, *) {
                return locationManager.authorizationStatus
            } else {
                return CLLocationManager.authorizationStatus()
            }
        } else {
            return .notDetermined
        }
    }
    
    private override init () {
        super.init()
        let gmspath = GMSMutablePath()
        for location in RiyadhPolygon.bound {
            gmspath.add(location)
        }
        path = GMSPath(path: gmspath)
    }

    func startUpdatingLocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
//            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
        locationManager?.delegate = self
        // Checking Authorization Status
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .denied {
            locationManager?.requestWhenInUseAuthorization()
            // self.updateCurrentLocation!(nil)
        }
    }

    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.delegate = nil
    }

    func fetchCurrentLocationWithDefaultLocation(completion: @escaping ((CurrentLocation, _ isCurrentLocationEnable: Bool) -> Void)) {

        var currentLocation: CLLocation? {
            didSet {
                guard let currentCoordinate = currentLocation?.coordinate else { return }
                var coordinate = currentCoordinate
                if let location = currentLocation {
                    if GMSGeometryContainsLocation(location.coordinate, locationManager.path, true) {
                        // Current Co-ordinate is in Riyadh
                    } else {
                        coordinate = self.riyadhCenterCoordinate
                    }
                    
                }
                
                GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(coordinate.latitude),\(coordinate.longitude)") { (location) in
                    if let results = location?.results, results.isNotEmpty, let result = results.first {
                        var addressComponents = [String]()
                        var addressHeader: String?
                        if let components = result.addressComponents {
                            for address in components {
                                if let types = address.types, !types.contains("postal_code") && !types.contains("postal_code_suffix") {
                                    addressComponents.append(address.longName ?? emptyString)
                                }
                            }
                        }
                        
                        var isCurrentLocationDetect: Bool = true
                        if coordinate.latitude == self.riyadhCenterCoordinate.latitude && coordinate.longitude == self.riyadhCenterCoordinate.longitude {
                            if addressComponents.count > 1 {
                                addressHeader = addressComponents.removeFirst()
                                if addressHeader == "PM7G+C4M" {
                                    addressHeader = addressComponents.removeFirst()
                                }
                            }
                            isCurrentLocationDetect = false
                        } else {
                            if addressComponents.count > 1 {
                                addressHeader = addressComponents.removeFirst()
                            }
                        }
                        
                        let data = CurrentLocation(id: result.placeID, address: addressHeader, subAddress: addressComponents.joined(separator: ", "), coordinate: coordinate)
                        completion(data, isCurrentLocationDetect)
                    } else {
                        let data = CurrentLocation(id: "", address: "", subAddress: "", coordinate: locationManager.riyadhCenterCoordinate)
                        completion(data, false)
                    }
                }
            }
        }

        let locationManager = LocationManager.SharedInstance
        
        if locationManager.locationStatus == .restricted || locationManager.locationStatus == .notDetermined || locationManager.locationStatus == .denied {
            let location: CLLocation = CLLocation(latitude: riyadhCenterCoordinate.latitude, longitude: riyadhCenterCoordinate.longitude)
            currentLocation = location
        } else {
            locationManager.startUpdatingLocation()
            locationManager.updateCurrentLocation = { location in
                currentLocation = location
            }
        }
    }
    
    func fetchCurrentLocation(completion: @escaping ((CurrentLocation) -> Void)) {

        var currentLocation: CLLocation? {
            didSet {
                guard let currentCoordinate = currentLocation?.coordinate else { return }
                
                var coordinate = currentCoordinate
                if let location = currentLocation {
                    if GMSGeometryContainsLocation(location.coordinate, locationManager.path, true) {
                        // Current Co-ordinate is in Riyadh
                    } else {
                        coordinate = self.riyadhCenterCoordinate
                    }
                }
                
                GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(coordinate.latitude),\(coordinate.longitude)") { (location) in
                    if let results = location?.results, results.isNotEmpty, let result = results.first {
                        var addressComponents = [String]()
                        var addressHeader: String?
                        if let components = result.addressComponents {
                            for address in components {
                                if let types = address.types, !types.contains("postal_code") && !types.contains("postal_code_suffix") {
                                    addressComponents.append(address.longName ?? emptyString)
                                }
                            }
                        }
                        
                        if coordinate.latitude == self.riyadhCenterCoordinate.latitude && coordinate.longitude == self.riyadhCenterCoordinate.longitude {
                            if addressComponents.count > 1 {
                                addressHeader = addressComponents.removeFirst()
                                if addressHeader == "PM7G+C4M" {
                                    addressHeader = addressComponents.removeFirst()
                                }
                            }
                        } else {
                            if addressComponents.count > 1 {
                                addressHeader = addressComponents.removeFirst()
                            }
                        }
                        
                        let data = CurrentLocation(id: result.placeID, address: addressHeader, subAddress: addressComponents.joined(separator: ", "), coordinate: coordinate)
                        completion(data)
                    }
                }
            }
        }

        let locationManager = LocationManager.SharedInstance
        
        if locationManager.locationStatus == .restricted || locationManager.locationStatus == .notDetermined || locationManager.locationStatus == .denied {
            let location: CLLocation = CLLocation(latitude: riyadhCenterCoordinate.latitude, longitude: riyadhCenterCoordinate.longitude)
            currentLocation = location
        } else {
            locationManager.startUpdatingLocation()
            locationManager.updateCurrentLocation = { location in
                currentLocation = location
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager?.startUpdatingLocation()
        case .denied:
            self.updateCurrentLocation!(nil)
        default:
            locationManager?.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        if let updateCurrentLocation = updateCurrentLocation {
            updateCurrentLocation(location)
        }
        self.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.updateCurrentLocation!(nil)
    }
}
