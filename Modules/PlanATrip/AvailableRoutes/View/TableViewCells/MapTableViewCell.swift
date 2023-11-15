//
//  MapTableViewCell.swift
//  DynamicRouteview
//
//  Created by anand madhav on 15/07/20.
//  Copyright © 2020 anand madhav. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapTableViewCellDelegate: AnyObject {
    func infoButtonClicked(cell: UITableViewCell, fare: Fare?)
}

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var routeMap: GMSMapView!
    @IBOutlet weak var selectButton: UIButton?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var totalFareLabel: UILabel?
    @IBOutlet weak var buttonBuy: UIButton?
    @IBOutlet weak var borderView: UIView!
    
    private var legs: [Leg?] = []
    weak var delegate: MapTableViewCellDelegate?
    private var infoWindow = MapInfoWindow()
    private var paths = [GMSMutablePath]()
    private var locationMarker: GMSMarker? = GMSMarker()
    private var locationManager: CLLocationManager?
    private var journey: Journey? {
        didSet {
            if let legs = journey?.legs {
                self.legs = legs
            }
        }
    }
    var shareTapped: (([String: Any]) -> Void)?
    var selectTapped: ((Journey) -> Void)?
    var buttonBuyTapped: (() -> Void)?
    private var viewModel: MapCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    private func configureView() {
        /*
        //self.contentView.layer.addBorder(edge: .left, color: Colors.rptGreen, thickness: 0.5)
        //self.contentView.layer.addBorder(edge: .right, color: Colors.rptGreen, thickness: 0.5)
        //self.contentView.layer.addBorder(edge: .top, color: Colors.rptGreen, thickness: 0.5)
        
//        self.contentView.clipsToBounds = true
//        self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        self.contentView.layer.cornerRadius = 20.0
        //self.contentView.layer.masksToBounds = false

        //self.borderView.clipsToBounds = true
        //self.borderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        //self.borderView.layer.cornerRadius = 20.0

        let topBorder = CALayer()
        topBorder.backgroundColor = Colors.rptGreen.cgColor
        topBorder.borderWidth = 1.0
        topBorder.borderColor = Colors.rptGreen.cgColor
        topBorder.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        topBorder.cornerRadius = 20.0
        topBorder.frame = CGRect(x: 0, y: 0, width: frame.width - /*49.0*/ 71.0, height: 1.0)
        //layer.addSublayer(topBorder)
        
        let addBorderLeft = CALayer()
        addBorderLeft.backgroundColor = Colors.rptGreen.cgColor
        addBorderLeft.borderWidth = 1.0
        addBorderLeft.borderColor = Colors.rptGreen.cgColor
        addBorderLeft.frame = CGRect(x: 0, y: 0, width: 1.0, height: frame.height + 25)
         //addBorderLeft.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addBorderLeft.cornerRadius = 20.0
       // layer.addSublayer(addBorderLeft)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 20, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: 20),
                          controlPoint: CGPoint(x: 0, y: 0))

        //Shape part - Top Left
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.lineWidth = 1.0
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = Colors.rptGreen.cgColor
        //layer.addSublayer(shape)
        
        let addBorderRight = CALayer()
        addBorderRight.backgroundColor = Colors.rptGreen.cgColor
        addBorderRight.borderWidth = 1.0
        addBorderRight.borderColor = Colors.rptGreen.cgColor
        addBorderRight.frame = CGRect(x: /*UIScreen.main.bounds.size.width - 31*/frame.width - 51, y: 10, width: 1.0, height: frame.height - 10.0)
         //topBorder.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addBorderLeft.cornerRadius = 20.0
        //layer.addSublayer(addBorderRight)
        
        let topRightPath = UIBezierPath()
        topRightPath.move(to: CGPoint(x: /*UIScreen.main.bounds.size.width - 51*/ frame.width - 51, y: 0))
        topRightPath.addQuadCurve(to: CGPoint(x: /*UIScreen.main.bounds.size.width - 31*/frame.width - 31, y: 20),
                          controlPoint: CGPoint(x: routeMap.frame.width - 19, y: 0))
        
        //Shape part - Top Right
        let topRightShape = CAShapeLayer()
        topRightShape.path = topRightPath.cgPath
        topRightShape.lineWidth = 1.0
        topRightShape.fillColor = UIColor.clear.cgColor
        topRightShape.strokeColor = Colors.rptGreen.cgColor
        //layer.addSublayer(topRightShape)
        */
        self.contentView.uperTwoCornerMask(radius: 10)
        self.contentView.layer.addBorder(edge: .top, color: Colors.rptGreen, thickness: 1.0)
        self.contentView.layer.addBorder(edge: .left, color: Colors.rptGreen, thickness: 1)
        self.contentView.layer.addBorder(edge: .right, color: Colors.rptGreen, thickness: 1)
        selectButton?.isHidden = true
        routeMap.clear()
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        routeMap.delegate = self
        routeMap.isMyLocationEnabled = true
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                routeMap?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        routeMap.settings.scrollGestures = true
       // buttonBuy?.isHidden = !AppDefaults.shared.isUserLoggedIn
        buttonBuy?.isHidden = true
        buttonBuy?.setTitle(Constants.ticket.localized, for: .normal)
        self.selectionStyle = .none
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    func configure(with viewModel: MapCellViewModel) {
        self.viewModel = viewModel
        self.routeMap.clear()
        self.journey = viewModel.journey
        self.timeLabel?.text = viewModel.travelTime
        self.totalFareLabel?.text = viewModel.travelCost
       
        //self.buttonBuy?.isHidden = !viewModel.isBuyOptionAvailable
        self.buttonBuy?.isHidden = true
        placeLocationMarkers()
        //drawRoute()
        setMapBounds()
    }

    private var isRouteValid: Bool {
        return (viewModel.routeMarkers?.count == viewModel.routeMarkerCoordinates.count) &&
            (viewModel.routePaths?.count == viewModel.routePathConfigurations.count)
    }

    private func placeLocationMarkers() {
        /*
        if viewModel.routeMarkers?.count == viewModel.routeMarkerCoordinates.count {
            viewModel.routeMarkers?.enumerated().forEach { index, marker in
                self.routeMap.addMarkerOn(
                    location: viewModel.routeMarkerCoordinates[index],
                    markerImage: marker.image,
                    imageOffset: marker.offset)
            }
        }
         */
        
         /*
        viewModel.stopsSequenceMarkers?.enumerated().forEach { index, marker in
            self.routeMap.addMarkerOn(
                location: viewModel.stopMarkerCoordinates[index].coordinate,
                markerImage: marker.image,
                imageOffset: marker.offset)
        }
         */
        
        //self.routeMap.addMarkerOn(location: viewModel.originMarker.coordinate, markerImage: viewModel.originMarker.image)
        //self.routeMap.addMarkerOn(location: viewModel.destinationMarker.coordinate, markerImage: viewModel.destinationMarker.image)
        
    }

    func addMarker(locationData:LocationData)  {
        let markerView = Bundle.loadView(fromNib: "MarkerView", withType: MarkerView.self)
        
        //markerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let marker = GMSMarker()
        marker.position = locationData.coordinate!
        markerView.labelTime.text = locationData.subAddress
        markerView.labelTime.backgroundColor = .black
        markerView.labelTime.textColor = .white
        markerView.labelTime.font = Fonts.CodecBold.eight
        markerView.markerImage.image = Images.homeBusStopPin
        markerView.labelTime.setCorner(radius: 4)
        marker.map = routeMap
        marker.iconView = markerView
        
        
    }
    private func drawRoute() {
        if viewModel.routePaths?.count == viewModel.routePathConfigurations.count {
            viewModel.routePaths?.enumerated().forEach { index, path in
                self.routeMap.drawRoute(
                    with: path,
                    color: viewModel.routePathConfigurations[index].color,
                    isFootPath: viewModel.routePathConfigurations[index].isDotted)
            }
        }
    }

    private func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: viewModel.routePath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        DispatchQueue.main.async {
            self.routeMap.animate(with: update)
        }
    }

    @IBAction func infoButtonTapped(_ sender: Any) {
        delegate?.infoButtonClicked(cell: self, fare: viewModel.fare)
    }

    @IBAction func selectButtonTapped(_ sender: Any) {
        guard let journey = self.journey else { return }
        selectTapped?(journey)
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        shareContentWhenButtonTapped()
        /*
        let image = self.routeMap.takeScreenshot()
        let legCount = self.legs.count
        guard let origin = self.legs[0]?.origin?.name, let destination = self.legs[legCount - 1]?.destination?.name else { return }
        var stops: String = ""
        for leg in 0..<legCount {
            if leg == legCount - 1 {
                stops.append("Stop \(leg + 1): \(self.legs[leg]?.origin?.name ?? emptyString)\n")
                stops.append("Stop \(leg + 2): \(self.legs[leg]?.destination?.name ?? emptyString)\n")
            } else {
                stops.append("Stop \(leg + 1): \(self.legs[leg]?.origin?.name ?? emptyString)\n")
            }
        }
        let route = "Origin: \(origin)\nDestination: \(destination)\nDuration: \(calculateTimeTaken(legs))\n\(stops)"
        let data: [String: Any] = ["map": image, "route": route]

        shareTapped?(data)
         */
    }
    
    private func shareContentWhenButtonTapped() {
        let image = self.routeMap.takeScreenshot()
        let legCount = self.legs.count
        
        if legCount < 1 {
            return
        }
        
        var messageToShare: String = ""
        for (index, leg)  in legs.enumerated() {
            if let leg = leg {
                switch leg.transportation.product.name {
                case .FootPath, .footpath, .arabFootpath:
                    if index == 0 {
                        var planTime = leg.origin?.departureTimePlanned?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString
                        planTime = planTime == emptyString ? "": "\(planTime) "
                        var messageWithTowards = leg.origin?.disassembledName ?? leg.origin?.name ?? emptyString
                        messageWithTowards = messageWithTowards == emptyString ? "": "\(Constants.towards.localized) \(messageWithTowards)"
                        messageToShare += "\(planTime)\(messageWithTowards)\n"
                        
                    } else if index == legs.count - 1 {
                        var estTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString
                        estTime = estTime == emptyString ? "": "\(estTime) "
                        var messageWithTowards = leg.origin?.disassembledName ?? leg.origin?.name ?? emptyString
                        messageWithTowards = messageWithTowards == emptyString ? "": "\(Constants.getOff.localized) \(messageWithTowards)"
                        messageToShare += "\(estTime)\(messageWithTowards)\n"
                        
                    } else {
                        var planTime = leg.origin?.departureTimePlanned?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString
                        planTime = planTime == emptyString ? "": "\(planTime) "
                        var messageWithTowards = leg.origin?.disassembledName ?? leg.origin?.name ?? emptyString
                        messageWithTowards = messageWithTowards == emptyString ? "": "\(Constants.getOff.localized) \(messageWithTowards)"
                        messageToShare += "\(planTime)\(messageWithTowards)\n"
                    }
                case .BUS, .bus, .arabBus :
                    /// **** Commented because need to remove last station
                    /*
                    if index == legCount - 1 {
                        
                        var estTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString
                        estTime = estTime == emptyString ? "": "\(estTime) "
                        var messageWithTowards = leg.transportation.destination?.name ?? emptyString
                        messageWithTowards = messageWithTowards == emptyString ? "": "\(Constants.towards.localized) \(messageWithTowards)"
                        let locationName = "\(leg.origin?.disassembledName ?? leg.origin?.name ?? emptyString) \(leg.transportation.name ?? "") "
                        messageToShare += "\(estTime)\(locationName)\(messageWithTowards)\n"
                        
                        var estFinalTime = leg.destination?.arrivalTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString
                        estFinalTime = estFinalTime == emptyString ? "": "\(estFinalTime) "
                        var messageWithGetOff = leg.destination?.disassembledName ?? leg.destination?.name ?? emptyString
                        messageWithGetOff = messageWithGetOff == emptyString ? "": "\(Constants.getOff.localized) \(messageWithGetOff)"
                        messageToShare += "\(estFinalTime)\(messageWithGetOff)\n"
                        
                    } else {
                    */
                        var estTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString
                        estTime = estTime == emptyString ? "": "\(estTime) "
                        var messageWithTowards = leg.transportation.destination?.name ?? emptyString
                        messageWithTowards = messageWithTowards == emptyString ? "": "\(Constants.towards.localized) \(messageWithTowards)"
                        let locationName = "\(leg.origin?.disassembledName ?? leg.origin?.name ?? emptyString) \(leg.transportation.name ?? "") "
                        messageToShare += "\(estTime)\(locationName)\(messageWithTowards)\n"
                  //  }
                default:
                    break
                }
            }
        }
        
        let data: [String: Any] = ["map": image, "route": messageToShare]

        shareTapped?(data)
    }
    
    
    @IBAction func buttonBuyTapped(_ sender: UIButton) {
        buttonBuyTapped?()
    }
    
    private func calculateTimeTaken(_ data: [Leg?]) -> String {
        let timeTaken = data.compactMap {$0}.reduce(0, { $0 + ($1.duration?.minutes ?? 0) })
        return "\(timeTaken) Min"
    }

    @objc func updateLocation() {
        LocationManager.SharedInstance.startUpdatingLocation()
        LocationManager.SharedInstance.updateCurrentLocation = { [weak self] location in
            if let self = self {
                for (index, path) in self.paths.enumerated() {
                    if self.routeMap.isLocationOnPath(point: location?.coordinate, path: path) {
                        print("current location at Index \(index)")
                    } else {
                        print("Location not found")
                    }
                }
            }
        }
    }
}

extension MapTableViewCell: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        // Needed to create the custom info window
        /*
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.tag = 1001
        infoWindow.addButton.translatesAutoresizingMaskIntoConstraints = false
        infoWindow.buttonWidthConstraint.constant = 0
        infoWindow.buttonLeadingConstraint.constant = 0
        infoWindow.buttonTrailingConstraint.constant = 0
        
        self.contentView.addSubview(infoWindow)
        if let stopSequenceWithCoord = viewModel.stopMarkerCoordinates.first(where: {$0.stopSequence.coord?.first == marker.position.latitude && $0.stopSequence.coord?.last == marker.position.longitude}) {
            self.infoWindow.addressLabel.text = stopSequenceWithCoord.stopSequence.name ?? emptyString
            self.infoWindow.addButton.isHidden = true
        } else {
            for view in self.contentView.subviews {
                if view.tag == 1001 {
                    view.removeFromSuperview()
                }
            }
        }
        */
        return false
    }

    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if locationMarker != nil {
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.frame = CGRect(x: infoWindow.frame.origin.x, y: infoWindow.frame.origin.y - 30, width: infoWindow.frame.size.width, height: infoWindow.frame.size.height)

        }
    }

    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }

    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }

    // MARK: Needed to create the custom info window (this is optional)
    func sizeForOffset(view: UIView) -> CGFloat {
        return  135.0
    }

    // MARK: Needed to create the custom info window (this is optional)
    func loadNiB() -> MapInfoWindow {
        let infoWindow = MapInfoWindow.instanceFromNib()
        return infoWindow
    }
}
