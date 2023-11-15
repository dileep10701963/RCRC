//
//  LocationSelectionOnMapController.swift
//  RCRC
//
//  Created by Aashish Singh on 08/05/23.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

enum SelectionType {
    case origin
    case destination
}

class LocationSelectionModel {
    var sourceType: SelectionType
    var origin: LocationData?
    var destination: LocationData?
    
    init(sourceType: SelectionType, origin: LocationData? = nil, destination: LocationData? = nil) {
        self.sourceType = sourceType
        self.origin = origin
        self.destination = destination
    }
    
}

protocol LocationSelectionOnMapDelegate: AnyObject {
    func didSelectOnMap(selectedModel: LocationSelectionModel?)
    func didSelectOnMapForFav(favLocation: SavedLocation?)
}

extension LocationSelectionOnMapDelegate {
    func didSelectOnMap(selectedModel: LocationSelectionModel?) {}
    func didSelectOnMapForFav(favLocation: SavedLocation?) {}
}

class LocationSelectionOnMapController: UIViewController {

    @IBOutlet weak var viewZoomButton: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    weak var delegate: LocationSelectionOnMapDelegate?
    
    var previousLocation = Constants.locationWhenUnavailable
    var travelPreferenceModal: TravelPreferenceModel? = nil
    var shadowView = UIView()
    var tapGesture = UITapGestureRecognizer()

//    var source = LocationData()
//    var destination = LocationData()
    
    let sourceLocationMarker = GMSMarker()
    let destinationLocationMarker = GMSMarker()
    var isSourceCurrentLocation: Bool = true
    private var infoWindow: MapInfoWindow?
    var selectedLocation: SavedLocation?
    let selectionTableView = UITableView()
    var homeViewModel = HomeViewModel()
    var locationModel: LocationSelectionModel?
    var isFromFavorite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .locationSelectionOnMap)
        
        DispatchQueue.main.async {
            self.addPolygon()
            
            let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
            self.mapView?.camera = camera
            self.mapView?.animate(to: camera)
        }
        
        initialize()
        configureMapView()
        
        self.setBusStopsOnMap()
    }
    
    private func setBusStopsOnMap() {
        if ServiceManager.sharedInstance.stopListItemData != nil {
            if let busStopModels:[StopsItem] = ServiceManager.sharedInstance.stopListItemData, busStopModels.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    DispatchQueue.main.async {
                       
                        
                        if busStopModels.count > 0 && self.mapView != nil {
                            for stopModel in busStopModels {
                                if let lat = CLLocationDegrees(stopModel.stop_lat ?? ""), let long = CLLocationDegrees(stopModel.stop_lon ?? "") {
                                    let markerPoint = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    let marker = GMSMarker()
                                    marker.position = markerPoint
                                    marker.map = self.mapView
                                    marker.icon = Images.livebusStatus?.imageWithNewSize(scaledToSize: CGSize(width: 18, height: 18)) //homeBusStopPin
                                }
                            }
                            
                            var gmsBounds = GMSCoordinateBounds()
                            for stopModel in busStopModels {
                                if let lat = CLLocationDegrees(stopModel.stop_lat ?? ""), let long = CLLocationDegrees(stopModel.stop_lon ?? "")  {
                                    let markerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    gmsBounds = gmsBounds.includingCoordinate(markerCoordinate)
                                }
                            }
                            
                            if let locationModel = self.locationModel {
                                if (locationModel.origin != nil && locationModel.origin?.coordinate?.latitude != 0.0 && locationModel.origin?.coordinate?.latitude != 0.0) || (locationModel.destination != nil && locationModel.destination?.coordinate?.latitude != 0.0 && locationModel.destination?.coordinate?.longitude != 0.0) {
                                    self.setupMarkerForOriginAndDestinationAfterSelection()
                                } else {
                                    let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 12)
                                    self.mapView?.animate(with: update)
                                }
                            } else {
                                let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 12)
                                self.mapView?.animate(with: update)
                            }
                            
                        }
                    }
                }
            }
        } else {
            self.fetchBusStopsForMap()
        }
    }

    private func fetchBusStopsForMap() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.homeViewModel.getBusStopListForMap { [weak self] (busStopList, error) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let busStopList = busStopList {
                        ServiceManager.sharedInstance.stopListItemData = busStopList
                        
                        
                        if busStopList.count > 0 && self.mapView != nil {
                            for busModel in busStopList {
                                if let lat = Double(busModel.stop_lat ?? ""), let long = Double(busModel.stop_lon ?? "") {
                                    let markerPoint = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    let marker = GMSMarker()
                                    marker.position = markerPoint
                                    marker.map = self.mapView
                                    marker.icon = Images.livebusStatus?.imageWithNewSize(scaledToSize: CGSize(width: 18, height: 18)) //homeBusStopPin
                                }
                            }
                            
                            var gmsBounds = GMSCoordinateBounds()
                            for busModel in busStopList {
                                if let lat = Double(busModel.stop_lat ?? ""), let long = Double(busModel.stop_lon ?? "") {
                                    let markerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    gmsBounds = gmsBounds.includingCoordinate(markerCoordinate)
                                }
                            }
                            
                            if let locationModel = self.locationModel {
                                if (locationModel.origin != nil && locationModel.origin?.coordinate?.latitude != 0.0 && locationModel.origin?.coordinate?.latitude != 0.0) || (locationModel.destination != nil && locationModel.destination?.coordinate?.latitude != 0.0 && locationModel.destination?.coordinate?.longitude != 0.0) {
                                    self.setupMarkerForOriginAndDestinationAfterSelection()
                                } else {
                                    let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 12)
                                    self.mapView?.animate(with: update)
                                }
                            } else {
                                let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 12)
                                self.mapView?.animate(with: update)
                            }
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.planATrip.localized)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    fileprivate func configureMapView() {
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.padding.bottom = 90
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.mapView.delegate = self
    }

    func setupMarkerForOriginAndDestinationAfterSelection() {
        if let locationModel = locationModel {

            if let origin = locationModel.origin, let originCoord = origin.coordinate, originCoord.latitude != 0.0, originCoord.longitude != 0.0, let destinationModel = locationModel.destination, let destCoordinate = destinationModel.coordinate, destCoordinate.latitude != 0.0, destCoordinate.longitude != 0.0 {
                
                placeLocationMarkerForSelectedBus(marker: self.sourceLocationMarker, coordinate: originCoord)
                placeLocationMarkerForSelectedBus(marker: self.destinationLocationMarker, coordinate: destCoordinate)
                
                var gmsBounds = GMSCoordinateBounds()
                let coord: [CLLocationCoordinate2D] = [originCoord, destCoordinate]
                for coordinate2d in coord {
                    gmsBounds = gmsBounds.includingCoordinate(coordinate2d)
                }
                
                DispatchQueue.main.async {
                    let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 12)
                    self.mapView?.animate(with: update)
                }
                
            } else if let origin = locationModel.origin, let originCoord = origin.coordinate, originCoord.latitude != 0.0 && originCoord.longitude != 0.0 {
                
                placeLocationMarkerForSelectedBus(marker: self.sourceLocationMarker, coordinate: originCoord)
                let camera = GMSCameraPosition(target: originCoord, zoom: Constants.mapViewZoomLevel)
                self.mapView.camera = camera
                
            } else if let destinationModel = locationModel.destination, let destCoordinate = destinationModel.coordinate, destCoordinate.latitude != 0.0 && destCoordinate.longitude != 0.0 {
                
                placeLocationMarkerForSelectedBus(marker: self.destinationLocationMarker, coordinate: destCoordinate)
                let camera = GMSCameraPosition(target: destCoordinate, zoom: Constants.mapViewZoomLevel)
                self.mapView.camera = camera
                
            } else {
                print("****** Executing Else Statement ******")
            }
            
        }
    }
    
    func initialize() {
        
        switch isFromFavorite {
        case true:
            LocationManager.SharedInstance.fetchCurrentLocationWithDefaultLocation { [weak self] (location, _) in
                let data = LocationData(id: location.id,
                                        address: location.address,
                                        subAddress: location.subAddress,
                                        coordinate: location.coordinate,
                                        type: .coordinate)
                DispatchQueue.main.async {
                    if let self = self {
                        if let coordinate = data.coordinate {
                            self.placeLocationMarker(marker: self.sourceLocationMarker, coordinate: coordinate)
                        } else {
                            self.placeLocationMarker(marker: self.sourceLocationMarker, coordinate: LocationManager.SharedInstance.riyadhCenterCoordinate)
                        }
                    }
                }
            }
            
        case false:
            if let locationModel = locationModel {
                if (locationModel.origin != nil && locationModel.origin?.coordinate?.latitude != 0.0 && locationModel.origin?.coordinate?.latitude != 0.0) || (locationModel.destination != nil && locationModel.destination?.coordinate?.latitude != 0.0 && locationModel.destination?.coordinate?.longitude != 0.0) {
                    self.setupMarkerForOriginAndDestinationAfterSelection()
                }
            }
        }
    }

    fileprivate func placeLocationMarkerForSelectedBus(marker: GMSMarker, coordinate: CLLocationCoordinate2D) {
        if marker == self.sourceLocationMarker {
            marker.icon = Images.mapSelectedOriginPin
        } else if marker == self.destinationLocationMarker {
            marker.icon = Images.mapDestinationPin
        }
        
        marker.position = coordinate
        marker.map = self.mapView
    }
    
    fileprivate func placeLocationMarker(marker: GMSMarker, coordinate: CLLocationCoordinate2D) {
        if marker == self.sourceLocationMarker {
            marker.icon = UIImage()//Images.mapOriginPin
        } else if marker == self.destinationLocationMarker {
            marker.icon = UIImage()//Images.mapDestinationPin
            marker.groundAnchor = CGPoint(x: 0, y: 1)
        }
        marker.position = coordinate
        marker.map = self.mapView
    }

    private func fetchCurrentLocation(selectionType: SelectionType) {
        LocationManager.SharedInstance.fetchCurrentLocationWithDefaultLocation { [weak self] (location, _) in
            let data = LocationData(id: location.id,
                                    address: location.address,
                                    subAddress: location.subAddress,
                                    coordinate: location.coordinate,
                                    type: .coordinate)
            DispatchQueue.main.async {
                
                if let self = self {
                    if let coordinate = data.coordinate {
                        if selectionType == .origin {
                            self.locationModel?.origin = data
                            self.placeLocationMarker(marker: self.sourceLocationMarker, coordinate: coordinate)
                        } else {
                            self.locationModel?.destination = data
                            self.placeLocationMarker(marker: self.destinationLocationMarker, coordinate: coordinate)
                        }
                        
                        let camera = GMSCameraPosition(target: coordinate, zoom: Constants.mapViewZoomLevel)
                        self.mapView.camera = camera
                        
                    } else {
                        if selectionType == .origin {
                            self.placeLocationMarker(marker: self.sourceLocationMarker, coordinate: LocationManager.SharedInstance.riyadhCenterCoordinate)
                        } else {
                            self.locationModel?.destination = data
                            self.placeLocationMarker(marker: self.destinationLocationMarker, coordinate: LocationManager.SharedInstance.riyadhCenterCoordinate)
                        }
                        
                        let camera = GMSCameraPosition(target: LocationManager.SharedInstance.riyadhCenterCoordinate, zoom: Constants.mapViewZoomLevel)
                        self.mapView.camera = camera
                    }
                }
            }
        }
    }

    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {

        if sender.view == self.shadowView {
//            hidePicker()
            //selectionTableView.removeFromSuperview()
        }
    }
    
    @IBAction func locationZoomInOutButtonTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            Constants.mapViewZoomLevel += 10
            mapView.animate(toZoom: Constants.mapViewZoomLevel)
        } else {
            Constants.mapViewZoomLevel -= 10
            mapView.animate(toZoom: Constants.mapViewZoomLevel)
        }
    }
    
}


extension LocationSelectionOnMapController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if isFromFavorite {
            self.saveLocationForFav(locationCoord: marker.position)
        } else {
            if let locationModel = self.locationModel {
                self.updateLocationModel(locationCoord: marker.position, selectionType: locationModel.sourceType)
            }
        }
        return false
    }

    func addPolygon() {
        guard let paths = Bundle.main.path(forResource: "RiyadhGeoJSON", ofType: "json") else {
            return
        }
        let url = URL(fileURLWithPath: paths)
        let geoJsonParser = GMUGeoJSONParser(url: url)
        geoJsonParser.parse()
        var renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
        var style: GMUStyle = GMUStyle()
        for (index, feature) in geoJsonParser.features.enumerated() {
            if index == 0 {
                style = GMUStyle(styleID: "random", stroke: .black, fill: UIColor.black.withAlphaComponent(0.2), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
            } else {
            style = GMUStyle(styleID: "random1", stroke: .black, fill: .clear, width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)

            }
            feature.style = style
        }
        renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
        renderer.render()
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if isFromFavorite {
            self.saveLocationForFav(locationCoord: coordinate)
        } else {
            if let locationModel = self.locationModel {
                self.updateLocationModel(locationCoord: coordinate, selectionType: locationModel.sourceType)
                
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        if isFromFavorite {
            self.saveLocationForFav(placeID: placeID, name: name, locationCoord: location)
        } else {
            if let locationModel = self.locationModel {
                self.updateLocationModel(placeID: placeID, name: name, locationCoord: location, selectionType: locationModel.sourceType)
            }
        }
        
    }
    
    func updateLocationModel(placeID: String = emptyString, name: String = emptyString, locationCoord: CLLocationCoordinate2D, selectionType: SelectionType) {
        
        var recentSearch: RecentSearch!
        
        switch selectionType {
        case .origin:
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(locationCoord.latitude),\(locationCoord.longitude)") { [weak self] (location) in
                if let result = location?.results, result.count > 0 {
                    
                    var busStopsFilter: [GeocodeResult] = []
                    busStopsFilter = result.filter({ singleResult in
                        if let types = singleResult.types, types.count > 0 {
                            return types.contains(where: {$0 == "bus_station" || $0 == "transit_station"})
                        } else {
                            return false
                        }
                    })
                    
                    if busStopsFilter.count <= 0 {
                        self?.stopNameDifferFromGoogleAPI(placeID: placeID, name: name, locationCoord: locationCoord, selectionType: selectionType)
                        return
                    }
                    
                    var googlePlaceID: String = placeID == emptyString ? busStopsFilter[0].placeID ?? emptyString : placeID
                    let placeName: String? = name == emptyString ? busStopsFilter[0].addressComponents?.first?.shortName ?? emptyString : name
                    
                    googlePlaceID = self?.homeViewModel.getStopGlobalID(name: placeName ?? emptyString) ?? emptyString
                    
                    let originData = LocationData(id: googlePlaceID, address: busStopsFilter[0].formattedAddress, subAddress: placeName, coordinate: locationCoord, type: .stop)
                    
                    recentSearch = RecentSearch(id: googlePlaceID, location: placeName, address: busStopsFilter[0].formattedAddress, latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.stop)
                    
                    self?.locationModel?.origin = originData
                } else {
                    //let globalPlaceID = self?.homeViewModel.getStopGlobalID(name: name)
                    let globalPlaceID = self?.homeViewModel.getStoGlobalIDByCoordinate(lat: "\(locationCoord.latitude)", long: "\(locationCoord.longitude)") ?? emptyString
                   let name = self?.homeViewModel.getBusStopNamebyCordinate(coordinate: locationCoord) ?? emptyString
                    let originData = LocationData(id: globalPlaceID, address: "", subAddress: name, coordinate: locationCoord, type: .stop)
                    recentSearch = RecentSearch(id: globalPlaceID, location: name, address: "", latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.stop)
                    
                    self?.locationModel?.origin = originData
                }
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if recentSearch != nil {
                        if self.isPlaceSaved(location: recentSearch) {
                            RecentSearchDataRepository.shared.delete(record: recentSearch)
                        }
                        RecentSearchDataRepository.shared.create(record: recentSearch)
                    }
                    self.delegate?.didSelectOnMap(selectedModel: self.locationModel)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        case .destination:
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(locationCoord.latitude),\(locationCoord.longitude)") { [weak self] (location) in
                if let result = location?.results, result.count > 0 {
                    
                    var busStopsFilter: [GeocodeResult] = []
                    busStopsFilter = result.filter({ singleResult in
                        if let types = singleResult.types, types.count > 0 {
                            return types.contains(where: {$0 == "bus_station" || $0 == "transit_station"})
                        } else {
                            return false
                        }
                    })
                    
                    if busStopsFilter.count <= 0 {
                        self?.stopNameDifferFromGoogleAPI(placeID: placeID, name: name, locationCoord: locationCoord, selectionType: selectionType)
                        return
                    }
                    
                    
                    var googlePlaceID: String = placeID == emptyString ? busStopsFilter[0].placeID ?? emptyString : placeID
                    let placeName: String? = name == emptyString ? busStopsFilter[0].addressComponents?.first?.shortName ?? emptyString : name
                    
                    googlePlaceID = self?.homeViewModel.getStopGlobalID(name: placeName ?? emptyString) ?? emptyString
                    
                    let destinationData = LocationData(id: googlePlaceID, address: busStopsFilter[0].formattedAddress, subAddress: placeName, coordinate: locationCoord, type: .stop)
                    
                    recentSearch = RecentSearch(id: googlePlaceID, location: placeName, address: busStopsFilter[0].formattedAddress, latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.stop)
                    
                    self?.locationModel?.destination = destinationData
                } else {
                    let globalPlaceID = self?.homeViewModel.getStoGlobalIDByCoordinate(lat: "\(locationCoord.latitude)", long: "\(locationCoord.longitude)") ?? emptyString
                    
                    let name = self?.homeViewModel.getBusStopNamebyCordinate(coordinate: locationCoord) ?? emptyString
                    let destinationData = LocationData(id: globalPlaceID, address: "", subAddress: name, coordinate: locationCoord, type: .stop)
                    
                    recentSearch = RecentSearch(id: globalPlaceID, location: name, address: "", latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.stop)
                    
                    self?.locationModel?.destination = destinationData
                }
                DispatchQueue.main.async {
                    
                    guard let self = self else { return }
                    if recentSearch != nil {
                        if self.isPlaceSaved(location: recentSearch){
                            RecentSearchDataRepository.shared.delete(record: recentSearch)
                        }
                        RecentSearchDataRepository.shared.create(record: recentSearch)
                    }
                    
                    self.delegate?.didSelectOnMap(selectedModel: self.locationModel)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func stopNameDifferFromGoogleAPI(placeID: String = emptyString, name: String = emptyString, locationCoord: CLLocationCoordinate2D, selectionType: SelectionType) {
        
        guard let stopModels:[StopsItem] = ServiceManager.sharedInstance.stopListItemData, stopModels.count > 0 else { return }
        
         
        let fliteredStopModel:[StopsItem] = stopModels.filter({$0.stop_lat == "\(locationCoord.latitude)" && $0.stop_lon == "\(locationCoord.longitude)" })
        
             
        if let busStopModel = fliteredStopModel.last {
            
            var recentSearch: RecentSearch!
            
            switch selectionType {
            case .origin:
                
                let originData = LocationData(id: "\(busStopModel.record_id ?? 0)", address: "", subAddress: busStopModel.translation ?? "", coordinate: locationCoord, type: .stop)
                recentSearch = RecentSearch(id: "\(busStopModel.record_id ?? 0)" , location: busStopModel.translation ?? "", address: "", latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.stop)
                
                self.locationModel?.origin = originData
                
                DispatchQueue.main.async {
                    if recentSearch != nil {
                        if self.isPlaceSaved(location: recentSearch) {
                            RecentSearchDataRepository.shared.delete(record: recentSearch)
                        }
                        RecentSearchDataRepository.shared.create(record: recentSearch)
                    }
                    self.delegate?.didSelectOnMap(selectedModel: self.locationModel)
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .destination:
                
                let destinationData = LocationData(id: "\(busStopModel.record_id ?? 0)", address: "", subAddress: busStopModel.translation ?? "", coordinate: locationCoord, type: .stop)
                recentSearch = RecentSearch(id: "\(busStopModel.record_id ?? 0)" , location: busStopModel.translation ?? "", address: "", latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.stop)
                self.locationModel?.destination = destinationData
                
                DispatchQueue.main.async {
                    if recentSearch != nil {
                        if self.isPlaceSaved(location: recentSearch) {
                            RecentSearchDataRepository.shared.delete(record: recentSearch)
                        }
                        RecentSearchDataRepository.shared.create(record: recentSearch)
                    }
                    self.delegate?.didSelectOnMap(selectedModel: self.locationModel)
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
        
    }
    
    func saveLocationForFav(placeID: String = emptyString, name: String = emptyString, locationCoord: CLLocationCoordinate2D) {
        var saveLocation: SavedLocation!
        
        GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(locationCoord.latitude),\(locationCoord.longitude)") { [weak self] (location) in
            if let result = location?.results, result.count > 0 {
                let googlePlaceID: String = placeID == emptyString ? result[0].placeID ?? emptyString : placeID
                let placeName: String? = name == emptyString ? result[0].addressComponents?.first?.shortName ?? emptyString : name
                saveLocation = SavedLocation(location: placeName, address: result[0].formattedAddress, id: googlePlaceID, latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.coordinate)
            } else {
                
                saveLocation = SavedLocation(location: name, address: "", id: placeID, latitude: locationCoord.latitude, longitude: locationCoord.longitude, type: Constants.coordinate)
            }
            DispatchQueue.main.async {
                guard let self = self else { return }
                if saveLocation != nil {
                    self.delegate?.didSelectOnMapForFav(favLocation: saveLocation)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func isPlaceSaved(location: RecentSearch) -> Bool {
        if let savedData = RecentSearchDataRepository.shared.fetchAll(),
           savedData.contains(location) {
            return true
        }
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        if let mylocation = mapView.myLocation {
            let locationManager = LocationManager.SharedInstance
            if GMSGeometryContainsLocation(mylocation.coordinate, locationManager.path, true) {
                self.mapView?.addMarkerOn(location: mylocation.coordinate, markerImage: UIImage()) //Images.mapOriginPin
                return false
            } else {
                let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
                self.mapView?.animate(to: camera)
                self.mapView?.addMarkerOn(location: locationManager.riyadhCenterCoordinate, markerImage: UIImage()) //Images.mapOriginPin
                return true
            }
        } else {
            return true
        }
    }

}
