//
//  LiveTrackerViewController.swift
//  RCRC
//
//  Created by Errol on 08/01/21.
//

import UIKit
import GoogleMaps

class LiveTrackerViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressHeaderLabel: UILabel!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var endTripButton: UIButton!
    @IBOutlet weak var swipeUpIndicator: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mapViewBottomToSafeArea: NSLayoutConstraint!
    @IBOutlet weak var mapViewBottomToBottomView: NSLayoutConstraint!

    var paths = [GMSMutablePath]()
    var legs: [Leg?] = []
    let cellSpacingHeight: CGFloat = 20
    let locationManager = CLLocationManager()
    var speed: CLLocationSpeed = Constants.defaultSpeed
    var currentLeg: Int? {
        didSet {
            updateCellViewModels()
        }
    }
    private var currentLocation: CLLocation? {
        didSet {
            guard let currentLocation = currentLocation else { return }
            let cameraPosition = GMSCameraPosition(latitude: currentLocation.coordinate.latitude,
                                           longitude: currentLocation.coordinate.longitude,
                                           zoom: mapZoomLevel,
                                           bearing: currentLocation.course,
                                           viewingAngle: 60)
            DispatchQueue.main.async {
                self.mapView.animate(to: cameraPosition)
            }
        }
    }
    var cellViewModels: [RouteCellViewModel] = []
    private var viewModel: LiveTrackerViewModel!
    private let marker = GMSMarker()
    private var mapZoomLevel = Constants.mapViewZoomLevel

    private func updateCellViewModels() {
        self.cellViewModels = cellViewModels.enumerated().map { index, _ -> RouteCellViewModel in
            let legs = self.legs.compactMap { $0 }
            let isActive = index == currentLeg
            let cellViewModel: RouteCellViewModel
            if cellViewModels.count > 1 {
                if index == cellViewModels.startIndex {
                    cellViewModel = RouteCellViewModel(originLeg: legs[index], isActive: isActive)
                } else if index == cellViewModels.endIndex - 1 {
                    cellViewModel = RouteCellViewModel(destinationLeg: legs[index], isActive: isActive)
                } else {
                    cellViewModel = RouteCellViewModel(middleLeg: legs[index], isActive: isActive)
                }
            } else {
                cellViewModel = RouteCellViewModel(singleLeg: legs[index], isActive: isActive)
            }
            return cellViewModel
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: "Ongoing Trip".localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .liveTracking)
        viewModel = LiveTrackerViewModel(legs: self.legs.compactMap { $0 })

        configureGesture()
        configureView()
        configureMapStyle()
        initializeMapView()

        DispatchQueue.global(qos: .background).async {
            self.placeTransportModeIcons()
            self.drawRoute()
            self.configureLocationManager()
            self.speed = self.viewModel.calculateSpeed()
        }
        configureTableView()
        updateCellViewModels()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.simulateNavigation()
        }
    }
    @IBAction func zoomTapped(_ sender: UIButton) {
        mapZoomLevel += Float(sender.tag)
        mapView.animate(toZoom: mapZoomLevel)
    }

    private func configureTableView() {
        self.registerCellXibs()
        let view = UIView()
        view.backgroundColor = Colors.backgroundGray
        self.tableView.tableFooterView = view
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    private func configureView() {
        bottomView.layer.shadowColor = UIColor.gray.cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.destinationAddress.text = legs.last??.destination?.disassembledName ?? legs.last??.destination?.name ?? legs.last??.destination?.parent?.name
        self.etaLabel.text = "Estimated Time of Arrival " + viewModel.calculateETA()
        self.mapView.isMyLocationEnabled = true
    }

    private func initializeMapView() {
        guard let originLatitude = legs.compactMap({$0}).first?.coords?.first??.compactMap({$0}).first,
              let originLongitude = legs.compactMap({$0}).first?.coords?.first??.compactMap({$0}).last else { return }

        let camera = GMSCameraPosition(latitude: originLatitude, longitude: originLongitude, zoom: Constants.mapViewZoomLevel)
        self.mapView.animate(to: camera)
        self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        self.mapView.settings.myLocationButton = true
    }

//    func makeGpx() {
//        let coords = legs.compactMap {$0}.map { leg -> [CLLocationCoordinate2D] in
//            let coords = leg.coords?.compactMap {$0}.map { coord -> CLLocationCoordinate2D in
//                let coordinate = coord.compactMap {$0}
//                return CLLocationCoordinate2D(
//                    latitude: coordinate[coordinate.startIndex],
//                    longitude: coordinate[coordinate.endIndex - 1])
//            }
//            return coords!
//        }
//        for i in coords {
//            for j in i {
//                print("<wpt lat=\"\(j.latitude)\" lon=\"\(j.longitude)\"> <name>Ann Arbor</name> </wpt>")
//            }
//        }
//    }

    private func configureMapStyle() {
        do {
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                let mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                DispatchQueue.main.async {
                    self.mapView.mapStyle = mapStyle
                }
            }
        } catch {
            print("Failed to set map style")
        }
    }

    func configureGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.bottomView.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.bottomView.addGestureRecognizer(swipeDown)
    }

    func configureLocationManager() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    /// Gesture callback for swippable bottom view
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.bottomViewHeightConstraint.constant = 150
                        self.mapViewBottomToSafeArea.priority = UILayoutPriority(rawValue: 999)
                        self.mapViewBottomToBottomView.priority = UILayoutPriority(rawValue: 750)
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    }
                    self.endTripButton.isHidden = false
                    self.swipeUpIndicator.isHidden = false
                }
            case UISwipeGestureRecognizer.Direction.up:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.bottomViewHeightConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.height / 2
                        self.mapViewBottomToSafeArea.priority = UILayoutPriority(rawValue: 750)
                        self.mapViewBottomToBottomView.priority = UILayoutPriority(rawValue: 999)
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    }
                    self.endTripButton.isHidden = true
                    self.swipeUpIndicator.isHidden = true
                }
            default:
                break
            }
        }
    }

    func registerCellXibs() {
        self.tableView.register(RouteTableViewCell.nib, forCellReuseIdentifier: RouteTableViewCell.identifier)
        tableView.register(ButtonTableViewCell.nib, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    }

    private func drawRoute() {
        let routePath = viewModel.getRoutePath()
        self.paths = routePath.map { $0.path }
        routePath.forEach { route in
            DispatchQueue.main.async {
                self.mapView.drawRoute(with: route.path, color: route.color, isFootPath: route.type)
            }
        }
    }

    private func placeTransportModeIcons() {
        let icons = viewModel.getTransportModeImages()
        icons.forEach { icon in
            DispatchQueue.main.async {
                self.mapView.addMarkerOn(location: icon.coordinate, markerImage: icon.image, imageOffset: icon.offset)
            }
        }
    }

    @IBAction func endTripTapped(_ sender: UIButton) {
        self.locationManager.stopUpdatingLocation()
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension LiveTrackerViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == cellViewModels.count {
            let cell: ButtonTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.button.setTitle("End Trip".localized, for: .normal)
            cell.buttonTapped = endTripTapped
            return cell
        } else {
            let cell: RouteTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
            if let cellViewModel = cellViewModels[safe: indexPath.row] {
                cell.configure(with: cellViewModel)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        5
    }
}

extension LiveTrackerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        for (index, path) in paths.enumerated() {
            if self.mapView.isLocationOnPath(point: currentLocation.coordinate, path: path) {
                currentLeg = index
                self.currentLocation = currentLocation
            }
        }
        
        //self.simulateLocationOnRealDevice(currentLocation: currentLocation)
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.trueHeading
        marker.rotation = heading
    }
    
    func simulateLocationOnRealDevice(currentLocation: CLLocation){
        
        let markerImage = Images.currentLocation?
            .rotate(radians: -0.785398)
            .scaled(to: CGSize(width: 45.0, height: 55.0))
            .maskWithColor(color: .black)
        marker.icon = markerImage
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        
        let coords = legs.compactMap {$0}.map { leg -> [CLLocationCoordinate2D] in
            let coords = leg.coords?.compactMap {$0}.map { coord -> CLLocationCoordinate2D in
                let coordinate = coord.compactMap {$0}
                return CLLocationCoordinate2D(
                    latitude: coordinate[coordinate.startIndex],
                    longitude: coordinate[coordinate.endIndex - 1])
            }
            return coords ?? []
        }.flatMap { $0 }
        
        if currentLocation.speed > 0 {
            speed = currentLocation.speed
        }
        
        let closestCoordinates = coords.min(by:
                                                { $0.distance(to: currentLocation.coordinate) < $1.distance(to: currentLocation.coordinate) })
        var nextCoordinate: CLLocationCoordinate2D = currentLocation.coordinate
        if let index = coords.firstIndex(where: {$0.longitude == closestCoordinates?.longitude && $0.latitude == closestCoordinates?.latitude}) {
            nextCoordinate = coords[index + 1]
        }
        
        let heading = calculateHeading(currentCoordinate: currentLocation.coordinate, nextCoordinate: nextCoordinate)
        let location = CLLocation(coordinate: currentLocation.coordinate,
                                  altitude: 100,
                                  horizontalAccuracy: 10,
                                  verticalAccuracy: 10,
                                  course: heading,
                                  speed: self.speed,
                                  timestamp: Date())
        self.marker.position = location.coordinate
        
    }
    
    func calculateHeading(currentCoordinate: CLLocationCoordinate2D, nextCoordinate: CLLocationCoordinate2D) -> CLLocationDegrees {
        let deltaL = nextCoordinate.longitude - currentCoordinate.longitude
        let x = cos(nextCoordinate.latitude) * sin(deltaL)
        let y = (cos(currentCoordinate.latitude) * sin(nextCoordinate.latitude)) - (sin(currentCoordinate.latitude) * cos(nextCoordinate.latitude) * cos(deltaL))
        let bearingRadians = atan2(x, y)
        let bearingDegrees = bearingRadians * 180 / Double.pi
        return CLLocationDegrees(bearingDegrees)
    }
    
}

extension UIImage {
    func rotate(radians: Float) -> UIImage {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }

    func maskWithColor(color: UIColor) -> UIImage {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return UIImage()
        }
    }
}

extension LiveTrackerViewController {
    private func simulateNavigation() {
        #if DEBUG
        let markerImage = Images.currentLocation?
            .rotate(radians: -0.785398)
            .scaled(to: CGSize(width: 45.0, height: 55.0))
            .maskWithColor(color: .black)
        marker.icon = markerImage
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        let coords = legs.compactMap {$0}.map { leg -> [CLLocationCoordinate2D] in
            let coords = leg.coords?.compactMap {$0}.map { coord -> CLLocationCoordinate2D in
                let coordinate = coord.compactMap {$0}
                return CLLocationCoordinate2D(
                    latitude: coordinate[coordinate.startIndex],
                    longitude: coordinate[coordinate.endIndex - 1])
            }
            return coords ?? []
        }.flatMap { $0 }

        var index = 0
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] t in
            guard let self = self else { return }
            if index == coords.count - 2 {
                t.invalidate()
            } else {
                let heading = calculateHeading(currentCoordinate: coords[index], nextCoordinate: coords[index + 1])
                let location = CLLocation(coordinate: coords[index],
                                          altitude: 100,
                                          horizontalAccuracy: 10,
                                          verticalAccuracy: 10,
                                          course: heading,
                                          speed: self.speed,
                                          timestamp: Date())
                self.marker.position = location.coordinate
                self.locationManager(self.locationManager, didUpdateLocations: [location])
            }
            index += 1
        }

        func calculateHeading(currentCoordinate: CLLocationCoordinate2D, nextCoordinate: CLLocationCoordinate2D) -> CLLocationDegrees {
            let deltaL = nextCoordinate.longitude - currentCoordinate.longitude
            let x = cos(nextCoordinate.latitude) * sin(deltaL)
            let y = (cos(currentCoordinate.latitude) * sin(nextCoordinate.latitude)) - (sin(currentCoordinate.latitude) * cos(nextCoordinate.latitude) * cos(deltaL))
            let bearingRadians = atan2(x, y)
            let bearingDegrees = bearingRadians * 180 / Double.pi
            return CLLocationDegrees(bearingDegrees)
        }

        func delay(_ delay: Double, completion: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: completion)
        }
        #endif
    }
}
