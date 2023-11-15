//
//  EventDetailViewController.swift
//  RCRC
//
//  Created by Errol on 24/06/21.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
class EventDetailViewController: UIViewController {

    @IBOutlet weak var bottomOverlay: UIView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventDistance: UILabel!
    @IBOutlet weak var eventDuration: UILabel!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var eventFee: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    private var viewModel: EventCellViewModel?
    private var mapZoomLevel = Constants.mapViewZoomLevel
    private var gmsMapView: GMSMapView = GMSMapView()
    private let locationMarker = GMSMarker()

    convenience init(viewModel: EventCellViewModel) {
        self.init(nibName: "EventDetailViewController", bundle: nil)
        self.viewModel = viewModel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(title: viewModel?.eventType.rawValue.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .eventDetails)
        bottomOverlay.layer.shadowColor = UIColor.gray.cgColor
        bottomOverlay.layer.shadowOpacity = 0.5

        eventName.text = viewModel?.name
        eventAddress.text = viewModel?.address
        eventDistance.text = "Apprx. " + (viewModel?.distance ?? "0.0 Km")
        eventDuration.attributedText = viewModel?.duration
        let entryFeeText = viewModel?.entryCost
        let entryFeeAttributedText = Utilities.shared.getAttributedText(firstString: "Entry Fee ",
                                                                        secondString: entryFeeText,
                                                                        firstFont: (Fonts.RptaSignage.sixteen!, Colors.textGray),
                                                                        secondFont: (Fonts.RptaSignage.eighteen!, .black))
        eventFee.attributedText = entryFeeAttributedText
        eventDescription.text = viewModel?.description

        let eventCoordinate: CLLocationCoordinate2D
        if let latitude = viewModel?.coordinate?.latitude,
           let longitude = viewModel?.coordinate?.longitude {
            eventCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            eventCoordinate = Constants.locationWhenUnavailable
        }
        let cameraPosition = GMSCameraPosition(latitude: eventCoordinate.latitude, longitude: eventCoordinate.longitude, zoom: Constants.mapViewZoomLevel)
        gmsMapView = GMSMapView(frame: mapView.bounds, camera: cameraPosition)
        gmsMapView.isMyLocationEnabled = true
        gmsMapView.settings.myLocationButton = true
        mapView.addSubview(gmsMapView)
        mapView.sendSubviewToBack(gmsMapView)
        gmsMapView.pinEdgesToSuperView()
        gmsMapView.addMarkerOn(location: eventCoordinate, markerImage: Images.events!)
        addPolygon()
    }

    private func addPolygon() {
        guard let paths = Bundle.main.path(forResource: Constants.geoJsonFileName, ofType: Constants.jsonType) else {
            return
        }
        let url = URL(fileURLWithPath: paths)
        let geoJsonParser = GMUGeoJSONParser(url: url)
        geoJsonParser.parse()
        var renderer = GMUGeometryRenderer(map: gmsMapView, geometries: geoJsonParser.features)
        var style: GMUStyle = GMUStyle()
        for (index, feature) in geoJsonParser.features.enumerated() {
            if index == 0 {
                style = GMUStyle(styleID: Constants.random, stroke: .black, fill: UIColor.black.withAlphaComponent(Constants.polygonaAlphaComponent), width: Constants.polygonBorderWidth, scale: Constants.polygonScale, heading: Constants.polygonZeroCoordinate, anchor: CGPoint(x: Constants.polygonZeroCoordinate, y: Constants.polygonZeroCoordinate), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
            } else {
                style = GMUStyle(styleID: Constants.randomOne, stroke: .black, fill: .clear, width: Constants.polygonBorderWidth, scale: Constants.polygonScale, heading: Constants.polygonZeroCoordinate, anchor: CGPoint(x: Constants.polygonZeroCoordinate, y: Constants.polygonZeroCoordinate), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)

            }
            feature.style = style
        }
        renderer = GMUGeometryRenderer(map: gmsMapView, geometries: geoJsonParser.features)
        renderer.render()
    }

    @IBAction func selectAsOriginTapped(_ sender: UIButton) {
        let location = LocationData(id: nil, address: viewModel?.address, subAddress: viewModel?.address, coordinate: viewModel?.coordinate, type: .coordinate)
        let viewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
        viewController.origin = location
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func selectAsDestinationTapped(_ sender: UIButton) {
        let location = LocationData(id: nil, address: viewModel?.address, subAddress: viewModel?.address, coordinate: viewModel?.coordinate, type: .coordinate)
        let viewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
        viewController.destination = location
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func zoomTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            mapZoomLevel += 1
        } else {
            mapZoomLevel -= 1
        }
        gmsMapView.animate(toZoom: mapZoomLevel)
    }
}
