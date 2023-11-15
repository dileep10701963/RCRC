//
//  LocationSelectionUsingMapViewController.swift
//  RCRC
//
//  Created by Errol on 09/02/21.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
class LocationSelectionUsingMapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var routeSelectionView: RouteSelectionView!
    @IBOutlet weak var selectLocationLabel: UILabel!
    @IBOutlet weak var proceedButtonView: ProceedButtonView!
    var previousLocation = Constants.locationWhenUnavailable
    var travelPreferenceModal: TravelPreferenceModel? = nil
    var shadowView = UIView()
    var tapGesture = UITapGestureRecognizer()
    var activeSearchBar: UISearchBar? {
        didSet {
            guard let activeSearchBar = activeSearchBar else {
                return
            }
            if let oldValue = oldValue {
                oldValue.textField?.layer.borderColor = UIColor.clear.cgColor
            }
            activeSearchBar.textField?.layer.borderColor = Colors.green.cgColor
            if activeSearchBar == self.routeSelectionView.originSearchBar {
                self.selectLocationLabel.text = Constants.selectSourceOnMap.localized
                guard let sourceCoordinate = self.source.coordinate else {
                    return
                }
                let camera = GMSCameraPosition(target: sourceCoordinate, zoom: Constants.mapViewZoomLevel)
                self.mapView.camera = camera
            } else if activeSearchBar == self.routeSelectionView.destinationSearchBar {
                self.selectLocationLabel.text = Constants.selectDestinationOnMap.localized
                guard let destinationCoordinate = self.destination.coordinate else {
                    return
                }
                let camera = GMSCameraPosition(target: destinationCoordinate, zoom: Constants.mapViewZoomLevel)
                self.mapView.camera = camera
            } else {
                self.selectLocationLabel.text = emptyString
            }
        }
    }
    var source = LocationData()
    var destination = LocationData()
    let sourceLocationMarker = GMSMarker()
    let destinationLocationMarker = GMSMarker()
    var isSourceCurrentLocation: Bool = true
    private var infoWindow: MapInfoWindow?
    var selectedLocation: SavedLocation?
    let selectionTableView = UITableView()
    var searchPreferences: SelectedSearchPreferences?
    var homeViewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .locationSelectionOnMap)
        DispatchQueue.main.async {
            self.mapView.addPolygon()
        }

        configureDelegates()
        initialize()
        configureMapView()
        self.activeSearchBar = self.routeSelectionView.destinationSearchBar
        routeSelectionView.backButtonDelegate = self
        self.setBusStopsOnMap()
    }
    
    private func setBusStopsOnMap() {
        if ServiceManager.sharedInstance.stopListItemData != nil {
            if let busStopList = ServiceManager.sharedInstance.stopListItemData, busStopList.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    DispatchQueue.main.async {
                      
                        if busStopList.count > 0 && self.mapView != nil {
                            for busModel in busStopList {
                                if let lat = Double(busModel.stop_lat ?? ""), let long = Double(busModel.stop_lon ?? "") {
                                    let markerPoint = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    let marker = GMSMarker()
                                    marker.position = markerPoint
                                    marker.map = self.mapView
                                    marker.icon = Images.busStopPin?.imageWithNewSize()
                                }
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
                    if let busModelList = busStopList {
                        ServiceManager.sharedInstance.stopListItemData = busStopList
                        if busModelList.count > 0 && self.mapView != nil {
                            for busModel in busModelList {
                                if let lat = Double(busModel.stop_lat ?? ""), let long = Double(busModel.stop_lon ?? "") {
                                    let markerPoint = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    let marker = GMSMarker()
                                    marker.position = markerPoint
                                    marker.map = self.mapView
                                    marker.icon = Images.busStopPin?.imageWithNewSize()
                                    
                                }
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
        //routeSelectionView.refresh()
        if routeSelectionView != nil && routeSelectionView.destinationSearchBar != nil {
            routeSelectionView.destinationSearchBar.textField?.clearButtonMode = .never
        }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        routeSelectionView.endEditing(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

    func initialize() {
        if isSourceCurrentLocation {
            DispatchQueue.global(qos: .utility).async {
                self.fetchCurrentLocation()
            }
        } else {
            if let sourceCoordinate = self.source.coordinate {
                routeSelectionView.originSearchBar.showsBookmarkButton = false
                self.mapView.isMyLocationEnabled = false
                self.mapView.settings.myLocationButton = false
                placeLocationMarker(marker: self.sourceLocationMarker, coordinate: sourceCoordinate)
                GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(sourceCoordinate.latitude),\(sourceCoordinate.longitude)") { [weak self] (location) in
                    if let result = location?.results, result.count > 0 {
                        self?.source.address = result[0].formattedAddress
                        self?.routeSelectionView.originSearchBar.text = result[0].formattedAddress
                    }
                }
            }
        }
        if let destinationCoordinate = self.destination.coordinate {
            placeLocationMarker(marker: self.destinationLocationMarker, coordinate: destinationCoordinate)
            let camera = GMSCameraPosition(target: destinationCoordinate, zoom: Constants.mapViewZoomLevel)
            self.mapView.camera = camera
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)") { [weak self] (location) in
                if let result = location?.results, result.count > 0 {
                    self?.destination.address = result[0].formattedAddress
                    self?.routeSelectionView.destinationSearchBar.text = result[0].formattedAddress
                }
            }
        } else {
            placeLocationMarker(marker: self.destinationLocationMarker, coordinate: Constants.locationWhenUnavailable)
            let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
            self.mapView.camera = camera
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(Constants.locationWhenUnavailable.latitude),\(Constants.locationWhenUnavailable.longitude)") { [weak self] (location) in
                if let result = location?.results, result.count > 0 {
                    self?.source.address = result[0].formattedAddress
                    self?.routeSelectionView.originSearchBar.text = result[0].formattedAddress
                }
            }
        }
    }

    fileprivate func placeLocationMarker(marker: GMSMarker, coordinate: CLLocationCoordinate2D) {
        if marker == self.sourceLocationMarker {
            marker.icon = Images.mapOriginPin
        } else if marker == self.destinationLocationMarker {
            marker.icon = Images.mapDestinationPin
            marker.groundAnchor = CGPoint(x: 0, y: 1)
        }
        marker.position = coordinate
        marker.map = self.mapView
    }

//    fileprivate func fetchCurrentLocation() {
//        let locationManager = LocationManager.SharedInstance
//        locationManager.startUpdatingLocation()
//        locationManager.updateCurrentLocation = { location in
//            if let location = location {
//                self.source.coordinate = location.coordinate
//                self.placeLocationMarker(marker: self.sourceLocationMarker, coordinate: location.coordinate)
//                GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(location.coordinate.latitude),\(location.coordinate.longitude)") { (location) in
//                    if let result = location?.results, result.count > 0 {
//                        self.source.address = result[0].formattedAddress
//                        self.routeSelectionView.originSearchBar.text = Constants.yourCurrentLocation
//                    }
//                }
//            } else {
//                self.showCustomAlert(alertTitle: Constants.noLocationAlertTitle,
//                                     alertMessage: Constants.noLocationAlertMessage,
//                                     firstActionTitle: Constants.goToSettings,
//                                     secondActionTitle: cancel,
//                                     secondActionStyle: .cancel,
//                                     firstActionHandler: {
//                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                        return
//                    }
//                    if UIApplication.shared.canOpenURL(settingsUrl) {
//                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
//                    }
//                }, secondActionHandler: nil)
//                let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
//                self.source.coordinate = Constants.locationWhenUnavailable
//                GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(Constants.locationWhenUnavailable.latitude),\(Constants.locationWhenUnavailable.longitude)") { (location) in
//                    if let result = location?.results, result.count > 0 {
//                        self.source.address = result[0].formattedAddress
//                        self.routeSelectionView.originSearchBar.text = result[0].formattedAddress
//                    }
//                }
//                self.mapView.camera = camera
//                // - Need to set different image for current location(todo)
//                if let sourceCoordinate = self.source.coordinate {
//                    self.placeLocationMarker(marker: self.sourceLocationMarker, coordinate: sourceCoordinate)
//                }
//            }
//        }
//    }

    private func fetchCurrentLocation() {
        LocationManager.SharedInstance.fetchCurrentLocation { [weak self] (location) in
            let data = LocationData(id: location.id,
                                    address: location.address,
                                    subAddress: location.subAddress,
                                    coordinate: location.coordinate,
                                    type: .coordinate)
            self?.source = data
            DispatchQueue.main.async {
                self?.routeSelectionView.originSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation.localized,
                                                                                       attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
            }
        }
    }

    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {

        if sender.view == self.shadowView {
            hidePicker()
            selectionTableView.removeFromSuperview()
        }
    }

    func configureDelegates() {
        self.routeSelectionView.delegate = self
        self.proceedButtonView.delegate = self
        self.routeSelectionView.originSearchBar.delegate = self
        self.routeSelectionView.destinationSearchBar.delegate = self
    }

    @IBAction func zoomInOutButtonTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            Constants.mapViewZoomLevel += 1
            mapView.animate(toZoom: Constants.mapViewZoomLevel)
        } else {
            Constants.mapViewZoomLevel -= 1
            mapView.animate(toZoom: Constants.mapViewZoomLevel)
        }
    }

    fileprivate func attributedText(_ firstString: String, _ secondString: String, _ firstFont: UIFont = Fonts.RptaSignage.sixteen!,
                                    _ secondFont: UIFont = Fonts.RptaSignage.fourteen!) -> NSMutableAttributedString {
        let stopNameAttribute = [NSAttributedString.Key.font: firstFont]
        let stopAddressAttribute = [NSMutableAttributedString.Key.font: secondFont, NSMutableAttributedString.Key.foregroundColor: Colors.darkGray]
        let stopName = NSMutableAttributedString(string: firstString + ", ", attributes: stopNameAttribute as [NSAttributedString.Key: Any])
        let stopAddress = NSMutableAttributedString(string: secondString, attributes: stopAddressAttribute as [NSAttributedString.Key: Any])
        stopName.append(stopAddress)
        return stopName
    }
}

extension LocationSelectionUsingMapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker == self.sourceLocationMarker {
            self.routeSelectionView.originSearchBar.becomeFirstResponder()
        } else if marker == self.destinationLocationMarker {
            self.routeSelectionView.destinationSearchBar.becomeFirstResponder()
        }
        infoWindow?.removeFromSuperview()
        infoWindow = MapInfoWindow.instanceFromNib()
        infoWindow?.translatesAutoresizingMaskIntoConstraints = false
        infoWindow?.delegate = self
        infoWindow?.borderWidth = 1.0
        infoWindow?.borderColor = .lightGray
        GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(marker.position.latitude),\(marker.position.longitude)") { [weak self] (location) in
            guard let self = self else { return }
            if let results = location?.results, results.isNotEmpty, let result = results.first, let addressComponents = result.addressComponents, addressComponents.count > 1 {
                var completeAddress: String = emptyString
                let placeAddress = addressComponents.first?.shortName ?? emptyString
                for index in 1..<addressComponents.count {
                    if let types = addressComponents[index].types, !types.contains("postal_code") {
                        completeAddress.append((addressComponents[index].shortName ?? emptyString) + space)
                    }
                }
                self.selectedLocation = SavedLocation(location: placeAddress, address: completeAddress, id: result.placeID, latitude: marker.position.latitude, longitude: marker.position.longitude, type: Constants.coordinate)
                self.infoWindow?.addressLabel.attributedText = self.attributedText(placeAddress, completeAddress)
            }
        }
        self.view.addSubview(infoWindow ?? UIView())
        infoWindow?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        infoWindow?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50).isActive = true
        infoWindow?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        infoWindow?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 10).isActive = true
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

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if activeSearchBar == self.routeSelectionView.activeSearchBar {
            if let coordinate = self.source.coordinate, String(format: "%.5f", coordinate.latitude) == String(format: "%.5f", position.target.latitude), String(format: "%.5f", coordinate.longitude) == String(format: "%.5f", position.target.longitude) {
                return
            }
        } else if activeSearchBar == self.routeSelectionView.destinationSearchBar {
            if let coordinate = self.destination.coordinate, String(format: "%.5f", coordinate.latitude) == String(format: "%.5f", position.target.latitude), String(format: "%.5f", coordinate.longitude) == String(format: "%.5f", position.target.longitude) {
                return
            }
        }
        
          // return
        if GMSGeometryContainsLocation(position.target, LocationManager.SharedInstance.path, true) {
            print("locationPoint is in Riyadh.")
            previousLocation = position.target
        } else {
            print("locationPoint is NOT in Riyadh.")
           // self.showToast("locationPoint is NOT in Riyadh.")
            DispatchQueue.main.async {
                self.showCustomAlert(alertTitle: Constants.locationOutOfRiyadhCityTitle.localized, alertMessage: Constants.locationOutOfRiyadhCity.localized, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                    self.mapView.camera = GMSCameraPosition(latitude: self.previousLocation.latitude, longitude: self.previousLocation.longitude, zoom: Constants.mapViewZoomLevel)
                    if self.activeSearchBar == self.routeSelectionView.destinationSearchBar {
                        self.placeLocationMarker(marker: self.destinationLocationMarker, coordinate: self.previousLocation)
                    } else {
                        self.placeLocationMarker(marker: self.sourceLocationMarker, coordinate: self.previousLocation)
                    }
                }, secondActionHandler: nil)
                self.showCustomAlert(alertTitle: "Location", alertMessage: "Location point is Not is Riyadh", firstActionTitle: ok)
            }
        }

        if activeSearchBar == self.routeSelectionView.originSearchBar {
            self.source.coordinate = position.target
            if let myLocation = mapView.myLocation {
                if myLocation.coordinate.latitude == position.target.latitude.round(to: 5) && myLocation.coordinate.longitude == position.target.longitude.round(to: 5) {
                    
                    if let coordinate = self.source.coordinate, String(format: "%.5f", coordinate.latitude) == String(format: "%.5f", position.target.latitude), String(format: "%.5f", coordinate.longitude) == String(format: "%.5f", position.target.longitude) {
                        return
                    }
                    
                    placeLocationMarker(marker: self.sourceLocationMarker, coordinate: position.target)
                    GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(position.target.latitude),\(position.target.longitude)") { [weak self] (location) in
                        if let result = location?.results, result.count > 0 {
                            self?.source.address = result[0].formattedAddress
                            self?.routeSelectionView.originSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation.localized,
                                                                                                                    attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
                        }
                    }
                } else {
                    
                    if let coordinate = self.source.coordinate, String(format: "%.5f", coordinate.latitude) == String(format: "%.5f", position.target.latitude), String(format: "%.5f", coordinate.longitude) == String(format: "%.5f", position.target.longitude) {
                        return
                    }
                    
                    placeLocationMarker(marker: self.sourceLocationMarker, coordinate: position.target)
                    GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(position.target.latitude),\(position.target.longitude)") { [weak self] (location) in
                        if let result = location?.results, result.count > 0 {
                            self?.source.address = result[0].formattedAddress
                            self?.routeSelectionView.originSearchBar.text = result[0].formattedAddress
                        }
                    }
                }
            }
        } else if activeSearchBar == self.routeSelectionView.destinationSearchBar {
            
            if let coordinate = self.destination.coordinate, String(format: "%.5f", coordinate.latitude) == String(format: "%.5f", position.target.latitude), String(format: "%.5f", coordinate.longitude) == String(format: "%.5f", position.target.longitude) {
                return
            }
            
            self.destination.coordinate = position.target
            placeLocationMarker(marker: self.destinationLocationMarker, coordinate: position.target)
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(position.target.latitude),\(position.target.longitude)") { [weak self] (location) in
                if let result = location?.results, result.count > 0 {
                    self?.destination.address = result[0].formattedAddress
                    self?.routeSelectionView.destinationSearchBar.text = result[0].formattedAddress
                }
            }
        }
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        
        if activeSearchBar == self.routeSelectionView.originSearchBar {
            self.source.coordinate = location
            if let myLocation = mapView.myLocation {
                if myLocation.coordinate.latitude == location.latitude.round(to: 5) && myLocation.coordinate.longitude == location.longitude.round(to: 5) {
                    placeLocationMarker(marker: self.sourceLocationMarker, coordinate: location)
                    GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(location.latitude),\(location.longitude)") { [weak self] (location) in
                        if let result = location?.results, result.count > 0 {
                            self?.source.address = result[0].formattedAddress
                            self?.routeSelectionView.originSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation.localized,
                                                                                                                    attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
                        }
                    }
                } else {
                    placeLocationMarker(marker: self.sourceLocationMarker, coordinate: location)
                    GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(location.latitude),\(location.longitude)") { [weak self] (location) in
                        if let result = location?.results, result.count > 0 {
                            self?.source.address = result[0].formattedAddress
                            self?.routeSelectionView.originSearchBar.text = result[0].formattedAddress
                        }
                    }
                }
            } else {
                placeLocationMarker(marker: self.sourceLocationMarker, coordinate: location)
                GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(location.latitude),\(location.longitude)") { [weak self] (location) in
                    if let result = location?.results, result.count > 0 {
                        self?.source.address = result[0].formattedAddress
                        self?.routeSelectionView.originSearchBar.text = result[0].formattedAddress
                    }
                }
            }
        } else if activeSearchBar == self.routeSelectionView.destinationSearchBar {
            self.destination.coordinate = location
            placeLocationMarker(marker: self.destinationLocationMarker, coordinate: location)
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(location.latitude),\(location.longitude)") { [weak self] (location) in
                if let result = location?.results, result.count > 0 {
                    self?.destination.address = result[0].formattedAddress
                    self?.routeSelectionView.destinationSearchBar.text = result[0].formattedAddress
                }
            }
        }
        
    }

}

extension LocationSelectionUsingMapViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.activeSearchBar = searchBar
        return false
    }
}

extension LocationSelectionUsingMapViewController: RouteSelectionViewDelegate {
    
    func didSelectLeaveArriveButton() {
        // Do Something
    }
    
    func buttonHomeWorkFavPressed(placeType: PlaceType) {
        
        if placeType == .favorite {
            let viewController: FavoritesViewController = FavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
            viewController.placeType = placeType
            viewController.travelPreferenceModel = self.travelPreferenceModal
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            switch placeType {
            case .home:
                let homeData = HomeLocationsDataRepository.shared.fetchAll()
                if let homeData = homeData, homeData.count > 0 {
                    setLocationValueToOriginDestination(savedLocation: homeData[0])
                } else {
                    redirectToHomeWorkScreen(placeType: placeType)
                }
            case .work:
                let workData = WorkLocationsDataRepository.shared.fetchAll()
                if let workData = workData, workData.count > 0 {
                    setLocationValueToOriginDestination(savedLocation: workData[0])
                } else {
                    redirectToHomeWorkScreen(placeType: placeType)
                }
            default:
                break
            }
        }
    }
    
    func redirectToHomeWorkScreen(placeType: PlaceType) {
        let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
        viewController.placeType = placeType
        viewController.travelPreferenceModel = self.travelPreferenceModal
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setLocationValueToOriginDestination(savedLocation: SavedLocation) {
        
        guard let activeSearchBar = activeSearchBar else {
            return
        }
        
        if let latitude = savedLocation.latitude, let longitude = savedLocation.longitude {
            if activeSearchBar == routeSelectionView.originSearchBar {
                
                self.source = LocationData(id: savedLocation.id, address: savedLocation.location, subAddress: savedLocation.address, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), type: savedLocation.type ?? emptyString == Constants.stop ? .stop: .coordinate)
                
                if let latitude = savedLocation.latitude, let longitude = savedLocation.longitude {
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    placeLocationMarker(marker: self.sourceLocationMarker, coordinate: coordinate)
                    let camera = GMSCameraPosition(target: coordinate, zoom: Constants.mapViewZoomLevel)
                    self.mapView.camera = camera
                }
                
                routeSelectionView.originSearchBar.text = self.source.address ?? self.source.subAddress ?? ""
                
            } else {
                
                destination = LocationData(id: savedLocation.id, address: savedLocation.location, subAddress: savedLocation.address, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), type: savedLocation.type ?? emptyString == Constants.stop ? .stop: .coordinate)
                
                if let latitude = savedLocation.latitude, let longitude = savedLocation.longitude {
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    placeLocationMarker(marker: self.destinationLocationMarker, coordinate: coordinate)
                    let camera = GMSCameraPosition(target: coordinate, zoom: Constants.mapViewZoomLevel)
                    self.mapView.camera = camera
                }
                
                routeSelectionView.destinationSearchBar.text = savedLocation.location ?? savedLocation.address ?? ""
                
            }
        }
    }
    
    func addToFavButtonTapped() {
        let travelPreferenceViewController: TravelPreferenceViewController = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        travelPreferenceViewController.delegate = self
        travelPreferenceViewController.travelPreferenceModel = self.travelPreferenceModal
        travelPreferenceViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(travelPreferenceViewController, animated: true)
    }
    

    func didTapButton(tag: Int) {
        switch tag {
        case 0:
            swapLocationData()
        default:
            return
        }
    }

    func swapLocationData() {

        if source.coordinate != nil, destination.coordinate != nil {
            (source, destination) = (destination, source)
        }
    }

    func enableShadowView() {

        shadowView.backgroundColor = Colors.shadowGray
        shadowView.frame = self.view.frame
        self.view.addSubview(shadowView)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        shadowView.addGestureRecognizer(tapGesture)
    }

    func hidePicker() {

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.shadowView.removeFromSuperview()
            }
        }
    }

    func didSelect(preferences: SearchPreference) {
        // Do Something
    }
}

extension LocationSelectionUsingMapViewController: ProceedButtonDelegate {

    func didTapProceed() {
        if self.routeSelectionView.originSearchBar.text == self.routeSelectionView.destinationSearchBar.text {
            self.showCustomAlert(alertTitle: "", alertMessage: Constants.sameSourceDestinationMessage.localized, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: nil, secondActionHandler: nil)
        } else {
            performNavigationToAvailableTrips()
        }
    }

    private func performNavigationToAvailableTrips() {
        let availableRoutesViewController: AvailableRoutesViewController = AvailableRoutesViewController.instantiate(appStoryboard: .availableRoutes)
        self.source.type = .coordinate
        self.destination.type = .coordinate
        routeSelectionViewData?.originSearchText = routeSelectionView.originSearchBar.text
        routeSelectionViewData?.destinationSearchText = routeSelectionView.destinationSearchBar.text
        let availableRoutesViewModel = AvailableRoutesViewModel()
        availableRoutesViewController.initialize(with: availableRoutesViewModel, origin: self.source, destination: self.destination, travelPreference: self.travelPreferenceModal)
        availableRoutesViewController.selectedSearchPreferences = self.searchPreferences
        self.navigationController?.pushViewController(availableRoutesViewController, animated: true)
    }
}

extension LocationSelectionUsingMapViewController: MarkerDelegate, UITableViewDataSource, UITableViewDelegate {

    func addLocation() {
        guard self.selectedLocation != nil else { return }
        infoWindow?.removeFromSuperview()
        selectionTableView.removeFromSuperview()
        selectionTableView.register(FavoriteSelectionTableViewCell.nib, forCellReuseIdentifier: FavoriteSelectionTableViewCell.identifier)
        selectionTableView.translatesAutoresizingMaskIntoConstraints = false
        selectionTableView.dataSource = self
        selectionTableView.delegate = self
        selectionTableView.cornerRadius = 10
        selectionTableView.tableFooterView = UIView()
        enableShadowView()
        self.view.addSubview(selectionTableView)
        selectionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        selectionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
        let center = self.view.frame.size.height / 2
        selectionTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: center - 100).isActive = true
        selectionTableView.heightAnchor.constraint(equalToConstant: 195).isActive = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteSelectionTableViewCell.identifier, for: indexPath) as? FavoriteSelectionTableViewCell
        switch indexPath.row {
        case 0:
            cell?.cellImage.image = Images.home
            cell?.selectionLabel.text = "My Home"
        case 1:
            cell?.cellImage.image = Images.work
            cell?.selectionLabel.text = "Work"
        case 2:
            cell?.cellImage.image = Images.favorites
            cell?.selectionLabel.text = "My Favourites"
        default: break
        }
        cell?.selectionImage.image = Images.unchecked
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedLocation = self.selectedLocation else { return }
        let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
        switch indexPath.row {
        case 0:
            viewController.placeType = .home
        case 1:
            viewController.placeType = .work
        case 2:
            viewController.placeType = .favorite
        default:
            break
        }
        viewController.selectedLocation = selectedLocation
        selectionTableView.removeFromSuperview()
        shadowView.removeFromSuperview()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LocationSelectionUsingMapViewController: TravelPreferenceViewControllerDelegate {
    
    func updatedTravelPreferences(modal: TravelPreferenceModel) {
        travelPreferenceModal = modal
    }
    
}

extension LocationSelectionUsingMapViewController: RouteSelectionViewBackButtonDelegate {
    func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GMSMapView {
    
    func addPolygon() {
        guard let paths = Bundle.main.path(forResource: "RiyadhGeoJSON", ofType: "json") else {
            return
        }
        let url = URL(fileURLWithPath: paths)
        let geoJsonParser = GMUGeoJSONParser(url: url)
        geoJsonParser.parse()
        var renderer = GMUGeometryRenderer(map: self, geometries: geoJsonParser.features)
        var style: GMUStyle = GMUStyle()
        for (index, feature) in geoJsonParser.features.enumerated() {
            if index == 0 {
                style = GMUStyle(styleID: "random", stroke: .black, fill: UIColor.black.withAlphaComponent(0.2), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
            } else {
            style = GMUStyle(styleID: "random1", stroke: .black, fill: .clear, width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)

            }
            feature.style = style
        }
        renderer = GMUGeometryRenderer(map: self, geometries: geoJsonParser.features)
        renderer.render()
    }
    
    
    
}
