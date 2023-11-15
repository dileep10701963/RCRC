//
//  AvailableRoutesViewController.swift
//  RCRC
//
//  Created by Errol on 21/07/20.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import Alamofire

class AvailableRoutesViewController: UIViewController {
    
    // Map View
    @IBOutlet weak var mapView: GMSMapView!
    let locationMarker = GMSMarker()
    var isMapLoaded = false
    @IBOutlet weak var proceedButtonConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var availableRouteTableViewBGHeight: NSLayoutConstraint!
    @IBOutlet weak var viewRouteAvailableBG: UIView!
    @IBOutlet weak var routeSelectionView: RouteSelectionView!
    @IBOutlet weak var availableRoutesTableView: UITableView!
    @IBOutlet weak var numberOfRoutesAvailable: UILabel!
    @IBOutlet weak var labelWhereFrom: UILabel!
    @IBOutlet weak var labelFrom: UILabel!
    @IBOutlet weak var labelBusRoutes: UILabel!
    @IBOutlet weak var labelBusRoutesSuggestedForYou: UILabel!
    @IBOutlet weak var viewRouteSuggested: UIView!
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var labelSaveForlater: UILabel!
    @IBOutlet weak var buttonAddFavourite: UIButton!
    @IBOutlet weak var buttonSavedFaouriteRoutes: UIButton!
    
    @IBOutlet weak var viewBusRouteSuggestHeightConstrant: NSLayoutConstraint!
    @IBOutlet weak var buttonDestination: UIButton!
    
    //@IBOutlet weak var proceedButtonView: ProceedButtonView!
    @IBOutlet weak var favoriteRouteButton: UIButton!
     var buttonSource = UIButton()
    @IBOutlet weak var buttonProceed: UIButton!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var labelDestination: UILabel!
    @IBOutlet weak var labelSource: UILabel!
    @IBOutlet weak var headerTitleFavoriteRouteView: UILabel!
    
    
    @IBOutlet weak var favRoutesTableView: UITableView!
    @IBOutlet weak var favoriteRoutesView: UIView!
    private var busNetworkViewModel = BusNetworkViewModel()
    private var travelPreferencesModel: TravelPreferenceModel!
    private var viewModel = AvailableRoutesViewModel()
    private let cellSpacingHeight: CGFloat = 15
    private let cellSpacingHeightWithCOntent: CGFloat = 27
    private let cellHeight: CGFloat = 150
    private var selectedSection: Int?
    private var didFetchData: Bool = false
    private var shouldAvailableTableShow = false
    private let mapZoomLevel:Float = 11
    var sourceStopModel:RecentSearch?
    var destinationStopModel:RecentSearch?
    var pdfData: Data? = nil
    var baseHomeViewModel = BaseHomeViewModel()
    var isFromViewDidLoad = true
    private var dataChanged: Bool = false {
        didSet {
            if let origin = self.origin, let destination = self.destination, dataChanged {
                //proceedButtonView.show()
                proceedButtonConstraintHeight.constant = 50
                self.availableRoutesTableView.setEmptyMessage("")
                self.setBackgroundViewNil()
            } else {
                //proceedButtonView.hide()
                //proceedButtonConstraintHeight.constant = 0
            }
        }
    }
    private var origin: LocationData?
    private var destination: LocationData?
    private var cellViewModels: [TripCellViewModel] = []
    var selectedSearchPreferences: SelectedSearchPreferences?
    var selectedStopsExpandModels: [StopRouteExpandModel] = []
    var arrayOfStopsIndexPath: [IndexPath] = []
    var selectedRow: Int = -1
    var searchResultsViewModel = SearchResultsViewModel()
    var pdfContentURL: String = emptyString
    var isProccedButtonVisible: Bool = false
    
    var favoriteRoutes: [FavoriteRoute]?
    var travelPreferenceModel: TravelPreferenceModel? = nil

    let coordinate = "coordinate"
    let stop = "stop"
    
    
    var isOriginAndDestinationAvailable: Bool {
        return origin != nil && destination != nil
    }
        
    var isOriginAvailable: Bool {
        return origin != nil && destination == nil
    }
        
    var isDestinationAvailable: Bool {
        return origin == nil && destination != nil
    }
    
    func initialize(with viewModel: AvailableRoutesViewModel, origin: LocationData, destination: LocationData, travelPreference: TravelPreferenceModel? = nil) {
        self.viewModel = viewModel
        self.origin = origin
        self.destination = destination
        self.travelPreferencesModel = travelPreference ?? nil
    }

    private func shimmerTableView() {
        if !didFetchData {
            DispatchQueue.main.async {
                self.availableRoutesTableView.reloadData()
                self.availableRoutesTableView.hideLoader()
                self.availableRoutesTableView.showLoader()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sourceDestinationViewSetup()
        titleSetup()
        self.logEvent(screen: .availableRoutes)
        self.availableRoutesTableView.dataSource = self
        self.availableRoutesTableView.delegate = self
        //shimmerTableView()
        self.fetchRoute()
        configureUIView()
        registerCellXibs()
        configureDelegates()
        setupFavoriteRoutes()
        
        //self.favoriteRouteButton.tintColor = .white
        //self.favoriteRouteButton.setImage(Images.ptAddToFavorite, for: .normal)
       // filterView.isHidden = true
        /*
        routeSelectionView.backButtonDelegate = self

        if routeSelectionViewData?.originSearchText == Constants.yourCurrentLocation {
            self.routeSelectionView.originSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation, attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
            self.routeSelectionView.destinationSearchBar.text = routeSelectionViewData?.destinationSearchText
        } else if routeSelectionViewData?.destinationSearchText == Constants.yourCurrentLocation {
            self.routeSelectionView.originSearchBar.text = routeSelectionViewData?.originSearchText
            self.routeSelectionView.destinationSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation, attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
        } else {
            self.routeSelectionView.originSearchBar.text = routeSelectionViewData?.originSearchText
            self.routeSelectionView.destinationSearchBar.text = routeSelectionViewData?.destinationSearchText
        }
        routeSelectionView.initialize(with: selectedSearchPreferences)
        */
        self.disableLargeNavigationTitleCollapsing()
        mapView.delegate = self
        DispatchQueue.main.async {
            self.addPolygon()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        guard let origin = self.origin, let destination = self.destination else { return }
        if viewModel.isRouteFavorite(source: origin, destination: destination) {
            //routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
        } else {
            routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.configureNavigationBar(title: Constants.planATrip.localized)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.availableRoutesTableView.setEmptyMessage("")
        if let pdfData = self.pdfData {
            self.availableRoutesTableView.setEmptyMessageWithLink(Constants.noDataAvailable.localized, #selector(self.errorMessageGoToRiyahdBusTapped(_:)), target: self, data: pdfData, #selector(self.handleTap(_:)), .center)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func sourceDestinationViewSetup()  {
       
        var sourceDestinationViewHeight = heightForSouceDestinationView()
        //mapView.frame = self.view.frame
        mapView.borderColor = .red
         if !isSourceDestinationSelected() {
             
           
            hideProceedButton()
             viewRouteSuggested.isHidden = true
            availableRoutesTableView.isHidden = false
             //self.viewRouteAvailableBG.frame = CGRectMake(0, self.view.frame.size.height - sourceDestinationViewHeight, self.view.frame.size.width, sourceDestinationViewHeight)
             //self.view.addSubview(self.viewRouteAvailableBG)
             
            // self.availableRoutesTableView.frame = CGRectMake(0, self.view.frame.size.height - sourceDestinationViewHeight, self.view.frame.size.width, sourceDestinationViewHeight)
            // self.view.addSubview(self.availableRoutesTableView)
             
             availableRouteTableViewBGHeight.constant = sourceDestinationViewHeight
             
             return
            
            
        }else if isSourceDestinationSelected() && shouldAvailableTableShow {
            let cell = cellRouteSelectJP()
            hideProceedButton()
            //availableRoutesTableView.isHidden = false
            cell.viewRouteSuggested.isHidden = false
            cell.viewRouteSuggested.isHidden = cellViewModels.count == 0
            cell.viewBusRouteSuggestHeightConstrant.constant = cellViewModels.count == 0 ? 0 : 40
            self.availableRoutesTableView.reloadData()
            availableRoutesTableView.isScrollEnabled = true
            //self.viewRouteAvailableBG.isUserInteractionEnabled = true
            //viewRouteAvailableBG.isScrollEnabled = true
            //viewRouteAvailableBG.contentSize = CGSizeMake(self.view.frame.size.width, 1500)
            //availableRouteTableViewBGHeight.constant = sourceDestinationViewHeight
        }else if isSourceDestinationSelected() {
           
            //proceedButtonView.show()
            //proceedButtonView.isHidden = false
            let cell = cellRouteSelectJP()
            cell.proceedButtonConstraintHeight.constant = 50
            cell.buttonProceed.titleLabel?.isHidden = false
            cell.buttonProceed.isHidden = false
            availableRoutesTableView.isScrollEnabled = false
            cell.viewRouteSuggested.isHidden = true
        }
        UIView.animate(withDuration: 1, animations: {
//            self.viewRouteAvailableBG.frame = CGRectMake(0, self.view.frame.size.height - sourceDestinationViewHeight, self.view.frame.size.width, sourceDestinationViewHeight)
            //self.availableRoutesTableView.frame = CGRectMake(0, self.view.frame.size.height - sourceDestinationViewHeight, self.view.frame.size.width, sourceDestinationViewHeight)
    //self.view.addSubview(self.viewRouteAvailableBG)
            self.availableRouteTableViewBGHeight.constant = sourceDestinationViewHeight
        })
        
    }
    
    func titleSetup()  {
        
        
        
        headerTitleFavoriteRouteView.text = Constants.favoriteRoutes.localized
        headerTitleFavoriteRouteView.setAlignment()
        
    }
    func heightForSouceDestinationView() -> CGFloat {
        var height:CGFloat = CGFloat(340)
        
        if isValidforProceedButton() && shouldAvailableTableShow  {
           height = self.view.frame.size.height - CGFloat(100)
        }else if isSourceDestinationSelected(){
            height = height + CGFloat(50)
        }
        return height
    }
    
    func isSourceDestinationSelected() -> Bool {
        return origin != nil && destination != nil
    }
    
    //MARK:Map View
    private func addMapMarker(locationData:CLLocationCoordinate2D,imageMarker:UIImage){
        
        
        let marker = GMSMarker()
        marker.position = locationData
        marker.map = self.mapView
        marker.icon = imageMarker
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
        
       
        if let sourceLoc = origin?.coordinate {
            addMapMarker(locationData: sourceLoc, imageMarker: Images.sourceMarkerOnJP ?? UIImage())
        }
        if let destLoc = destination?.coordinate {
            
            addMapMarker(locationData: destLoc, imageMarker: Images.destinationMarkerOnJP ?? UIImage())
        }
        
        
        
    }
    
    func initialize() {
       
        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { location in
            if let location = location {
                let camera = GMSCameraPosition(target: (location.coordinate), zoom: self.mapZoomLevel)
                
                self.mapView?.camera = camera
                if GMSGeometryContainsLocation(location.coordinate, locationManager.path, true) {
                    self.mapView?.addMarkerOn(location: location.coordinate, markerImage: UIImage()) //Images.mapOriginPin ??
                    return
                }
                // if location out of Riyadh City
                
                DispatchQueue.main.async {
                    let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: self.mapZoomLevel)
                    self.mapView?.camera = camera
                    self.mapView?.animate(to: camera)
                }
                
                self.showCustomAlert(alertTitle: Constants.locationOutOfRiyadhCityTitle.localized, alertMessage: Constants.locationOutOfRiyadhCity, firstActionTitle: ok.localized, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                    DispatchQueue.main.async {
                        if ServiceManager.sharedInstance.stopListItemData == nil || ServiceManager.sharedInstance.stopListItemData?.count ?? 0 <= 0 {
                            let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: self.mapZoomLevel)
                            self.mapView?.camera = camera
                            self.mapView?.animate(to: camera)
                        } else {
                            if ServiceManager.sharedInstance.stopListItemData != nil || ServiceManager.sharedInstance.stopListItemData?.count == 0 {
                                
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
                
                if let sourceCoordinate = self.origin?.coordinate {
                    self.mapView?.addMarkerOn(location: sourceCoordinate, markerImage: UIImage()) //Images.mapOriginPin ??
                }
            }
        }
        
    }

    private func fetchCurrentLocation() {
        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { location in
            if let location = location {
                self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 5)

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
                let camera = GMSCameraPosition(target: Constants.locationWhenUnavailable, zoom: self.mapZoomLevel)
                self.mapView.camera = camera
            }
        }
    }
    

    func fetchRoute() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        guard let origin = self.origin, let destination = self.destination  else {
            return
        }
        
        if selectedSearchPreferences == nil {
            self.selectedSearchPreferences = SelectedSearchPreferences()
        }
        
        viewModel.fetchTrips(origin: origin, destination: destination, searchPreferences: selectedSearchPreferences, travelPreference: travelPreferencesModel) { [weak self] cellViewModels in
            self?.cellViewModels = cellViewModels
            self?.pdfData = nil
            self?.didFetchData = true
            self?.shouldAvailableTableShow = true
            DispatchQueue.main.async { [weak self] in
               // self?.proceedButtonView.hide()
                self?.proceedButtonConstraintHeight.constant = 0
                self?.buttonProceed.isHidden = true
                self?.buttonProceed.titleLabel?.isHidden = true
                
                self?.availableRoutesTableView.hideLoader()
                self?.availableRoutesTableView.reloadData()
                self?.sourceDestinationViewSetup()
                if cellViewModels.isNotEmpty {
                   // self?.filterView.isHidden = true
                    self?.availableRoutesTableView.setEmptyMessage("")
                    if cellViewModels.count == 1 {
                        self?.numberOfRoutesAvailable.text = "\(cellViewModels.count) \(Constants.oneRouteAvailable.localized)"
                    } else {
                        //self?.numberOfRoutesAvailable.text = "\(cellViewModels.count) \(Constants.routeAvailable.localized)"
                    }
                    
                } else {
                    if let self = self {
                        let activityIndicator = self.startActivityIndicator()
                        self.baseHomeViewModel.getMapData { data in
                            activityIndicator.stop()
                            if let data = data {
                                self.pdfData = data
                                    self.shouldAvailableTableShow = true
                                self.availableRoutesTableView.setEmptyMessageWithLink(Constants.noDataAvailable.localized, #selector(self.errorMessageGoToRiyahdBusTapped(_:)), target: self, data: data, #selector(self.handleTap(_:)), .center)
                            } else {
                                self.shouldAvailableTableShow = true
                                self.availableRoutesTableView.setEmptyMessageWithLink(Constants.noDataAvailable.localized, #selector(self.errorMessageGoToRiyahdBusTapped(_:)), target: self, data: nil, #selector(self.handleTap(_:)), .center)
                            }
                        }
                        activityIndicator.stop()
                    }
                   // self?.filterView.isHidden = true
                }
            }
        }
    }
    
    @objc func errorMessageGoToRiyahdBusTapped(_ sender: UIButton) {
        
        if let navigationController = self.navigationController {
            let timeTableViewController: TimeTableViewController = TimeTableViewController.instantiate(appStoryboard: .busNetwork)
            timeTableViewController.hidesBottomBarWhenPushed = true
            timeTableViewController.isBackButtonPresent = true
            navigationController.pushViewController(timeTableViewController, animated: true)
        }
    }
    
    func fetchBusContent() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        busNetworkViewModel.getBusNetworkContent { responseResult, errr in
            DispatchQueue.main.async {
                if errr == .caseIgnore {
                    if let responseResult = responseResult, let item = responseResult.items, item.count > 0 {
                        self.fetchCurrentBusLines()
                        self.sourceDestinationViewSetup()
                    }
                }
            }
        }
    }
    
    private func fetchCurrentBusLines() {
        
        guard let contentFieldIndex = self.busNetworkViewModel.busResult?.items?[0].contentFields?.firstIndex(where: {$0.contentFieldValue?.data ?? emptyString == "Riyadh Bus Network"}) else { return }
        guard let nestedContentFieldsIndex = self.busNetworkViewModel.busResult?.items?[0].contentFields?[contentFieldIndex].nestedContentFields?.firstIndex(where: {$0.contentFieldValue?.data ?? emptyString == "Routes Map"}) else {return}
        
        
        let fileExtension = self.busNetworkViewModel.busResult?.items?[0].contentFields?[contentFieldIndex].nestedContentFields?[nestedContentFieldsIndex].nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.document?.fileExtension ?? ""
        
        if fileExtension == emptyString { return }
        if fileExtension == "pdf" {
            let contentPath = self.busNetworkViewModel.busResult?.items?[0].contentFields?[contentFieldIndex].nestedContentFields?[nestedContentFieldsIndex].nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.document?.contentURL ?? ""
            pdfContentURL = URLs.baseUrl + contentPath
            
            if let url = URL(string: pdfContentURL) {
                self.busNetworkViewModel.getPDFData(url: url) { [weak self ]data in
                    DispatchQueue.main.async {
                        if let data = data, let self = self {
                            self.availableRoutesTableView.setEmptyMessageWithLink(Constants.noDataAvailable.localized, #selector(self.errorMessageGoToRiyahdBusTapped(_:)), target: self, data: data, #selector(self.handleTap(_:)), .center)
                        }
                    }
                }
            }
        }
    }

    func configureUIView() {
        self.availableRoutesTableView?.rowHeight = cellHeight
        //self.proceedButtonView.hide()
        proceedButtonConstraintHeight.constant = 0
        buttonProceed.titleLabel?.isHidden = true
        self.availableRoutesTableView.tableFooterView = UIView()
    }

    func registerCellXibs() {
        availableRoutesTableView.register(RouteStopsTableViewCell.self)
        availableRoutesTableView.register(RouteTableViewCell.self)
        availableRoutesTableView.register(BuyButtonTableViewCell.self)
        availableRoutesTableView.register(RouteSelectJPTableViewCell.self)
        self.availableRoutesTableView.register(AvailableRouteTableViewCell.nib, forCellReuseIdentifier: AvailableRouteTableViewCell.identifier)
        
        
        //availableRoutesTableView.register(RouteSelectJPTableViewCell.self, forCellReuseIdentifier: RouteSelectJPTableViewCell.identifier)
        self.availableRoutesTableView.register(MapTableViewCell.nib, forCellReuseIdentifier: MapTableViewCell.identifier)
        self.availableRoutesTableView.register(RouteTableViewCell.nib, forCellReuseIdentifier: RouteTableViewCell.identifier)
        
        
        favRoutesTableView.register(FavoriteRouteTableViewCell.nib, forCellReuseIdentifier: FavoriteRouteTableViewCell.identifier)
        favRoutesTableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: EmptyTableViewCell.identifier)
    }

    func configureDelegates() {
        var coOrd = CLLocationCoordinate2D()
        var imageMarker = Images.sourceMarkerOnJP
        if let sourceLoc = origin?.coordinate {
            coOrd = sourceLoc
        }
        if let destLoc = destination?.coordinate {
            coOrd = destLoc
            imageMarker = Images.destinationMarkerOnJP
        }
    }

    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let url = Bundle.main.url(forResource: "Home_Map", withExtension: "pdf") {
            let viewController: BusNetworkFullViewController = BusNetworkFullViewController.instantiate(appStoryboard: .busNetwork)
            viewController.url = url
            viewController.isStaticMapLoading = false
            viewController.pdfData = self.pdfData
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    @IBAction func favoriteRouteButtonTapped(_ sender: Any) {
        guard let origin = self.origin, let destination = self.destination else { return }
        if favoriteRouteButton.currentImage == Images.ptAddToFavorite {
            viewModel.saveRoute(source: origin, destination: destination)
            favoriteRouteButton.setImage(Images.ptAddedToFavorite, for: .normal)
        } else {
            viewModel.removeRoute(source: origin, destination: destination)
            favoriteRouteButton.setImage(Images.ptAddToFavorite, for: .normal)
        }
    }
    
    func setBackgroundViewNil() {
        //self.availableRoutesTableView.backgroundView = nil
    }
    
}

extension AvailableRoutesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.favRoutesTableView {
            return 1
        }
        else {
             
                return self.didFetchData ? cellViewModels.count : 3
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.favRoutesTableView {
            return self.favoriteRoutes?.count ?? 0 <= 0 ? 1 : self.favoriteRoutes?.count ?? 0
        } else {
            if section == 0 {
              return 1
            }
            else if didFetchData, selectedSection == section {
                if arrayOfStopsIndexPath.count > 0 {
                    return cellViewModels[section].routeCellViewModels.count + arrayOfStopsIndexPath.count + 2
                } else {
                    return cellViewModels[section].routeCellViewModels.count + 2
                }
            }
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == favRoutesTableView {
            return CGFloat.leastNormalMagnitude
        }
        return self.didFetchData == false ? 0: (section == 0) ? cellSpacingHeight : cellSpacingHeightWithCOntent
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.favRoutesTableView {
            return 120
        }
        else if indexPath.section == 0 {
            return 350
        }
        let height = indexPath.section == selectedSection ? UITableView.automaticDimension : UITableView.automaticDimension
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return tableView.tempHeaderView()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        if tableView == favRoutesTableView {
            if self.favoriteRoutes?.count ?? 0 > 0 {
                return setupCellForFavouritesRoute(indexPath: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
                cell?.textLabel?.text = Constants.noFavorites.localized
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.font = Fonts.CodecRegular.eighteen
                cell?.accessoryView = nil
                return cell ?? UITableViewCell()
            }
        } else if indexPath.section == 0 {
            let cell:RouteSelectJPTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.delegate = self
            
            return cell
        } else {
            if selectedSection == indexPath.section, didFetchData {
                
                let rowsCountForSection = tableView.numberOfRows(inSection: indexPath.section)
                
                if indexPath.row == 0 {
                    let cell: MapTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                    if let mapCellViewModel = cellViewModels[indexPath.section].mapCellViewModel {
                        cell.configure(with: mapCellViewModel)
                        cell.selectTapped = { [weak self] journey in
                            self?.selectTapped(journey, index: indexPath.section)
                        }
                        cell.shareTapped = { [weak self] data in
                            self?.shareTapped(data: data)
                        }
                        cell.addMarker(locationData: origin!)
                        cell.addMarker(locationData: destination!)
                        cell.buttonBuyTapped = buttonBuyTapped
                        cell.contentView.uperTwoCornerMask(radius: 10)
                    }
                    cell.delegate = self
                    return cell
                } else if indexPath.row == rowsCountForSection-1{
                    let cell:BuyButtonTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                    cell.buttonBuyTapped = buttonBuyTapped
                    return cell
                } else{
                    let cell: RouteTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                    var showBottom: Bool = false
                    if (cellViewModels[indexPath.section].routeCellViewModels.count) == indexPath.row {
                        showBottom = true
                    }
                    if let routeCellViewModel = cellViewModels[indexPath.section].routeCellViewModels[safe: indexPath.row - 1] {
                        let isExpanded = selectedRow == indexPath.row
                        cell.configure(with: routeCellViewModel, selectedRow: selectedRow, currentRow: indexPath.row, isExpanded: isExpanded, showBottom: showBottom)
                    }
                    cell.delegate = self
                    return cell
                }
            } else {
                let cell: AvailableRouteTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                if let cellViewModel = cellViewModels[safe: indexPath.section] {
                    cell.configure(with: cellViewModel)
                }
                cell.delegate = self
                cell.buttonBuyTapped = buttonBuyTapped
                cell.layoutIfNeeded()
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.favRoutesTableView {
            if self.favoriteRoutes?.count ?? 0 <= 0 {
                return
            }
            tapOnFavouriteRoutes(indexPath: indexPath)
        } else {
            let selection = (selectedSection == indexPath.section) ?  nil : indexPath.section
            selectedSection = selection
            selectedRow = -1
            selectedStopsExpandModels.removeAll()
            availableRoutesTableView.reloadData()
            availableRoutesTableView.hideLoader()
            
            if let section = selectedSection, section >= 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: false)
            }
        }
    }

    private func selectTapped(_ journey: Journey, index: Int) {
        if let legs = journey.legs {
            let viewController: LiveTrackerViewController = LiveTrackerViewController.instantiate(appStoryboard: .availableRoutes)
            viewController.legs = legs
            viewController.cellViewModels = self.cellViewModels[index].routeCellViewModels
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func buttonBuyTapped() {
        if AppDefaults.shared.isUserLoggedIn {
            let fareMediaViewController = FareMediaViewController()
            fareMediaViewController.isBackButtonPresent = true
            self.navigationController?.pushViewController(fareMediaViewController, animated: true)
        } else {
            let viewController = LoginViewController.instantiate(appStoryboard: .authentication)
            loginRootView = .myAccount
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }

    private func shareTapped(data: [String: Any]) {
        if let map = data["map"] as? UIImage,
           let route = data["route"] as? String {
            let viewController = UIActivityViewController(activityItems: [route, map],
                                                          applicationActivities: [])
            self.present(viewController, animated: true)
        }
    }
}

extension AvailableRoutesViewController: ProceedButtonDelegate {
    
    func reloadTableView(hideData: Bool) {
        //isProccedButtonVisible = hideData
        //self.availableRoutesTableView.reloadData()
        //self.sourceDestinationViewSetup()
    }

    func didTapProceed() {
        self.availableRoutesTableView.backgroundView = nil
        if isSourceDestinationSelected() && self.origin?.id ?? "" == self.destination?.id ?? "" {
            self.showCustomAlert(alertTitle: "", alertMessage: Constants.sameSourceDestinationMessage.localized,
                                 firstActionTitle: ok, firstActionStyle: .default)
        } else {
            self.didTapProceedValidation()
            //sourceDestinationViewSetup()
        }
    }
    
    func didTapProceedValidation() {
        //proceedButtonView.hide()
        hideProceedButton()
        selectedRow = -1
        selectedSection = -1
       // filterView.isHidden = true
        self.didFetchData = false
       // shimmerTableView()
        
        if isSourceDestinationSelected() {
            searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.sourceStopModel?.id ?? emptyString) {[weak self] gmsPlace in
                DispatchQueue.main.async {
                    if let gmsPlace = gmsPlace, self?.origin?.id == gmsPlace.placeID {
                        self?.origin?.coordinate = gmsPlace.coordinate
                    }
                    self?.fetchRouteOnDidTapProceed()
                }
            }
        } else if self.destination?.coordinate == nil && self.origin?.coordinate != nil {
            searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.destination?.id ?? emptyString) {[weak self] gmsPlace in
                DispatchQueue.main.async {
                    if let gmsPlace = gmsPlace, self?.destination?.id == gmsPlace.placeID {
                        self?.destination?.coordinate = gmsPlace.coordinate
                    }
                    self?.fetchRouteOnDidTapProceed()
                }
            }
        } else if self.destination?.coordinate == nil && self.origin?.coordinate == nil {
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.origin?.id ?? emptyString) {[weak self] gmsPlace in
                DispatchQueue.main.async {
                    if let gmsPlace = gmsPlace, self?.origin?.id == gmsPlace.placeID {
                        self?.origin?.coordinate = gmsPlace.coordinate
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.enter()
            searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.destination?.id ?? emptyString) {[weak self] gmsPlace in
                DispatchQueue.main.async {
                    if let gmsPlace = gmsPlace, self?.destination?.id == gmsPlace.placeID {
                        self?.destination?.coordinate = gmsPlace.coordinate
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.fetchRouteOnDidTapProceed()
                }
            }
            
        } else {
            fetchRouteOnDidTapProceed()
        }
    }
    
    func fetchRouteOnDidTapProceed() {
        self.fetchRoute()
        if let origin = self.origin, let destination = self.destination {
            if viewModel.isRouteFavorite(source: origin, destination: destination) {
                //favoriteRouteButton.setImage(Images.ptAddedToFavorite, for: .normal)
            } else {
                //favoriteRouteButton.setImage(Images.ptAddToFavorite, for: .normal)
            }
        }
    }
    
}

extension AvailableRoutesViewController: RouteSelectionViewDelegate {
    
    func tableViewPresented(for searchBar: SearchBars) {
        isProccedButtonVisible = true
        self.availableRoutesTableView.reloadData()
    }
    
    func didSelectLeaveArriveButton() {
        // Do Something
    }
    
    func buttonHomeWorkFavPressed(placeType: PlaceType) {
        
        if placeType == .favorite {
            
            let viewController: FavoritesViewController = FavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
            viewController.placeType = placeType
            viewController.travelPreferenceModel = self.travelPreferencesModel
            viewController.favoritesViewDelegate = self
            
            if favoriteRoutesView.isHidden == false {
                favoriteRoutesView.isHidden = true
            } else {
                favoriteRoutesView.isHidden = false
                favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
            }
            DispatchQueue.main.async {
                self.favRoutesTableView.reloadData()
            }

            self.availableRoutesTableView.reloadData()
//            self.favoriteRoutesView.myFavTableView.reloadData()
//            self.favView = viewController.view
//            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
            viewController.placeType = placeType
            viewController.travelPreferenceModel = self.travelPreferencesModel
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func addToFavButtonTapped() {
        if self.origin == nil || self.destination == nil {
            self.showCustomAlert(alertTitle: "", alertMessage: Constants.favoriteRouteErrorMessage.localized, firstActionTitle: ok.localized, firstActionStyle: .cancel, firstActionHandler: nil)
        } else {
            guard let origin = self.origin, let destination = self.destination else { return }
            
            //if viewModel.isSourceAndDestinationSame(source: origin, destination: destination) {
            if self.routeSelectionView.originSearchBar.text != emptyString && self.routeSelectionView.destinationSearchBar.text != emptyString && self.origin?.id ?? "" == self.destination?.id ?? "" {

                self.showCustomAlert(alertTitle: "",
                                     alertMessage: Constants.sameSourceDestinationMessage.localized,
                                     firstActionTitle: ok.localized)
                return
            }
            
            if routeSelectionView.imagePreferences.image == Images.ptAddToFavorite {
                viewModel.saveRoute(source: origin, destination: destination)
                routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
            } else {
                viewModel.removeRoute(source: origin, destination: destination)
                routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
            }
        }
        
        if favoriteRoutesView.isHidden == false {
            DispatchQueue.main.async {
                self.favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
                self.favRoutesTableView.reloadData()
            }
        }
        
//        if favoriteRoutesView.isHidden == false {
//            favRoutesTableView.reloadData()
//        }
    }
    
    func selectRouteOpen()  {
        let routeSelectionViewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
        //routeSelectionViewController.navigationItem.backBarButtonItem?.title = " "
        //routeSelectionViewController.hidesBottomBarWhenPushed = true
        //routeSelectionViewController.travelPreferenceModel = travelPreferenceModal
        self.modalPresentationStyle = .automatic
        //self.present(routeSelectionViewController, animated: true)
        let navigationController = UINavigationController(rootViewController: routeSelectionViewController)
        routeSelectionViewController.routeSelectionDelegate = self
        self.present(navigationController, animated: false)
        //self.navigationController?.pushViewController(routeSelectionViewController, animated: true)
    }
    func searchCancelled(for searchBar: SearchBars, searchBarField: UISearchBar, isBeginEditing: Bool) {
        favoriteRoutesView.isHidden = true
        
        AF.session.getTasksWithCompletionHandler { dataTask, uploadTask, downloadTask in
            downloadTask.forEach({$0.cancel()})
        }

        for view in self.view.subviews {
            if view.isKind(of: UIActivityIndicatorView.self) {
                view.removeFromSuperview()
            }
        }
        
        if !isBeginEditing {
            clearLocationData(for: searchBar)
        }
    }
    
    func clearLocationData(for searchBar: SearchBars) {
        switch searchBar {
        case .origin:
            self.origin = nil
        case .destination:
            self.destination = nil
        }
        self.dataChanged = false
    }
    
    func swapLocationData() {
        if isOriginAndDestinationAvailable {
            (origin, destination) = (destination, origin)
            dataChanged = true
            //proceedButtonView.show()
            self.setBackgroundViewNil()
        } else if isOriginAvailable {
            self.destination = origin
            self.origin = nil
            dataChanged = false
        } else if isDestinationAvailable {
            self.origin = destination
            self.destination = nil
            dataChanged = false
        }
        
        guard let origin = self.origin, let destination = self.destination else { return }
        if viewModel.isRouteFavorite(source: origin, destination: destination) {
            routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
        } else {
            routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
        }
        
    }
    
    func didTapButton(tag: Int) {
        if favoriteRoutesView.isHidden == false {
            DispatchQueue.main.async {
                self.favoriteRoutesView.isHidden = true
                self.favRoutesTableView.reloadData()
            }
        }
        switch tag {
        case 0:
            swapLocationData()
        case 10:
            self.redirectToMapSelectionViewController(sourceType: .origin)
        case 11:
            self.redirectToMapSelectionViewController(sourceType: .destination)
        default:
            return
        }
        //proceedButtonView.show()
    }
    
    private func redirectToMapSelectionViewController(sourceType: SelectionType) {
        
        if sourceType == .origin && self.origin?.coordinate == nil {
            self.routeSelectionView.originSearchBar.isLoading = true
            searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.origin?.id ?? emptyString) {[weak self] gmsPlace in
                DispatchQueue.main.async {
                    self?.routeSelectionView.originSearchBar.isLoading = false
                    if let gmsPlace = gmsPlace, self?.origin?.id == gmsPlace.placeID {
                        self?.origin?.coordinate = gmsPlace.coordinate
                    }
                    self?.redirectToMapScreen(sourceType: sourceType)
                }
            }
        } else if sourceType == .destination && self.destination?.coordinate == nil {
            self.routeSelectionView.destinationSearchBar.isLoading = true
            searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.destination?.id ?? emptyString) {[weak self] gmsPlace in
                DispatchQueue.main.async {
                    self?.routeSelectionView.destinationSearchBar.isLoading = false
                    if let gmsPlace = gmsPlace, self?.destination?.id == gmsPlace.placeID {
                        self?.destination?.coordinate = gmsPlace.coordinate
                    }
                    self?.redirectToMapScreen(sourceType: sourceType)
                }
            }
        } else {
            self.redirectToMapScreen(sourceType: sourceType)
        }
    }
    
    
    private func redirectToMapScreen(sourceType: SelectionType) {
        let locationSelectionOnMapController: LocationSelectionOnMapController = LocationSelectionOnMapController.instantiate(appStoryboard: .home)
        let locationModel = LocationSelectionModel(sourceType: sourceType, origin: self.origin, destination: self.destination)
        locationSelectionOnMapController.locationModel = locationModel
        locationSelectionOnMapController.delegate = self
        self.navigationController?.pushViewController(locationSelectionOnMapController, animated: true)
    }
    

    func didSelectPlace(for type: SearchBars, location: LocationData) {
        
        switch type {
        case .origin:
            self.origin = location
        case .destination:
            self.destination = location
        }
        if self.origin != nil && self.destination != nil {
           // self.proceedButtonView.show()
            self.setBackgroundViewNil()
        }
        
        let recentSearch = RecentSearch(id: location.id, location: location.subAddress, address: "", latitude: location.coordinate?.latitude, longitude: location.coordinate?.longitude, type: Constants.coordinate)
        if isPlaceSaved(location: recentSearch) {
            RecentSearchDataRepository.shared.delete(record: recentSearch)
        }
        RecentSearchDataRepository.shared.create(record: recentSearch)
        
        guard let origin = self.origin, let destination = self.destination else { return }
        if viewModel.isRouteFavorite(source: origin, destination: destination) {
            routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
        } else {
            routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
        }
        
    }
    
    func isPlaceSaved(location: RecentSearch) -> Bool {
        if let savedData = RecentSearchDataRepository.shared.fetchAll(),
           savedData.contains(location) {
            return true
        }
        return false
    }

    func didSelectPreference() {
        //proceedButtonView.show()
       // self.setBackgroundViewNil()
    }

    func didSelect(preferences: SearchPreference) {
        // Do Something
    }
    
    
    //MARK:UIButton Actions
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonBackTapFavoriteView(_ sender: Any) {
        hideFavouiteView()
    }
    @IBAction func buttonAddFaouriteRoutes(_ sender: Any) {
        guard let origin = self.origin, let destination = self.destination else { return }
        viewModel.saveRoute(source: origin, destination: destination)
    }
    
    @IBAction func buttonSavedFaouriteRoutes(_ sender: Any) {
       showFavouriteView()
    }
    
    @IBAction func buttonSourceTap(_ sender: Any) {
        self.selectRouteOpen()
        buttonSource.isSelected = true
        buttonSource.isEnabled = false
    }
    
    @IBAction func buttonDestinationTap(_ sender: Any) {
        self.selectRouteOpen()
        buttonSource.isSelected = false
        buttonSource.isEnabled = true
    }
    
    @IBAction func buttonSwapStaionsTap(_ sender: Any) {
        if sourceStopModel != nil && destinationStopModel != nil{
            mapView.clear()
            let sourceModel = sourceStopModel
            sourceStopModel = destinationStopModel
            destinationStopModel = sourceModel
            setSelectedStopOnLabel()
            
            let orginLocationModel = self.origin
            self.origin = self.destination
            destination = orginLocationModel
            fetchRoute()
            
        }
    }
    @IBAction func buttonProceedTap(_ sender: Any) {
        didTapProceed()
    }
    
    func hideProceedButton()  {
        proceedButtonConstraintHeight.constant = 0
        buttonProceed.titleLabel?.isHidden = true
        buttonProceed.isHidden = true
        isFromViewDidLoad = false
    }
}

extension AvailableRoutesViewController: RouteTableViewCellDelegate {
    
    func stopLabelClicked(cell: UITableViewCell, stopSequences: [StopSequenceModel]?) {
        guard let indexPath = self.availableRoutesTableView.indexPath(for: cell) else { return }
        if selectedRow == indexPath.row {
            selectedRow = -1
        } else {
            selectedRow = indexPath.row
        }
        availableRoutesTableView.reloadData()
    }
    
}

extension AvailableRoutesViewController {

    @objc func infoTapped(_ notification: NSNotification) {
        self.showCustomAlert(alertTitle: Constants.info,
                             alertMessage: Constants.info,
                             firstActionTitle: ok)
    }
}

extension AvailableRoutesViewController: MapTableViewCellDelegate {
    
    func infoButtonClicked(cell: UITableViewCell, fare: Fare?) {
        if let fare = fare, let tickets = fare.tickets, tickets.count > 0 {
            
            let fare = "\(tickets.first??.properties?.priceTotalFare ?? "0")\(Constants.currencyTitle.localized)"
            let fareValue = fare == "0\(Constants.currencyTitle.localized)" ? emptyString : fare
            let passName = tickets[0]?.name ?? emptyString
            
            self.showCustomAlert(alertTitle: passName,
                                 alertMessage: fareValue,
                                 firstActionTitle: ok)
        }
    }
    
}

extension AvailableRoutesViewController: RouteSelectionViewBackButtonDelegate {
    func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AvailableRoutesViewController: TravelPreferenceViewControllerDelegate {
    
    func updatedTravelPreferences(modal: TravelPreferenceModel) {
        if travelPreferencesModel != modal {
            travelPreferencesModel = modal
            if self.origin != nil && self.destination != nil {
                self.dataChanged = true
            }
        }
    }
    
}

extension AvailableRoutesViewController: FavoritesViewDelegate {
    
    func favoritePopWithData(viewModel: AvailableRoutesViewModel, origin: LocationData, destination: LocationData, travelPreference: TravelPreferenceModel?, data: RouteSelectionViewData?) {
        self.viewModel = viewModel
        self.origin = origin
        self.destination = destination
        self.travelPreferencesModel = travelPreference ?? nil
        self.routeSelectionView.originSearchBar.text = routeSelectionViewData?.originSearchText
        self.routeSelectionView.destinationSearchBar.text = routeSelectionViewData?.destinationSearchText
        self.didTapProceedValidation()
    }
    
}

extension AvailableRoutesViewController: LocationSelectionOnMapDelegate {
    
    func didSelectOnMap(selectedModel: LocationSelectionModel?) {
        if let selectedModel = selectedModel {
            switch selectedModel.sourceType {
            case .origin:
                if self.origin != selectedModel.origin {
                    self.dataChanged = true
                }
                self.origin = selectedModel.origin
                self.routeSelectionView.originSearchBar.text = selectedModel.origin?.subAddress ?? selectedModel.origin?.address ?? ""
            case .destination:
                if self.destination != selectedModel.destination {
                    self.dataChanged = true
                }
                self.destination = selectedModel.destination
                self.routeSelectionView.destinationSearchBar.text = selectedModel.destination?.subAddress ?? selectedModel.destination?.address ?? ""
            }
            
            guard let origin = self.origin, let destination = self.destination else { return }
            if viewModel.isRouteFavorite(source: origin, destination: destination) {
                routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
            } else {
                routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
            }
            
        }
    }
    
}

extension AvailableRoutesViewController {
    private func setupCellForFavouritesRoute(indexPath: IndexPath) -> UITableViewCell {
        let cell = favRoutesTableView.dequeueReusableCell(withIdentifier: FavoriteRouteTableViewCell.identifier, for: indexPath) as? FavoriteRouteTableViewCell
        if let favoriteRoutes = self.favoriteRoutes {
            if let source = favoriteRoutes[indexPath.row].sourceAddress, let destination = favoriteRoutes[indexPath.row].destinationAddress {
                cell?.source.attributedText = Utilities.shared.getAttributedText(source, nil,Fonts.CodecRegular.twelve)
                cell?.destination.attributedText = Utilities.shared.getAttributedText(destination, nil, Fonts.CodecRegular.twelve)
                cell?.labelRouteNumber.text = "\(Constants.route.localized)\(indexPath.row+1)"
                cell?.labelRouteNumber.setAlignment()
                cell?.labelBusStop.isHidden = true
                cell?.source.textColor = Colors.textGray
                cell?.destination.textColor = Colors.textGray
                cell?.source.setAlignment()
                cell?.destination.setAlignment()
                cell?.deleteButton.tag = indexPath.row
                cell?.deleteButton.addTarget(self, action: #selector(favoriteRouteDeleted(button:)), for: .touchUpInside)
            }
        }
        return cell ?? UITableViewCell()
    }
    
    @objc func favoriteRouteDeleted(button: UIButton) {
        if let favouriteRoute = favoriteRoutes?[button.tag] {
            deleteFavRoute(favoriteRoute: favouriteRoute, at: button.tag)
        }
    }
    
    func deleteFavRoute(favoriteRoute: FavoriteRoute, at: Int) {
        self.showCustomAlert(alertTitle: Constants.deleteFavRouteTitle.localized, alertMessage: Constants.deleteFavRouteMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .cancel, firstActionHandler: {
            FavoriteRouteDataRepository.shared.delete(record: favoriteRoute)
            self.favoriteRoutes?.remove(at: at)
            DispatchQueue.main.async {
                self.favRoutesTableView.reloadData()
                
                guard let origin = self.origin, let destination = self.destination else { return }
                if self.viewModel.isRouteFavorite(source: origin, destination: destination) {
                    self.routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
                } else {
                    self.routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
                }
            }
        }, secondActionHandler: nil)

    }
    
    private func tapOnFavouriteRoutes(indexPath: IndexPath){
        favRoutesTableView.deselectRow(at: indexPath, animated: true)
        favoriteRoutesView.isHidden = true
        guard let favoriteRoutes = self.favoriteRoutes else { return }
        let route = favoriteRoutes[indexPath.row]
        var source = LocationData()
        var destination = LocationData()
        switch favoriteRoutes[indexPath.row].sourceType {
        case coordinate:
            guard let sourceLatitude = route.sourceLatitude?.toDouble(), let sourceLongitude = route.sourceLongitude?.toDouble() else { return }
            source.coordinate = CLLocationCoordinate2D(latitude: sourceLatitude, longitude: sourceLongitude)
            source.type = .coordinate
            source.id = route.sourceId
        case stop:
            if let sourceLatitude = route.sourceLatitude?.toDouble(), let sourceLongitude = route.sourceLongitude?.toDouble() {
                source.coordinate = CLLocationCoordinate2D(latitude: sourceLatitude, longitude: sourceLongitude)
            }
            source.subAddress = route.sourceAddress
            source.id = route.sourceId
            source.type = .stop
        default:
            break
        }
        source.subAddress = route.sourceAddress
        switch favoriteRoutes[indexPath.row].destinationType {
        case coordinate:
            guard let destinationLatitude = route.destinationLatitude?.toDouble(), let destinationLongitude = route.destinationLongitude?.toDouble() else { return }
            destination.coordinate = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
            destination.type = .coordinate
            destination.id = route.destinationId
        case stop:
            if let destinationLatitude = route.destinationLatitude?.toDouble(), let destinationLongitude = route.destinationLongitude?.toDouble() {
                destination.coordinate = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
            }
            destination.subAddress = route.destinationAddress
            destination.id = route.destinationId
            destination.type = .stop
        default:
            break
        }
        destination.subAddress = route.destinationAddress
        routeSelectionViewData?.originSearchText = source.subAddress ?? emptyString
        routeSelectionViewData?.destinationSearchText = destination.subAddress ?? emptyString
        self.travelPreferenceModel = TravelPreferenceModel(busTransport: true, maxTime: .fifteenMin, routePreference: .quickest, walkSpeed: .normal)
        self.favoriteViewPopWithData(viewModel: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: self.travelPreferenceModel, data: routeSelectionViewData)
        
        self.origin = source
        self.destination = destination
        
        setSelectedStopOnLabel()
    }
    
    func favoriteViewPopWithData(viewModel: AvailableRoutesViewModel, origin: LocationData, destination: LocationData, travelPreference: TravelPreferenceModel?, data: RouteSelectionViewData?) {
        self.viewModel = viewModel
        self.origin = origin
        self.destination = destination
        self.travelPreferencesModel = travelPreference ?? nil
        //self.routeSelectionView.originSearchBar.text = routeSelectionViewData?.originSearchText
        //self.routeSelectionView.destinationSearchBar.text = routeSelectionViewData?.destinationSearchText
        self.didTapProceedValidation()
    }
    
    func setupFavoriteRoutes() {
        self.favoriteRoutesView.frame = CGRectMake(0, self.view.frame.size.height+100, self.view.frame.size.width, self.view.frame.size.height)
        self.favoriteRoutesView.isHidden = true
    }
    
    func showFavouriteView()  {
        self.favoriteRoutesView.frame = self.view.frame
        self.favoriteRoutesView.isHidden = false
        favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
        favRoutesTableView.reloadData()
        self.view.addSubview(favoriteRoutesView)
    }
    func hideFavouiteView()  {
        self.setupFavoriteRoutes()
    }
}


extension AvailableRoutesViewController: GMSMapViewDelegate {

    func mapViewSnapshotReady(_ mapView: GMSMapView) {
        if !isMapLoaded {
            //fetchCurrentLocation()
            //configureLocationMarker()
            initialize()
            isMapLoaded = true
        }
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        locationMarker.position = coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let camera = GMSCameraPosition(target: coordinate, zoom: self.mapZoomLevel)
        self.mapView.camera = camera
        GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(latitude),\(longitude)") { (result) in
            guard let address = result?.results?.first?.formattedAddress else { return }
            
            //self.selectedLocation = MapLocation(address: address, subAddress: nil, latitude: latitude, longitude: longitude)
        }
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        locationMarker.position = position.target
        if GMSGeometryContainsLocation(position.target, LocationManager.SharedInstance.path, true) {
           // previousLocation = position.target
        } else {
//            DispatchQueue.main.async {
//                self.showCustomAlert(alertTitle: Constants.locationOutOfRiyadhCityTitle.localized, alertMessage: Constants.locationOutOfRiyadhCity.localized, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
////                    self.mapView.camera = GMSCameraPosition(latitude: self.previousLocation.latitude, longitude: self.previousLocation.longitude, zoom: Constants.mapViewZoomLevel)
//                    //self.locationMarker.position = self.previousLocation
//                }, secondActionHandler: nil)
//            }
        }
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        locationMarker.position = position.target
        let latitude = position.target.latitude
        let longitude = position.target.longitude
        GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(latitude),\(longitude)") { (result) in
            guard let address = result?.results?.first?.formattedAddress else { return }
           // self.locationLabel.text = "Selected Location:\n\(address)"
           // self.selectedLocation = MapLocation(address: address, subAddress: nil, latitude: latitude, longitude: longitude)
        }
    }
    
    func isValidforProceedButton() ->Bool {
       return isSourceDestinationSelected() && (origin?.coordinate != destination?.coordinate)
    }
    
    func setSelectedStopOnLabel()  {
        sourceDestinationViewSetup()
        let indexPath = NSIndexPath(row: 0, section: 0)
        
        let cell = cellRouteSelectJP()
        
        print("source = \(sourceStopModel?.location ?? "") , Destination\(destinationStopModel?.location ?? "")")
            cell.labelSource.text = origin?.subAddress ?? Constants.enterOrigin.localized
            cell.labelDestination.text = destination?.subAddress ?? Constants.selectYourDestination
       
       configureLocationMarker()
        
        
    }
    func cellRouteSelectJP() -> RouteSelectJPTableViewCell {
        let indexPath = NSIndexPath(row: 0, section: 0)
        
        let cell:RouteSelectJPTableViewCell = availableRoutesTableView.cellForRow(at: indexPath as IndexPath) as! RouteSelectJPTableViewCell
        return cell
    }
    func proccedButtonEnableDisable()  {
        if sourceStopModel != nil && destinationStopModel != nil {
            //proceedButtonView.show()
            //proceedButtonView.isHidden = false
        }else{
            //proceedButtonView.hide()
            //proceedButtonView.isHidden = true
        }
        
    }
}

extension AvailableRoutesViewController:RouteStopSelectionDelegate {
func stopSelectedFromSearchList(selectedStop:RecentSearch,locationData:LocationData){
    var imageMarker = Images.sourceMarkerOnJP
   
        if buttonSource.isSelected {
            sourceStopModel = selectedStop
            self.origin = locationData
        }else{
            destinationStopModel = selectedStop
            self.destination = locationData
            imageMarker = Images.destinationMarkerOnJP
        }
    
      setSelectedStopOnLabel()
        proccedButtonEnableDisable()
    
    }
}

extension AvailableRoutesViewController:RouteSelectJPHeaderCellDelegate{
    
    func buttonProceedTaped(button:UIButton){
    didTapProceed()
        
    }
    func buttonSourceTaped(buttn:UIButton){
        self.selectRouteOpen()
        buttonSource.isSelected = true
    }
    func buttonDestinationTaped(button:UIButton){
        buttonSource.isSelected = false
        self.selectRouteOpen()
    }
    func buttonAddToFavourite(buttn:UIButton){
        guard let origin = self.origin, let destination = self.destination else { return }
        viewModel.saveRoute(source: origin, destination: destination)
    }
    func buttonSavedFavourite(buttn:UIButton){
        showFavouriteView()
    }
    func buttonSwapLocation(buttn:UIButton){
        if sourceStopModel != nil && destinationStopModel != nil{
            mapView.clear()
            let sourceModel = sourceStopModel
            sourceStopModel = destinationStopModel
            destinationStopModel = sourceModel
            
            
            let orginLocationModel = self.origin
            self.origin = self.destination
            destination = orginLocationModel
            setSelectedStopOnLabel()
            fetchRoute()
            
        }
    }
}
