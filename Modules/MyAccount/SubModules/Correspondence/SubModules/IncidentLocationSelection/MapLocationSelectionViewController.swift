//
//  MapLocationSelectionViewController.swift
//  RCRC
//
//  Created by Errol on 26/04/21.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

struct MapLocation {
    var address: String?
    var subAddress: String?
    var latitude: Double?
    var longitude: Double?
}

class MapLocationSelectionViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!

    var selectedLocation: MapLocation?
    weak var delegate: ReportLocationSelectionDelegate?
    let locationMarker = GMSMarker()
    var isMapLoaded: Bool = false
    var previousLocation = Constants.locationWhenUnavailable

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .locationSelectionOnMap)
        self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        mapView.delegate = self
        DispatchQueue.main.async {
            self.addPolygon()
        }
    }

    private func addPolygon() {
        guard let paths = Bundle.main.path(forResource: Constants.geoJsonFileName, ofType: Constants.jsonType) else {
            return
        }
        let url = URL(fileURLWithPath: paths)
        let geoJsonParser = GMUGeoJSONParser(url: url)
        geoJsonParser.parse()
        var renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
        var style: GMUStyle = GMUStyle()
        for (index, feature) in geoJsonParser.features.enumerated() {
            if index == 0 {
                style = GMUStyle(styleID: Constants.random, stroke: .black, fill: UIColor.black.withAlphaComponent(0.2), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
            } else {
                style = GMUStyle(styleID: Constants.randomOne, stroke: .black, fill: .clear, width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)

            }
            feature.style = style
        }
        renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
        renderer.render()
    }

    private func configureLocationMarker() {
        locationMarker.icon = Images.mapOriginPin
        locationMarker.map = self.mapView
    }

    private func fetchCurrentLocation() {
        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { location in
            if let location = location {
                self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: Constants.mapViewZoomLevel)

            } else {
                self.showCustomAlert(alertTitle: Constants.noLocationAlertTitle.localized,
                                     alertMessage: Constants.noLocationAlertMessage.localized,
                                     firstActionTitle: Constants.goToSettings.localized,
                                     secondActionTitle: cancel,
                                     secondActionStyle: .cancel,
                                     firstActionHandler: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
                    }
                }, secondActionHandler: nil)
                let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
                self.mapView.camera = camera
            }
        }
    }

    @IBAction func proceedTapped(_ sender: UIButton) {
        guard let selectedLocation = self.selectedLocation else { return }
        delegate?.didSelectLocation(selectedLocation)
        self.dismiss(animated: true)
    }
}

extension MapLocationSelectionViewController: GMSMapViewDelegate {

    func mapViewSnapshotReady(_ mapView: GMSMapView) {
        if !isMapLoaded {
            fetchCurrentLocation()
            configureLocationMarker()
            isMapLoaded = true
        }
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        locationMarker.position = coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let camera = GMSCameraPosition(target: coordinate, zoom: Constants.mapViewZoomLevel)
        self.mapView.camera = camera
        GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(latitude),\(longitude)") { (result) in
            guard let address = result?.results?.first?.formattedAddress else { return }
            self.locationLabel.text = "Selected Location:\n\(address)"
            self.selectedLocation = MapLocation(address: address, subAddress: nil, latitude: latitude, longitude: longitude)
        }
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        locationMarker.position = position.target
        if GMSGeometryContainsLocation(position.target, LocationManager.SharedInstance.path, true) {
            previousLocation = position.target
        } else {
            DispatchQueue.main.async {
                self.showCustomAlert(alertTitle: Constants.locationOutOfRiyadhCityTitle.localized, alertMessage: Constants.locationOutOfRiyadhCity.localized, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                    self.mapView.camera = GMSCameraPosition(latitude: self.previousLocation.latitude, longitude: self.previousLocation.longitude, zoom: Constants.mapViewZoomLevel)
                    self.locationMarker.position = self.previousLocation
                }, secondActionHandler: nil)
            }
        }
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        locationMarker.position = position.target
        let latitude = position.target.latitude
        let longitude = position.target.longitude
        GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(latitude),\(longitude)") { (result) in
            guard let address = result?.results?.first?.formattedAddress else { return }
            self.locationLabel.text = "Selected Location:\n\(address)"
            self.selectedLocation = MapLocation(address: address, subAddress: nil, latitude: latitude, longitude: longitude)
        }
    }
}
