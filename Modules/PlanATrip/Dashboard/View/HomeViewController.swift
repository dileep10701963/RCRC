//
//  HomeViewController.swift
//  RCRC
//
//  Created by anand madhav on 10/06/20.
//  Copyright © 2020 Riyadh Journey Planner. All rights reserved.
//

import UIKit
import MapKit
import Lottie
import GoogleMaps
import Alamofire
import GooglePlaces
import GoogleMapsUtils


class HomeViewController: ContentViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var viewBGMainTrackList: UIView!
    @IBOutlet weak var labelBusTracker: UILabel!
    @IBOutlet weak var viewBGTrackList: UIView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var favoritePlacesTableView: UITableView!
    @IBOutlet weak var nearbyStationsLabel: UILabel!
    @IBOutlet weak var bottomSheetHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var slideUpDownView: UIView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var bottomSheetStackView: UIStackView!
    
    @IBOutlet weak var slideDownView: UIView!
    @IBOutlet weak var imageTravelPreferences: UIImageView!
    @IBOutlet weak var labelSelectDestination: UILabel!
    @IBOutlet weak var buttonSelectDestination: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraintTravelPre: NSLayoutConstraint!
    @IBOutlet weak var topHeaderTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topHeaderTitleImageView: UIImageView!
    @IBOutlet weak var topHeaderTitleLeftImage: UIImageView!
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonDropDown: LoadingButton!
    //@IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    //@IBOutlet weak var tableWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelDirectionTo: UILabel!
    @IBOutlet weak var buttonFirstDirection: LoadingButton!
    @IBOutlet weak var buttonDirectionView: UIView!
    @IBOutlet weak var directionView: UIView!
    @IBOutlet weak var directionToView: UIView!
    @IBOutlet weak var buttonDirectionTo: UIButton!
    @IBOutlet weak var buttonSecondDirection: LoadingButton!
    
    @IBOutlet var directionViewConstrantHeight: NSLayoutConstraint!
    
    var timer = Timer()
    
    var filterBusLines: [SelectedRouteModel] = []
    var allBusStatusModel: [LiveBusStatusModel] = []
    var timeTableViewModel = TimeTableViewModel()
    
    var selectedDirection: SelectedDirection = .north
    var routeDirectionModel: RouteDirectionModel? = nil
    
    var drawPolyline: [GMSPolyline] = []
    var travelPreferenceModal: TravelPreferenceModel? = nil
    var travelPreferencesViewModel = TravelPreferencesViewModel()
    var activityIndicator: UIActivityIndicatorView?
    private var favCellImageHeightWithPadding: CGFloat = 67
    private var heightForRow = UITableView.automaticDimension
    private var extraSpacingHeight: CGFloat = 16
    private var headerHeight: CGFloat = 10
    private var routeModel:RouteModel?
    var isBottomSheetExpanded: Bool = false
    var homeViewModel = HomeViewModel()
    var animationView: AnimationView?
    var source = LocationData()
    var destination = LocationData()
    var cellHeight: CGFloat = 44
    var canZoomIn = false
    var selectRoute = Constants.showOnMap.localized
    private var infoWindow: MapInfoWindow?
    private var addressLabelInfoWindow: String?
    private var fromButtonShowOnMapAction: Bool = false
    private var infoTableWindow: MarkerInfoTableView?
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    let screenSize: CGRect = UIScreen.main.bounds
    var bottomSheetCollapsedHeight: CGFloat {
        let firstCell = favoritePlacesTableView.visibleCells.first
        if firstCell == nil && homeViewModel.favoritePlaces.value.count > 0 {
            cellHeight = favCellImageHeightWithPadding
            self.favoritePlacesTableView.beginUpdates()
            heightForRow = cellHeight
            self.favoritePlacesTableView.endUpdates()
        } else {
            cellHeight = favoritePlacesTableView.visibleCells.first?.bounds.size.height ?? 44
        }
        if let firstCell = firstCell, firstCell.isKind(of: FavoritesTableViewCell.self) {
            cellHeight = cellHeight < favCellImageHeightWithPadding ? favCellImageHeightWithPadding: cellHeight
            self.favoritePlacesTableView.beginUpdates()
            heightForRow = cellHeight
            self.favoritePlacesTableView.endUpdates()
        }
        return bottomSheetStackView.bounds.size.height + slideDownView.bounds.size.height + cellHeight + extraSpacingHeight + headerHeight
    }
    var bottomSheetExpandedHeight: CGFloat {
        let maxHeight = self.view.frame.size.height * 0.70
        
        let height = bottomSheetStackView.bounds.size.height + slideDownView.bounds.size.height + favoritePlacesTableView.contentSize.height + extraSpacingHeight
        if height < maxHeight {
            return height
        } else {
            return maxHeight
        }
    }
    private var mapView: GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topHeaderTitleImageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageTravelPreferences.translatesAutoresizingMaskIntoConstraints = false
        
        self.logEvent(screen: .home)
        setUpView()
//        weatherView.layer.cornerRadius = 3
//        self.view.bringSubviewToFront(weatherView)
        self.favoritePlacesTableView.dataSource = self
        self.favoritePlacesTableView.delegate = self
        self.favoritePlacesTableView.register(FavoritesTableViewCell.nib, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
        self.favoritePlacesTableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: EmptyTableViewCell.identifier)
        self.tableView.register(MapBusRouteCell.self)
        initialize()
        setUpBottomView()
        setupRouteListView()
       // self.animationView = Animations.shared.loadingDots(superView: self.weatherView)
        //notificationButton.addTarget(self, action: #selector(notificationTapped(_:)), for: .touchUpInside)
        bottomSheetStackView.arrangedSubviews.forEach { (subview) in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            subview.addGestureRecognizer(tapGesture)
        }
        
        if let mainViewController = self.navigationController?.tabBarController?.parent as? MainViewController {
            mainViewController.delegate = self
        }
        
        self.travelPreferenceModal = TravelPreferenceModel(busTransport: true, maxTime: .fifteenMin, routePreference: .quickest, walkSpeed: .normal)
        
        if #available(iOS 15.0, *) {
            self.favoritePlacesTableView.sectionHeaderTopPadding = 0
        } else {}
        
        topHeaderTitleLeftImage.image = topHeaderTitleLeftImage.image?.setNewImageAsPerLanguage()
        self.selectRoute = Constants.showOnMap.localized
        buttonDropDown.setTitle(Constants.showOnMap.localized, for: .normal)
        buttonDropDown.titleLabel?.font = Fonts.CodecBold.twelve
        buttonDropDown.setTitleColor(Colors.textColor, for: .normal)
        tableView.delegate = self
        tableView.dataSource = self
        // Changed true to false
       // dropDownView.isHidden = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setUpView() {
        //self.weatherView.isHidden = true
        addActionToPreferences()
        setUPDirectionToCorner()
        let destinationAttribute =  NSMutableAttributedString(string: Constants.whereto.localized, attributes: [NSMutableAttributedString.Key.foregroundColor: Colors.textGray, NSMutableAttributedString.Key.font: Fonts.CodecBold.eleven])
        
        buttonSelectDestination.setAttributedTitle(destinationAttribute, for: .normal)
        
       
        buttonSelectDestination.titleLabel?.setAlignment()
        
        buttonDropDown.setTitle(Constants.showOnMap.localized, for: .normal)
       
        buttonDropDown.titleLabel?.font = Fonts.CodecBold.twelve
        buttonDropDown.setTitleColor(Colors.textColor, for: .normal)
        viewBGMainTrackList.backgroundColor = .init(white: 0.5, alpha: 0.0)
        
        buttonDropDown.titleLabel?.setAlignment()
        
//        labelSelectDestination.text = Constants.whereto.localized
//        labelSelectDestination.setAlignment()
        labelBusTracker.text = Constants.showOnMap.localized
        viewBGTrackList.uperTwoCornerMask(radius: 30)
        viewBGMainTrackList.isHidden = true
        
        
    }
    
    func setUPDirectionToCorner()  {
//        if  !buttonDropDown.isSelected {
//            //directionToView.UperTwoCornerMask(radius: 30)
//            //buttonDirectionView.lowerTwoCornerMask(radius: 30)
//            directionView.setCorner(radius: 10)
//            directionView.layer.borderWidth = 1.0
//            directionView.layer.borderColor = UIColor.black.cgColor
//        }else{
//            directionView.layer.cornerRadius = 30
//            directionView.layer.masksToBounds = true
//        }
        //directionView.setCorner(radius: 10)
        //directionView.layer.borderWidth = 1.0
    }
    
    private func addActionToPreferences() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterButtonTapped))
        imageTravelPreferences.isUserInteractionEnabled = true
        imageTravelPreferences.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.configureNavigationBar(title: Constants.planATrip.localized)
        createMap()
        
        // Preferences Button
        imageTravelPreferences.isHidden = !AppDefaults.shared.isUserLoggedIn
        self.setNavigationBarAppearance(isPrimaryColorSet: true)
        configureTopHeaderForTraveelPreferences()
        self.configureTopHeaderForTraveelPreferences()
        self.getBusStopAndSetupStopsOnMap()
        
        self.tabBarController?.tabBar.isHidden = false
        self.filterBusLines = []
        self.getLiveBusStatusFromAPI()
        
        self.labelDirectionTo.text = Constants.directionTo.localized
        self.buttonDirectionTo.setTitle(Constants.directionTo.localized, for: .normal)
        self.hideRouteDirectionView()
        
    }
    
    private func hideRouteDirectionView() {
        self.buttonDirectionView.isHidden = true
        self.labelDirectionTo.isHidden = true
        self.directionView.isHidden = true
        self.buttonFirstDirection.hideLoading()
        self.buttonSecondDirection.hideLoading()
        self.selectedDirection = .north
    }
    
    private func getLiveBusStatusFromAPI() {
        
        var selectedRouteNumber: String = ""
        if let selectedRouteIndex = self.filterBusLines.firstIndex(where: {$0.isSelected == true}) {
            selectedRouteNumber = self.filterBusLines[selectedRouteIndex].routeNumber
        } else {
            self.routeDirectionModel = nil
        }
        
        self.homeViewModel.getLiveStatusOfBus(routeDirectionModel: routeDirectionModel, selectedRoute: selectedRouteNumber) { busCurrentStatus, error in
            DispatchQueue.main.async {
                if let busCurrentStatus = busCurrentStatus, busCurrentStatus.count > 0 {
//                    if self.viewBGMainTrackList.isHidden && self.buttonDropDown.isSelected {
//                        self.showRouteList()
//                    }
                    if let routeDirectionModel = self.routeDirectionModel {
                        //self.buttonFirstDirection.hideLoading()
                        //self.buttonSecondDirection.hideLoading()
                    
                        let sourceStopirection:String = self.selectedDirection == .north ? routeDirectionModel.northDirection : routeDirectionModel.southDirection
                        //self.buttonFirstDirection.setTitle(sourceStopirection, for: .normal)

                        let destinationStopirection:String = self.selectedDirection == .north ? routeDirectionModel.southDirection : routeDirectionModel.northDirection

                       // self.buttonSecondDirection.setTitle(destinationStopirection, for: .normal)
                        
                    }
                    
                    self.allBusStatusModel = busCurrentStatus
                    self.setupBusLineFilter(currentStatus: busCurrentStatus)
                    var buttonText = self.buttonDropDown.titleLabel?.text ?? ""
                    print("buttonText1: \(buttonText)")
                    print("selectRoutesss1: \(self.selectRoute)")
                    
                    if currentLanguage == .english && buttonText.isArabic {
                        buttonText = Constants.showOnMap.localized
                    }
                    print("buttonText1: \(buttonText)")
                    print("selectRoutesss1: \(self.selectRoute)")
                    
                    if !self.directionView.isHidden  || buttonText != Constants.showOnMap.localized {
                        self.setBusCurrentStatusOnMap(currentStatus: self.allBusStatusModel)
                    }
                }
            }
        }
    }
    
    private func setupBusLineFilter(currentStatus: [LiveBusStatusModel]) {
        
        var busPoint: [String] = currentStatus.compactMap({$0.lineText ?? ""})
        busPoint = Array(Set(busPoint))
        var filteredRoute: [String] = []
        if #available(iOS 15.0, *) {
            filteredRoute = busPoint.sorted(using: .localizedStandard)
        } else {
            filteredRoute = busPoint.sorted(by: {$0 < $1})
        }
        
        if filterBusLines.count > 1 {
            // Do Something
        } else {
            
            filteredRoute.forEach { filterRoute in
                let model = SelectedRouteModel(routeNumber: filterRoute, isSelected: false)
                filterBusLines.append(model)
            }
        }
        
        
        self.tableView.reloadData()
       // self.dropDownView.isHidden = false
        
    }
    
    private func setBusCurrentStatusOnMap(currentStatus: [LiveBusStatusModel]) {
        
        let buttonText = self.buttonDropDown.titleLabel?.text ?? ""
        print("selectRoutesss: \(self.selectRoute)")
        print("buttonText: \(buttonText)")
        
        if self.viewBGMainTrackList.isHidden && self.selectRoute.localized == Constants.showOnMap.localized {
            for index in 0 ..< self.filterBusLines.count {
                self.filterBusLines[index].isSelected = false
            }
            timer.invalidate()
            return
        } else if !self.viewBGMainTrackList.isHidden && filterBusLines.filter({$0.isSelected == true}).count <= 0 {
            for index in 0 ..< self.filterBusLines.count {
                self.filterBusLines[index].isSelected = false
            }
        }
        
        self.mapView?.clear()
        self.mapView?.addPolygon()
        
        if self.filterBusLines.filter({$0.isSelected == true}).count > 0 && self.homeViewModel.getBusStopsForSelectedRoute().count > 0 {
            self.setBusStationForSelectedRoutes(locationSequence: self.homeViewModel.getBusStopsForSelectedRoute())
            self.drawRoute(directionType: selectedDirection)
        } else {
            self.getBusStopAndSetupStopsOnMap(isRouteSelected: self.filterBusLines.filter({$0.isSelected == true}).count > 0 ? true: false)
        }
        
        LocationManager.SharedInstance.fetchCurrentLocation { location in
            if let coordinate = location.coordinate {
                self.mapView?.addMarkerOn(location: coordinate, markerImage: UIImage()) //Images.mapOriginPin ??
                LocationManager.SharedInstance.stopUpdatingLocation()
            }
        }
        
        
        var showBusStatusOfMap: [LiveBusStatusModel] = currentStatus
        let selectedRoute = filterBusLines.filter({$0.isSelected == true})
        print("******* Calling Select Route \(selectedRoute)")
        if selectedRoute.count > 0 {
            let selectedRouteString = selectedRoute.map({$0.routeNumber})
            showBusStatusOfMap = showBusStatusOfMap.filter{selectedRouteString.contains($0.lineText ?? "")}
        } else {
            showBusStatusOfMap = []
        }
        
        print("******* Calling TOtoal Count \(showBusStatusOfMap.count)")
        var markerCoorindate: [CLLocationCoordinate2D] = []
        
        for status in showBusStatusOfMap where status.x != "" && status.y != "" {
            if let latitude = CLLocationDegrees(status.y ?? ""), let longitude = CLLocationDegrees(status.x ?? ""), let oldLatitude = CLLocationDegrees(status.yPrevious ?? ""), let oldLongitude = CLLocationDegrees(status.xPrevious ?? "") {
                let markerPoint = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let oldMarkerPoint = CLLocationCoordinate2D(latitude: oldLatitude, longitude: oldLongitude)
                
                let marker = GMSMarker()
                
                marker.position = oldMarkerPoint
                marker.map = self.mapView
                
                let delayModel = homeViewModel.getDelayTimeWithCondition(liveBusStatusModel: status)
                let markerView = Bundle.loadView(fromNib: "MarkerView", withType: MarkerView.self)
                markerView.frame = CGRect(x: 0, y: 0, width: delayModel.widthFrame, height: delayModel.heighFrame)
                markerView.setTime = delayModel.delayTimeValue
                markerView.setTextColor = delayModel.color
                marker.iconView = markerView
                
                CATransaction.begin()
                CATransaction.setValue(Int(1.0), forKey: kCATransactionAnimationDuration)
                if marker.position != oldMarkerPoint {
                    marker.position = markerPoint
                    marker.map = self.mapView
                    
                    if delayModel.showDelay {
                        let markerView = Bundle.loadView(fromNib: "MarkerView", withType: MarkerView.self)
                        markerView.frame = CGRect(x: 0, y: 0, width: delayModel.widthFrame, height: delayModel.heighFrame)
                        markerView.setTime = delayModel.delayTimeValue
                        markerView.setTextColor = delayModel.color
                        marker.iconView = markerView
                    } else {
                        marker.icon = Images.livebusStatus?.imageWithNewSize()
                    }
                }
                
                CATransaction.commit()
                
                markerCoorindate.append(oldMarkerPoint)
                markerCoorindate.append(markerPoint)
                
            } else if let latitude = CLLocationDegrees(status.y ?? ""), let longitude = CLLocationDegrees(status.x ?? "") {
                let markerPoint = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let marker = GMSMarker()
                
                CATransaction.begin()
                CATransaction.setValue(Int(1.0), forKey: kCATransactionAnimationDuration)
                
                if markerPoint != marker.position {
                    marker.position = markerPoint
                    marker.map = self.mapView
                    
                    let delayModel = homeViewModel.getDelayTimeWithCondition(liveBusStatusModel: status)
                    let markerView = Bundle.loadView(fromNib: "MarkerView", withType: MarkerView.self)
                    markerView.frame = CGRect(x: 0, y: 0, width: delayModel.widthFrame, height: delayModel.heighFrame)
                    markerView.setTime = delayModel.delayTimeValue
                    markerView.setTextColor = delayModel.color
                    marker.iconView = markerView
                    
                }
                CATransaction.commit()
                
                markerCoorindate.append(markerPoint)
                
            }
        }
        if !canZoomIn {
            var gmsBounds = GMSCoordinateBounds()
            for coordinate in markerCoorindate {
                gmsBounds = gmsBounds.includingCoordinate(coordinate)
            }
            
            let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 17)
            mapView?.animate(with: update)
            canZoomIn = true
        }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval:10, repeats: true) { _ in
            print("******* Calling This API ******")
            self.getLiveBusStatusFromAPI()
        }
    }
    
    @IBAction func buttonShowOnMapAction(_ sender: UIButton) {
        sender.isSelected = true
if let addressInfoWindow = self.addressLabelInfoWindow, let addressLabelText = self.infoWindow?.addressLabel.text,/* !addressInfoWindow.isEmpty, !addressLabelText.isEmpty,*/ addressInfoWindow != addressLabelText {
            /*if tableHeightConstraint.constant > 0 {
             tableHeightConstraint.constant = 0
             }*/
            infoWindow?.removeFromSuperview()
        }
        self.infoTableWindow?.removeFromSuperview()
        self.addressLabelInfoWindow = ""
        //viewBGMainTrackList.isHidden = false
//        self.tableWidthConstraint.constant = homeViewModel.getMaxWidth(routes: filterBusLines.map({$0.routeNumber}))
        
           // self.tableHeightConstraint.constant = 0
            self.mapView?.clear()
            self.mapView?.addPolygon()
           // self.getBusStopAndSetupStopsOnMap(isRouteSelected: false)
       
            canZoomIn = false
//            for index in 0 ..< self.filterBusLines.count {
//                self.filterBusLines[index].isSelected = false
//            }
            self.selectRoute = Constants.showOnMap.localized
            self.buttonDropDown.setTitle(Constants.showOnMap.localized, for: .normal)
            

        
        self.resetDrawPathView()
       // self.setBusCurrentStatusOnMap(currentStatus: allBusStatusModel)
        //self.getLiveBusStatusFromAPI()
        self.tableView.layoutIfNeeded()
        
        timeTableViewModel.getBusTimeTableContent(completionHandler: { routeModel, error in
            
            self.routeModel = routeModel
            
            if self.buttonDropDown.isSelected {
                self.showRouteList()
            }
        })
    }
    
    
    private func resetDrawPathView() {
        self.hideRouteDirectionView()
        self.drawPolyline.forEach({$0.map = nil})
        self.drawPolyline = []
    }
    
    private func getBusStopAndSetupStopsOnMap(isRouteSelected: Bool = false) {
        
        if ServiceManager.sharedInstance.stopListItemData != nil && ServiceManager.sharedInstance.stopListItemData?.count ?? 0 > 0  {
            if let busStoplocation:[StopsItem] = ServiceManager.sharedInstance.stopListItemData {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    DispatchQueue.main.async {
                        
                        if busStoplocation.count > 0 && self.mapView != nil {
                            for busStopModel in busStoplocation {
                                if let lat = CLLocationDegrees(busStopModel.stop_lat ?? ""), let long = CLLocationDegrees(busStopModel.stop_lon ?? "") {
                                    let markerPoint = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    
                                    let marker = GMSMarker()
                                    marker.position = markerPoint
                                    marker.map = self.mapView
                                    marker.icon = Images.livebusStatus?.imageWithNewSize(scaledToSize: CGSize(width: 40, height: 40)) //homeBusStopPin
                                }
                            }
                            
                            if isRouteSelected == false {
                                var gmsBounds = GMSCoordinateBounds()
                                for busStopModel in busStoplocation {
                                    if let lat = CLLocationDegrees(busStopModel.stop_lat ?? ""), let long = CLLocationDegrees(busStopModel.stop_lon ?? "") {
                                        let markerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                        gmsBounds = gmsBounds.includingCoordinate(markerCoordinate)
                                    }
                                }
                                
                                let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 12)
                                self.mapView?.animate(with: update)
                                self.zoomMapView()
                            }
                        }
                    }
                }
            }
        } else {
            self.fetchBusStopListForMap(isRouteSelected: isRouteSelected)
        }
    }
    
    private func fetchBusStopListForMap(isRouteSelected: Bool = false) {
        
        
        let activity = startActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.homeViewModel.getBusStopListForMap { [weak self] (stopList, error) in
                activity.stop()
                guard let self = self else { return }
                DispatchQueue.main.async {
                   
                      //  ServiceManager.sharedInstance.busStopsModel = busModel
                    
                    guard let stopItemList = stopList else {
                        return
                    }
                       
                    
                    ServiceManager.sharedInstance.stopListItemData = stopItemList
                        self.homeViewModel.busStopModelList = stopItemList
                        if stopItemList.count > 0 && self.mapView != nil {
                            for stopModel in stopItemList {
                                if let lat = CLLocationDegrees(stopModel.stop_lat ?? ""), let long = CLLocationDegrees(stopModel.stop_lon ?? "") {
                                    let markerPoint = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    let marker = GMSMarker()
                                    marker.position = markerPoint
                                    //marker.title =  stopModel.translation
                                    
                                    marker.map = self.mapView
                                    marker.icon = Images.livebusStatus?.imageWithNewSize(scaledToSize: CGSize(width: 40, height: 40)) //homeBusStopPin
                                }
                            }
                            
                            if isRouteSelected == false {
                                var gmsBounds = GMSCoordinateBounds()
                                for stopModel in stopItemList {
                                    if let lat = CLLocationDegrees(stopModel.stop_lat ?? ""), let long = CLLocationDegrees(stopModel.stop_lon ?? "") {
                                        let markerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                        gmsBounds = gmsBounds.includingCoordinate(markerCoordinate)
                                    }
                                }
                                
                                let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 12)
                                self.mapView?.animate(with: update)
                                self.zoomMapView()
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
    
   
    func busStopsForSelectedBusRoutes(stopsLocation: [BusStopLocation]) -> [BusStopLocation] {
        
        var busStations: [BusStopLocation] = []
        
        if let selectedRouteIndex = self.filterBusLines.firstIndex(where: {$0.isSelected == true}) {
            let allSelectedRoutes = self.allBusStatusModel.filter({$0.lineText ?? "" == self.filterBusLines[selectedRouteIndex].routeNumber})
            if allSelectedRoutes.count > 0 {
                var currentStops = allSelectedRoutes.filter({$0.currentStop ?? "" != ""}).map({$0.currentStop ?? ""})
                let nextStops = allSelectedRoutes.filter({$0.nextStop ?? "" != ""}).map({$0.nextStop ?? ""})
                currentStops += nextStops
                let allStops = Array(Set(currentStops))
                busStations = stopsLocation.filter({allStops.contains($0.properties?.stoppointGlobalID ?? "")})
            }
        }
        return busStations
    }
    
    func configureTopHeaderForTraveelPreferences() {
        
        switch AppDefaults.shared.isUserLoggedIn {
        case true:
            topHeaderTrailingConstraint.priority = UILayoutPriority(250)
            widthConstraint.constant = 36
            trailingConstraintTravelPre.priority = UILayoutPriority(999)
            topHeaderTitleImageView.image = Images.homeTitle
        case false:
            topHeaderTrailingConstraint.priority = UILayoutPriority(999)
            widthConstraint.constant = 0
            trailingConstraintTravelPre.priority = UILayoutPriority(250)
            topHeaderTitleImageView.image = Images.myAccountTitleArrow?.setNewImageAsPerLanguage()
        }
        
    }
    
    private func createMap() {
        
        let height = UIScreen.main.bounds.height - (self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 40 + (self.navigationController?.navigationBar.frame.size.height ?? 96) + (self.tabBarController?.tabBar.frame.size.height ?? 90))
        if currentLanguage == .english {
            LanguageService.setAppLanguageTo(lang: Languages.english.rawValue)
            GMSPlacesClient.provideAPIKey("")
            GMSPlacesClient.provideAPIKey(Keys.googleApiKey)
            mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        } else {
            LanguageService.setAppLanguageTo(lang: Languages.arabic.rawValue)
            GMSPlacesClient.provideAPIKey("")
            GMSPlacesClient.provideAPIKey(Keys.googleApiKey)
            mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        }
        mapView?.delegate = self
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.padding = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        self.mapContainerView.addSubview(self.mapView ?? GMSMapView())
        
        DispatchQueue.main.async {
            let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
            self.mapView?.camera = camera
            self.mapView?.animate(to: camera)
        }
        
        initialize()
        
        DispatchQueue.main.async {
            if let mapView = self.mapView {
                mapView.addPolygon()
            }
        }
        
    }
    
    private func removeMap() {
        mapView?.removeFromSuperview()
        mapView?.delegate = nil
        mapView = nil
    }
    
    private func zoomMap(){
        
        //self.mapView?.camera?.setScale(3.0)
    }
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.endEditing(true)
        // Favorite hiden from Home Screen
        //fetchFavoritePlaces()
        
        //fetchWeather()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.weatherView.isHidden = true
        //self.animationView?.isHidden = true
        self.isBottomSheetExpanded = false
        removeMap()
        
        for index in 0 ..< self.filterBusLines.count {
            self.filterBusLines[index].isSelected = false
        }
        self.selectRoute = Constants.showOnMap.localized
        self.buttonDropDown.setTitle(Constants.showOnMap.localized, for: .normal)
       // self.tableHeightConstraint.constant = 0
        self.tableView.layoutIfNeeded()
        self.timer.invalidate()
        
        AF.session.getTasksWithCompletionHandler { dataTask, uploadTask, downloadTask in
            downloadTask.forEach({$0.cancel()})
            uploadTask.forEach({$0.cancel()})
            downloadTask.forEach({$0.cancel()})
        }
        
       // self.viewBGMainTrackList.layer.removeFromSuperlayer()
        
    }
    
    func setUpBottomView() {
        favoritePlacesTableView.tableFooterView = UIView()
        self.bottomSheetView.layer.shadowColor = Colors.borderColorGray.cgColor
        self.bottomSheetView.layer.shadowOpacity = 0.3
        self.slideUpDownView.layer.cornerRadius = 3
    }
    
    func setupRouteListView()  {
        
        self.viewBGMainTrackList.frame = CGRectMake(0, screenSize.height+100, screenSize.width, screenSize.height)
        appdelegate.window?.addSubview(self.viewBGMainTrackList)
    }
    func showRouteList()  {
        UIView.animate(withDuration: 1.5) {
            self.viewBGMainTrackList.isHidden = false
            self.viewBGTrackList.isHidden = false
            self.tableView.reloadData()
            self.viewBGMainTrackList.frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.height)
                self.viewBGMainTrackList.backgroundColor = .init(white: 0.5, alpha: 0.1)
            self.tableView.reloadData()
        }
    }
    
    func hideRouteList()  {
        buttonDropDown.isSelected = false
        viewBGMainTrackList.backgroundColor = .init(white: 0.5, alpha: 0.0)
        UIView.animate(withDuration: 1.5) {
         
            self.viewBGMainTrackList.frame = CGRectMake(0, self.screenSize.height+100, self.screenSize.width, self.screenSize.height)
          
        }
       
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        
        guard bottomSheetStackView.arrangedSubviews.count == 7, let tappedView = sender.view else { return }
        if let index = bottomSheetStackView.arrangedSubviews.firstIndex(of: tappedView) {
            switch index {
            case 0:
                navigateTo(.home)
            case 1:
                navigateTo(.work)
            case 2:
                navigateTo(.school)
            case 3:
                navigateTo(.favorite)
            case 4:
                let viewController = EventListViewController(nibName: "EventListViewController", bundle: nil)
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        }
    }
    
    private func navigateTo(_ placeType: PlaceType) {
        let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
        viewController.placeType = placeType
        viewController.travelPreferenceModel = self.travelPreferenceModal
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func fetchWeather() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        guard let animationView = self.animationView else {
            return
        }
        animationView.isHidden = false
        self.weatherView.isHidden = true
        animationView.play()
        homeViewModel.getWeather()
        homeViewModel.weatherResult.bind { (weather, error) in
            if let weather = weather {
                ServiceManager.sharedInstance.downloadImage(url: weather.weatherIcon ?? "") { result in
                    if case let .success(weatherIcon) = result {
                        self.weatherIcon.image = weatherIcon
                        self.weatherIcon.tintColor = UIColor(hexString: weather.textColor ?? "", alpha: 1.0)
                    }
                }
                DispatchQueue.main.async {
                    self.weatherView.isHidden = false
                    animationView.isHidden = true
                    if let roundedTemperature = weather.temperature?.round(to: 1) {
                        self.weatherLabel.text = roundedTemperature.string + " °"
                    }
                    if let color = weather.color, color != emptyString {
                        self.weatherView.backgroundColor = UIColor(hexString: color, alpha: 1.0)
                    } else {
                        self.weatherView.backgroundColor = Colors.defaultWeatherBackground
                    }
                    self.weatherLabel.textColor = UIColor(hexString: weather.textColor ?? "", alpha: 1.0)
                    self.weatherIcon.tintColor = UIColor(hexString: weather.textColor ?? "", alpha: 1.0)
                }
            } else if error != nil {
                //self.showAlert(for: .serverError)
            }
        }
    }
    
    @objc func filterButtonTapped() {
        let travelPreferenceViewController: TravelPreferenceViewController = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        travelPreferenceViewController.delegate = self
        travelPreferenceViewController.travelPreferenceModel = self.travelPreferenceModal
        travelPreferenceViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(travelPreferenceViewController, animated: true)
    }
    
    func initialize() {
        
        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { location in
            if let location = location {
                let camera = GMSCameraPosition(target: (location.coordinate), zoom: Constants.mapViewZoomLevel)
                self.source.coordinate = location.coordinate
                self.mapView?.camera = camera
                if GMSGeometryContainsLocation(location.coordinate, locationManager.path, true) {
                    self.mapView?.addMarkerOn(location: location.coordinate, markerImage: UIImage()) //Images.mapOriginPin ??
                    return
                }
                // if location out of Riyadh City
                
                DispatchQueue.main.async {
                    let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
                    self.mapView?.camera = camera
                    self.mapView?.animate(to: camera)
                }
                
                self.showCustomAlert(alertTitle: Constants.locationOutOfRiyadhCityTitle.localized, alertMessage: Constants.locationOutOfRiyadhCity, firstActionTitle: ok.localized, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                    DispatchQueue.main.async {
                        if ServiceManager.sharedInstance.stopListItemData == nil || ServiceManager.sharedInstance.stopListItemData?.count ?? 0 <= 0 {
                            let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: Constants.mapViewZoomLevel)
                            self.mapView?.camera = camera
                            self.mapView?.animate(to: camera)
                        } else {
                            if ServiceManager.sharedInstance.stopListItemData != nil || ServiceManager.sharedInstance.stopListItemData?.count == 0 {
                                self.getBusStopAndSetupStopsOnMap()
                            }
                        }
                    }
                }, secondActionHandler: nil)
            } else {
                self.showCustomAlert(alertTitle: Constants.noLocationAlertTitle.localized,
                                     alertMessage: Constants.noLocationAlertMessage.localized,
                                     firstActionTitle: Constants.goToSettings.localized,
                                     secondActionTitle: cancel,
                                     secondActionStyle: .cancel, firstActionHandler: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
                    }
                }, secondActionHandler: nil)
                
                if let sourceCoordinate = self.source.coordinate {
                    self.mapView?.addMarkerOn(location: sourceCoordinate, markerImage: UIImage()) //Images.mapOriginPin ??
                }
            }
        }
    }
    
    @IBAction func didPanBottomSheet(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        if sender.state == .changed {
            if translation.y < -50 {
                if self.isBottomSheetExpanded == false {
                    self.isBottomSheetExpanded = true
                    UIView.animate(withDuration: 0.3) {
                        self.bottomSheetHeightConstraint.constant = self.bottomSheetExpandedHeight
                        self.view.layoutIfNeeded()
                    }
                }
            } else if translation.y > 50 {
                if self.isBottomSheetExpanded == true {
                    UIView.animate(withDuration: 0.3) {
                        self.bottomSheetHeightConstraint.constant = self.bottomSheetExpandedHeight
                        self.favCellImageHeightWithPadding = 64
                        self.heightForRow = UITableView.automaticDimension
                        self.bottomSheetHeightConstraint.constant = self.bottomSheetCollapsedHeight
                        self.view.layoutIfNeeded()
                    }
                    self.isBottomSheetExpanded = false
                }
            }
        } else if sender.state == .ended {
            sender.setTranslation(.zero, in: view)
        }
    }
    
    func fetchCurrentLocation() {
        var currentLocation: CLLocation? {
            didSet {
                if let coordinate = currentLocation?.coordinate {
                    GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(coordinate.latitude),\(coordinate.longitude)") { (location) in
                        if let result = location?.results, result.count > 0 {
                            self.source.coordinate = coordinate
                            self.source.address = result[0].formattedAddress
                        }
                    }
                }
            }
        }
        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { location in
            if let location = location {
                currentLocation = location
            }
        }
    }
    
    @IBAction func buttonSelectDestinationTapped(_ sender: UIButton) {
      
        let routeSelectionViewController: AvailableRoutesViewController = AvailableRoutesViewController.instantiate(appStoryboard: .availableRoutes)
        routeSelectionViewController.navigationItem.backBarButtonItem?.title = " "
        routeSelectionViewController.hidesBottomBarWhenPushed = true
        routeSelectionViewController.travelPreferenceModel = travelPreferenceModal
        self.navigationController?.pushViewController(routeSelectionViewController, animated: true)
       
       // navigateOnAvailableRouteView
    }
    
//    func navigateOnAvailableRouteView()  {
//        let availableRoutesViewController: AvailableRoutesViewController = AvailableRoutesViewController.instantiate(appStoryboard: .availableRoutes)
//        //availableRoutesViewController.initialize(with: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: self.travelPreferenceModel)
//        self.navigationController?.pushViewController(availableRoutesViewController, animated: true)
//    }
    private func setBusStationForSelectedRoutes(locationSequence: [LocationSequence]) {
        if locationSequence.count > 0 {
            let coordinates = locationSequence.map({$0.coord})
            if coordinates.count > 0 && self.mapView != nil {
                for coordinate in coordinates {
                    if let lat = coordinate.first, let long = coordinate.last {
                        let markerPoint = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let marker = GMSMarker()
                        marker.position = markerPoint
                        marker.map = self.mapView
                        if coordinate == coordinates.first || coordinate == coordinates.last {
                            marker.icon = Images.livebusStatus?.imageWithNewSize(scaledToSize: CGSize(width: 40, height: 40))
                            
                        }else{
                            marker.icon = Images.busDot?.imageWithNewSize(scaledToSize: CGSize(width: 13, height: 13))
                        }
                        
                    }
                }
            }
        }
    }
    
    func drawRoute(directionType: SelectedDirection) {
        
        let routePath = homeViewModel.getRoutePath(selectedDirectionType: directionType)
        routePath.forEach { route in
            DispatchQueue.main.async {
                if let firstIndex = self.drawPolyline.firstIndex(where: {$0.path == route.path}) {
                    self.drawPolyline[firstIndex].strokeColor = route.color
                    self.drawPolyline[firstIndex].map = self.mapView
                } else {
                    let polyLine = GMSPolyline(path: route.path)
                    polyLine.strokeColor = route.color
                    polyLine.strokeWidth = Constants.mapRouteStrokeWidth
                    polyLine.map = self.mapView
                    self.drawPolyline.append(polyLine)
                }
            }
        }
    }
    
    func switchRoutes(isNormalRoute:Bool)  {
        
        //selectedDirection = isNormalRoute ? .north :.south
            //routeDirectionModel?.directionType = isNormalRoute ? .north : .south
       // self.drawRoute(directionType: selectedDirection)
        timer.invalidate()
        let strSource = buttonSecondDirection.titleLabel?.text ?? ""
        let strDestination = buttonFirstDirection.titleLabel?.text ?? ""
        
        buttonFirstDirection.setTitle(strSource, for: .normal)
        buttonSecondDirection.setTitle(strDestination, for: .normal)
        isNormalRoute ? self.buttonTopDirectionTapped(UIButton()) : self.buttonBottomDirectionTapped(UIButton())
        self.getLiveBusStatusFromAPI()
        
    }
    
    @IBAction func buttonTapSwitchDirection(_ sender: UIButton) {
        let isNormalRoute = sender.isSelected
        switchRoutes(isNormalRoute: isNormalRoute)
        sender.isSelected = !sender.isEnabled
        
        
    }
    
    @IBAction func buttonTapDirectionTo(_ sender: UIButton) {
        self.buttonDirectionView.isHidden = !sender.isSelected
        
        UIView.animate(withDuration: 2) {
            self.directionViewConstrantHeight.constant = self.buttonDirectionView.isHidden ? 0 : 96
        }
        sender.isSelected = !sender.isSelected
        setUPDirectionToCorner()
    }
    
    @IBAction func buttonTopDirectionTapped(_ sender: UIButton) {
        
       
        
        if selectedDirection == .north {
            return
        }
        
        drawPolyline.forEach({$0.map = nil})
        drawPolyline = []
        
        selectedDirection = .north
        routeDirectionModel?.directionType = .north
        self.drawRoute(directionType: .north)
//        self.buttonFirstDirection.isUserInteractionEnabled = true
//        self.buttonSecondDirection.isUserInteractionEnabled = false
        self.buttonFirstDirection.showLoading(color: UIColor.white)
        timer.invalidate()
        self.getLiveBusStatusFromAPI()
        
    }
    
    @IBAction func buttonBottomDirectionTapped(_ sender: UIButton) {
       
        
        if selectedDirection == .south {
            return
        }
        
        drawPolyline.forEach({$0.map = nil})
        drawPolyline = []
        
        selectedDirection = .south
        routeDirectionModel?.directionType = .south
        self.drawRoute(directionType: .south)
        
        timer.invalidate()
        self.getLiveBusStatusFromAPI()
        
    }
    @IBAction func buttonDismissRouteList(_ sender: UIButton) {
        self.hideRouteList()
    }
}

extension HomeViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("willMove \(self.addressLabelInfoWindow ?? "")")
        print("willMove \(self.infoWindow?.addressLabel.text ?? "")")
        if let addressInfoWindow = self.addressLabelInfoWindow, let addressLabelText = self.infoTableWindow?.titleLabel.text, addressInfoWindow != addressLabelText {
//            if tableHeightConstraint.constant > 0 && !fromButtonShowOnMapAction {
//                tableHeightConstraint.constant = 0
//            }
            if self.fromButtonShowOnMapAction {
                self.fromButtonShowOnMapAction = false
            }
        }
        
        if viewBGMainTrackList.isHidden  || infoTableWindow?.loadingButton.isHidden == true {
            self.infoTableWindow?.removeFromSuperview()
        }
        
        self.addressLabelInfoWindow = ""
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("didTapAt")

//        if tableHeightConstraint.constant > 0 {
//            tableHeightConstraint.constant = 0
//        }
        infoWindow?.removeFromSuperview()
        infoTableWindow?.removeFromSuperview()
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        if let mylocation = mapView.myLocation {
            let locationManager = LocationManager.SharedInstance
            if GMSGeometryContainsLocation(mylocation.coordinate, locationManager.path, true) {
                self.mapView?.addMarkerOn(location: mylocation.coordinate, markerImage: UIImage()) //Images.mapOriginPin
                return false
            } else {
                self.showCustomAlert(alertTitle: Constants.locationOutOfRiyadhCityTitle.localized, alertMessage: Constants.locationOutOfRiyadhCity, firstActionTitle: ok.localized, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: nil, secondActionHandler: nil)
                return true
            }
        } else {
            return true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//
//        if tableHeightConstraint.constant > 0 {
//            tableHeightConstraint.constant = 0
//        }
        
        let isSelected = filterBusLines.contains(where: {$0.isSelected == true})
        let stationName = homeViewModel.getBusStationName(isRouteSelected: isSelected, marker: marker)
        let stopID = homeViewModel.getBusStopIDSelectedBus(isRouteSelected: isSelected, marker: marker)
    
        if stationName != emptyString {
            infoTableWindow?.removeFromSuperview()
            infoTableWindow = MarkerInfoTableView.instanceFromNib()
            infoTableWindow?.configureView()
            infoTableWindow?.titleText = stationName
            infoTableWindow?.frame = self.view.frame
            infoTableWindow?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(infoTableWindow ?? UIView())
            
            infoTableWindow?.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 25).isActive = true
            infoTableWindow?.trailingAnchor.constraint(greaterThanOrEqualTo: self.view.trailingAnchor, constant: -25).isActive = true

            infoTableWindow?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 10).isActive = true
            infoTableWindow?.tableHeightConstraint.constant = 28
        }
        
        infoTableWindow?.loadingButton.isHidden = false
        infoTableWindow?.loadingButton.showLoading(color: Colors.textColor)
        self.homeViewModel.getNextBusDetail(stopID: stopID) { nextBusDetail, error in
            DispatchQueue.main.async {
                
                self.infoTableWindow?.loadingButton.hideLoading()
                self.infoTableWindow?.loadingButton.isHidden = true
                
                if let nextBusDetail = nextBusDetail, nextBusDetail.count > 0 {
                    let busInfo = self.homeViewModel.getNextBusDetailInfo(nextBusInfo: nextBusDetail)
                    let tableHeight = self.homeViewModel.getTotalHeightOfMarkerTableView(markersInfo: busInfo)
                    self.infoTableWindow?.tableHeightConstraint.constant = tableHeight
                    if tableHeight < 150 {
                        self.infoTableWindow?.tableView.isScrollEnabled = false
                    } else {
                        self.infoTableWindow?.tableView.isScrollEnabled = true
                    }
                    
                    let markerInfoWidth = self.homeViewModel.getWidthForMarkerInfoView(placeName: stationName, nextBusInfo: busInfo)
                    
                    if markerInfoWidth.updatedWidth {
                        self.infoTableWindow?.widthAnchor.constraint(equalToConstant: markerInfoWidth.width).isActive = true
                    }
                    
                    self.infoTableWindow?.layoutIfNeeded()
                    self.infoTableWindow?.layoutSubviews()
                    self.infoTableWindow?.tabularData = busInfo
                } else {
                    //self.infoTableWindow?.tableHeightConstraint.constant = 0
                }
            }
        }
        
        return false
    }
}

// MARK: - Notifications
extension HomeViewController {

    @objc func notificationTapped(_ sender: UIButton) {
        let notificationViewController = NotificationViewController.instantiate(appStoryboard: .notification)
        self.navigationController?.pushViewController(notificationViewController, animated: true)
    }
}

// MARK: - Favorite Place Implementation
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if homeViewModel.favoritePlaces.value.count > 0 && tableView == self.tableView {
            return 10
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return routeModel?.items?.count ?? 0
        } else {
            if homeViewModel.favoritePlaces.value.count > 0 {
                return homeViewModel.favoritePlaces.value.count
            }
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.tempHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForRow = tableView == self.tableView ? 70 : heightForRow
        return heightForRow
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if routeModel?.items?.count ?? 0 > 0 {
                let cell: MapBusRouteCell = tableView.dequeue(cellForRowAt: indexPath)
                let model = routeModel?.items?[indexPath.row]
                
                
                cell.labelBusRouteNumber.text = routeModel?.getRouteNumber(index: indexPath.row)
                
                cell.labelBusRouteNumber.backgroundColor = routeModel?.getTackColor(index: indexPath.row) //titleAndColor?.0.hexToUIColor()
                
               // cell.labelBusRouteStops.text = model.routeNumber
               // cell.buttonSelectCheckBox.isSelected = filterBusLines[indexPath.row].isSelected
                cell.labelBusRouteNumber.textColor = .white
                
                cell.labelBusRouteStops.text = routeModel?.getSourceDestination(index: indexPath.row)
                //cell.labelBusRouteNumber.setAlignment()
                //cell.labelBusRouteStops.setAlignment()
                return cell
            } else {
                // Changed true to false
               // self.dropDownView.isHidden = false
                return UITableViewCell()
            }
            
        } else {
            if homeViewModel.favoritePlaces.value.count > 0 {
                let favoritePlaces = homeViewModel.favoritePlaces.value
                let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesTableViewCell.identifier, for: indexPath) as? FavoritesTableViewCell
                cell?.favoriteCellImage.image = cell?.myFavPlacesImage
                cell?.configureCell(favoritePlace: favoritePlaces[indexPath.row])
                return cell ?? UITableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
                cell?.textLabel?.text = Constants.noFavorites.localized
                cell?.textLabel?.font = Fonts.CodecBold.fourteen
                cell?.textLabel?.textColor = Colors.noFavoritesText
                cell?.textLabel?.textAlignment = .center
                return cell ?? UITableViewCell()
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == self.tableView {
            hideRouteList()
            if let firstIndex = filterBusLines.firstIndex(where: {$0.isSelected == true}) {
                if indexPath.row != firstIndex {
                    filterBusLines[firstIndex].isSelected = false
                    self.tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0)], with: .none)
                }
            }
            
            //filterBusLines[indexPath.row].isSelected = !filterBusLines[indexPath.row].isSelected
            
            self.tableView.reloadRows(at: [indexPath], with: .none)
            
//            if tableHeightConstraint.constant > 0 {
//                // Hide by dileep
//                //self.tableHeightConstraint.constant = 0
//            }
//
            if let filteredBus = filterBusLines.first(where: {$0.isSelected == true}) {
                self.buttonDropDown.showLoading(color: Colors.textColor)
                homeViewModel.getRouteForSelectedStopAPI(selectedRoute: filteredBus.routeNumber) { stopRouteModel, error in
                    DispatchQueue.main.async {
                        self.buttonDropDown.hideLoading()
                        
                        let routeDirection = self.homeViewModel.getMultipleRouteDriection()
                        self.routeDirectionModel = routeDirection
                        self.setupMultipleDirectionView(directionModel: routeDirection)
                        self.buttonDropDown.titleLabel?.numberOfLines = 0
                        let titleName = "\(Constants.busRoute.localized) \(filteredBus.routeNumber)"
                        self.selectRoute = titleName
                        self.buttonDropDown.setTitle(titleName, for: .normal)
                        
                        if let stopRouteModel = stopRouteModel, let transportations = stopRouteModel.transportations, transportations.count > 0 {
                            self.setBusCurrentStatusOnMapAfterRouteSelection(currentStatus: self.allBusStatusModel)
                            self.drawRoute(directionType: routeDirection.directionType)
                        }
                    }
                }
            }
            
            canZoomIn = false
            self.tableView.layoutIfNeeded()
            
        } else {
            guard homeViewModel.favoritePlaces.value.count > 0 else { return }
            let favoritePlace = homeViewModel.favoritePlaces.value[indexPath.row]
            var location = LocationData()
            if let latitude = favoritePlace.latitude, let longitude = favoritePlace.longitude {
                location.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            location.id = favoritePlace.id
            location.address = favoritePlace.address
            location.type = LocationType(rawValue: favoritePlace.type ?? emptyString)
            didSelectFromFavorites(place: location)
        }
    }
    
    private func setupMultipleDirectionView(directionModel: RouteDirectionModel) {
//
//        buttonSecondDirection.backgroundColor = UIColor.white
//        buttonSecondDirection.setTitleColor(Colors.rptGreen, for: .normal)
        
//        buttonFirstDirection.backgroundColor = Colors.rptGreen
//        buttonFirstDirection.setTitleColor(UIColor.white, for: .normal)
        
        buttonFirstDirection.setTitle(directionModel.northDirection, for: .normal)
       buttonSecondDirection.setTitle(directionModel.southDirection, for: .normal)
        
        if directionModel.directionType == .none {
            self.hideRouteDirectionView()
        } else {
            self.labelDirectionTo.isHidden = true
            self.buttonDirectionView.isHidden = false
            self.directionView.isHidden = false
            self.buttonFirstDirection.isUserInteractionEnabled = false
            self.buttonSecondDirection.isUserInteractionEnabled = false
            
            buttonSecondDirection.isHidden = false
            if directionModel.southDirection == "" {
                buttonSecondDirection.isHidden = true
            }
        }
    }

    private func setBusCurrentStatusOnMapAfterRouteSelection(currentStatus: [LiveBusStatusModel]) {
    
        self.mapView?.clear()
        self.mapView?.addPolygon()
        
        if self.filterBusLines.filter({$0.isSelected == true}).count > 0 && self.homeViewModel.getBusStopsForSelectedRoute().count > 0 {
            self.setBusStationForSelectedRoutes(locationSequence: self.homeViewModel.getBusStopsForSelectedRoute())
        } else {
            self.getBusStopAndSetupStopsOnMap(isRouteSelected: self.filterBusLines.filter({$0.isSelected == true}).count > 0 ? true: false)
        }
        
        LocationManager.SharedInstance.fetchCurrentLocation { location in
            if let coordinate = location.coordinate {
                self.mapView?.addMarkerOn(location: coordinate, markerImage: UIImage()) //Images.mapOriginPin ??
                LocationManager.SharedInstance.stopUpdatingLocation()
            }
        }
        
        var showBusStatusOfMap: [LiveBusStatusModel] = currentStatus
        let selectedRoute = filterBusLines.filter({$0.isSelected == true})
        print("******* Calling Select Route \(selectedRoute)")
        if selectedRoute.count > 0 {
            let selectedRouteString = selectedRoute.map({$0.routeNumber})
            showBusStatusOfMap = showBusStatusOfMap.filter{selectedRouteString.contains($0.lineText ?? "")}
        }
        
        print("******* Calling TOtoal Count \(showBusStatusOfMap.count)")
        var markerCoorindate: [CLLocationCoordinate2D] = []
        
        for status in showBusStatusOfMap where status.x != "" && status.y != "" {
            if let latitude = CLLocationDegrees(status.y ?? ""), let longitude = CLLocationDegrees(status.x ?? ""), let oldLatitude = CLLocationDegrees(status.yPrevious ?? ""), let oldLongitude = CLLocationDegrees(status.xPrevious ?? "") {
                let markerPoint = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let oldMarkerPoint = CLLocationCoordinate2D(latitude: oldLatitude, longitude: oldLongitude)
                
                let marker = GMSMarker()

                marker.position = oldMarkerPoint
                marker.map = self.mapView
                
                let delayModel = homeViewModel.getDelayTimeWithCondition(liveBusStatusModel: status)
                let markerView = Bundle.loadView(fromNib: "MarkerView", withType: MarkerView.self)
                markerView.frame = CGRect(x: 0, y: 0, width: delayModel.widthFrame, height: delayModel.heighFrame)
                markerView.setTime = delayModel.delayTimeValue
                markerView.setTextColor = delayModel.color
                marker.iconView = markerView
                
                CATransaction.begin()
                CATransaction.setValue(Int(1.0), forKey: kCATransactionAnimationDuration)
                if marker.position != oldMarkerPoint {
                    marker.position = markerPoint
                    marker.map = self.mapView
                    
                    if delayModel.showDelay {
                        let markerView = Bundle.loadView(fromNib: "MarkerView", withType: MarkerView.self)
                        markerView.frame = CGRect(x: 0, y: 0, width: delayModel.widthFrame, height: delayModel.heighFrame)
                        markerView.setTime = delayModel.delayTimeValue
                        markerView.setTextColor = delayModel.color
                        marker.iconView = markerView
                    } else {
                        marker.icon = Images.livebusStatus?.imageWithNewSize()
                    }
                }
                
                CATransaction.commit()
                
                markerCoorindate.append(oldMarkerPoint)
                markerCoorindate.append(markerPoint)
                
            } else if let latitude = CLLocationDegrees(status.y ?? ""), let longitude = CLLocationDegrees(status.x ?? "") {
                let markerPoint = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let marker = GMSMarker()
                
                CATransaction.begin()
                CATransaction.setValue(Int(1.0), forKey: kCATransactionAnimationDuration)
                
                if markerPoint != marker.position {
                    marker.position = markerPoint
                    marker.map = self.mapView
                    
                    let delayModel = homeViewModel.getDelayTimeWithCondition(liveBusStatusModel: status)
                    let markerView = Bundle.loadView(fromNib: "MarkerView", withType: MarkerView.self)
                    markerView.frame = CGRect(x: 0, y: 0, width: delayModel.widthFrame, height: delayModel.heighFrame)
                    markerView.setTime = delayModel.delayTimeValue
                    markerView.setTextColor = delayModel.color
                    marker.iconView = markerView
                    
                }
                CATransaction.commit()
                
                markerCoorindate.append(markerPoint)
                    
            }
        }
        
        var gmsBounds = GMSCoordinateBounds()
        for coordinate in markerCoorindate {
            gmsBounds = gmsBounds.includingCoordinate(coordinate)
        }
        
        let update = GMSCameraUpdate.fit(gmsBounds, withPadding: 30)
        mapView?.animate(with: update)
        
    }
    func zoomMapView() {
        
        self.mapView?.animate(toZoom: 12)
    }
    private func fetchFavoritePlaces() {

        homeViewModel.fetchFavoritePlaces()
        homeViewModel.favoritePlaces.bind { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.favoritePlacesTableView.reloadData()
                UIView.animate(withDuration: 0.3) {
                    self.bottomSheetHeightConstraint.constant = self.bottomSheetCollapsedHeight
                }
            }
        }
    }

    private func didSelectFromFavorites(place: LocationData) {
        let routeSelectionViewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
        routeSelectionViewController.destination = place
        routeSelectionViewController.travelPreferenceModel = self.travelPreferenceModal
        self.navigationController?.pushViewController(routeSelectionViewController, animated: true)
    }
}

extension HomeViewController: TravelPreferenceViewControllerDelegate {
    
    func updatedTravelPreferences(modal: TravelPreferenceModel) {
        travelPreferenceModal = modal
    }
    
}

extension HomeViewController: MainViewControllerDelegate {
    
    func planATripSlideMenuTapped() {
    }
    
    func logoutButtonPressed() {
        showCustomAlert(alertTitle: emptyString,
                        alertMessage: Constants.logoutAlertMessage.localized,
                        firstActionTitle: Constants.logout.localized,
                        secondActionTitle: cancel,
                        secondActionStyle: .default,
                        firstActionHandler: performLogout)
    }
    
    private func performLogout() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let activity = startActivityIndicator()
        let logoutViewModel = LogoutViewModel()
        logoutViewModel.logout { [weak self] _ in
            activity.stop()
            AppDefaults.shared.isUserLoggedIn = false
            UserProfileDataRepository.shared.delete()
            UserDefaultService.deleteUserName()
            ServiceManager.sharedInstance.profileModel = nil
            self?.navigateToDashboard()
        }
    }
    
}

class LogoAnimationView: UIView {

    let logoGifImageView = try! UIImageView(gifImage: UIImage(gifName: "Splash_screen.gif"), loopCount: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .white
        
        let screenSize: CGRect = UIScreen.main.bounds
        addSubview(logoGifImageView)
        logoGifImageView.contentMode = .scaleAspectFit
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: screenSize.height).isActive = true
    }
}

extension UIImage {
    
    func imageWithNewSize(scaledToSize newSize:CGSize = CGSize(width: 22, height: 22)) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

import MapKit

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
}

public func !=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (lhs.latitude != rhs.latitude || lhs.longitude != rhs.longitude)
}

