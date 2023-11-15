//
//  SelectOriginDestinationViewController.swift
//  RCRC
//
//  Created by Errol on 16/07/20.
//

import UIKit
import CoreLocation
import Alamofire

//Protocol StopSelectionDelegate:AnyObject {
//    
//    func stopSelected(stopName:RecentSearch)
//
//}
protocol RouteStopSelectionDelegate: AnyObject {
    func stopSelectedFromSearchList(selectedStop:RecentSearch,locationData:LocationData)
}

class RouteSelectionViewController: UIViewController {

    @IBOutlet weak var routeSelectionView: RouteSelectionView!
    @IBOutlet weak var routeSelectionTableView: UITableView!
    @IBOutlet weak var selectLocationPopup: UIView!
    @IBOutlet weak var selectLocationPopupHeight: NSLayoutConstraint!
    @IBOutlet weak var proceedButtonView: ProceedButtonView!
    @IBOutlet weak var routeSelectionTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var headerLeftImage: UIImageView!
    @IBOutlet weak var headerTitleBackgroundImage: UIImageView!
    weak var routeSelectionDelegate:RouteStopSelectionDelegate?
    
    
    let routeSelectionTableDataSource = RouteSelectionTableDataSource()
    var travelPreferenceModel: TravelPreferenceModel? = nil
    var travelPreferencesViewModel = TravelPreferencesViewModel()
    var selectedSearchPreferences: SelectedSearchPreferences!
    
    let searchResultsViewModel = SearchResultsViewModel()
    var activityIndicator: UIActivityIndicatorView?
    let availableRouteViewModel = AvailableRoutesViewModel()
    var isBothOriginDestinationTapped: Bool = false
    
    var origin: LocationData? {
        didSet {
            if isViewLoaded {
                		showProceedButton(true)
            }
        }
    }
    var destination: LocationData? {
        didSet {
            if isViewLoaded {
                showProceedButton(true)
            }
        }
    }
    var activeSearchBar: UISearchBar?
    var searchPreferences = SearchPreference()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .routesSelection)
        configureTableViewCells()
        configureDelegates()
        configureDataSources()
        self.selectLocationPopupHeight.constant = Constants.selectLocationCollapsedHeight
        self.routeSelectionTableView.backgroundColor = Colors.white
        configureProceedView()
        self.routeSelectionTableView.allowsSelection = true
//        initializeRouteSelectionView()
        routeSelectionView.initialize()
        self.disableLargeNavigationTitleCollapsing()
        headerTitle.text = Constants.planATrip.localized
        if #available(iOS 15.0, *) {
            self.routeSelectionTableView.sectionHeaderTopPadding = CGFloat.leastNormalMagnitude
        } else {
            // Fallback on earlier versions
        }
        
        self.selectedSearchPreferences = SelectedSearchPreferences()
        self.headerLeftImage.image = self.headerLeftImage.image?.setNewImageAsPerLanguage()
        self.headerTitleBackgroundImage.image = self.headerTitleBackgroundImage.image?.setNewImageAsPerLanguage()
        routeSelectionView.backButtonDelegate = self
    }
    
    /*
    private func initializeRouteSelectionView() {
        if destination != nil {
            routeSelectionView.destinationSearchBar.text = destination?.address
            routeSelectionView.endEditing(true)
            showProceedButton(true)
        } else {
            routeSelectionView.destinationSearchBar.becomeFirstResponder()
        }
        if origin != nil {
            routeSelectionView.originSearchBar.text = origin?.address
            routeSelectionView.endEditing(true)
            showProceedButton(true)
        } else {
            self.routeSelectionView.originSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation.localized, attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
            DispatchQueue.global(qos: .utility).async {
                DispatchQueue.main.async {
                    self.fetchCurrentLocation()
                }
            }
        }
    }
     */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configureNavigationBar(title: Constants.planATrip.localized)
        //routeSelectionView.refresh()
        self.setAlphaAtDidTapProceed(apiCalledFinish: true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.routeSelectionTableDataSource.favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()

        if travelPreferenceModel == nil {
            self.travelPreferenceModel = TravelPreferenceModel(busTransport: true, maxTime: .fifteenMin, routePreference: .quickest, walkSpeed: .normal)
        }
        
        guard let origin = self.origin, let destination = self.destination else { return }
        if availableRouteViewModel.isRouteFavorite(source: origin, destination: destination) {
            routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
        } else {
            routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        routeSelectionTableView.reloadData()
    }
    
    func fetchCurrentLocation() {
        
        if self.routeSelectionView.originSearchBar != nil {
            self.routeSelectionView.originSearchBar.isLoading = true
            self.routeSelectionView.originSearchBar.isUserInteractionEnabled = false
        }
        
        LocationManager.SharedInstance.fetchCurrentLocationWithDefaultLocation { [weak self] (location, currentLocationDetect) in
            let data = LocationData(id: location.id,
                                    address: location.address,
                                    subAddress: location.subAddress,
                                    coordinate: location.coordinate,
                                    type: .coordinate)
            self?.origin = data
            DispatchQueue.main.async {
                self?.routeSelectionView.originSearchBar.isLoading = false
                self?.routeSelectionView.originSearchBar.isUserInteractionEnabled = true
                if currentLocationDetect {
                    self?.routeSelectionView.originSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation.localized,
                                                                                           attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
                } else {
                    self?.routeSelectionView.originSearchBar.textField?.text = "\(data.address ?? emptyString) \(data.subAddress ?? emptyString)"
                }
            }
        }
    }

    func configureProceedView() {
        self.proceedButtonView.delegate = self
        self.proceedButtonView.alpha = 0.0
        self.proceedButtonView.isHidden = true
        self.view.bringSubviewToFront(self.proceedButtonView)
    }

    func configureDataSources() {
        self.routeSelectionTableView.dataSource = routeSelectionTableDataSource
    }

    func configureTableViewCells() {
        self.routeSelectionTableView.register(QuickSelectTableViewCell.nib, forCellReuseIdentifier: QuickSelectTableViewCell.identifier)
        self.routeSelectionTableView.register(SelectLocationOnMapTableViewCell.nib, forCellReuseIdentifier: SelectLocationOnMapTableViewCell.identifier)
        self.routeSelectionTableView.register(RecentSearchTableViewCell.nib, forCellReuseIdentifier: RecentSearchTableViewCell.identifier)
        self.routeSelectionTableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: EmptyTableViewCell.identifier)
        self.routeSelectionTableView.register(DividerTableCell.self)
        self.routeSelectionTableView.registerHeaderFooterViewNib(RecentSearchHeaderView.self)
        self.routeSelectionTableView.register(FavoriteRouteTableViewCell.nib, forCellReuseIdentifier: FavoriteRouteTableViewCell.identifier)
    }

    func configureDelegates() {
        self.routeSelectionTableView.delegate = routeSelectionTableDataSource
        self.routeSelectionView.delegate = self
        routeSelectionTableDataSource.delegate = self
    }

    @IBAction func useCurrentLocationButtonTapped(_ sender: Any) {
        if selectLocationPopupHeight.constant == Constants.selectLocationExpandedHeight {
            UIView.animate(withDuration: 0.3) {
                self.selectLocationPopupHeight.constant = Constants.selectLocationCollapsedHeight
                DispatchQueue.global(qos: .utility).async {
                    if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        DispatchQueue.main.async {
                            self.fetchCurrentLocation()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showCustomAlert(alertTitle: Constants.noLocationAlertTitle.localized,
                                                 alertMessage: Constants.noLocationAlertMessage.localized,
                                                 firstActionTitle: Constants.goToSettings.localized,
                                                 secondActionTitle: cancel,
                                                 firstActionHandler: {
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                                }
                            }, secondActionHandler: nil)
                        }
                    }
                }
                self.routeSelectionView.endEditing(true)
            }
        }
    }

    func showProceedButton(_ bool: Bool) {
        if origin != nil, destination != nil, bool {
            self.routeSelectionTableViewBottomConstraint.constant = 70
            self.proceedButtonView.alpha = 1.0
            //self.proceedButtonView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.selectLocationPopupHeight.constant = Constants.selectLocationCollapsedHeight
            }
        } else {
            //self.routeSelectionTableViewBottomConstraint.constant = 24
            self.proceedButtonView.alpha = 0.0
            self.proceedButtonView.isHidden = true
        }
    }

    func clearLocationData(for searchBar: SearchBars) {
        switch searchBar {
        case .origin:
            self.origin = nil
        case .destination:
            self.destination = nil
        }
        self.showProceedButton(false)
    }

    func swapLocationData() {
        if origin != nil, destination != nil {
            (self.origin, self.destination) = (self.destination, self.origin)
        } else if origin != nil && destination == nil {
            self.destination = self.origin
            self.origin = nil
        } else if origin == nil && self.destination != nil {
            self.origin = self.destination
            self.destination = nil
        }
        
        guard let origin = self.origin, let destination = self.destination else { return }
        if availableRouteViewModel.isRouteFavorite(source: origin, destination: destination) {
            routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
        } else {
            routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
        }
        
    }

    private func showLocationSelectionOverlay() {
        UIView.animate(withDuration: 0.5) {
            (self.selectLocationPopupHeight.constant == Constants.selectLocationCollapsedHeight) ? (self.selectLocationPopupHeight.constant = Constants.selectLocationExpandedHeight) : (self.selectLocationPopupHeight.constant = Constants.selectLocationCollapsedHeight)
        }
    }

    private func hideLocationSelectionOverlay() {
        UIView.animate(withDuration: 0.5) {
            self.selectLocationPopupHeight.constant = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        routeSelectionView.endEditing(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setAlphaAtDidTapProceed(apiCalledFinish: Bool){
        if self.proceedButtonView != nil && self.proceedButtonView.proceedButton != nil {
            self.proceedButtonView.alpha = apiCalledFinish ? 1.0: 0.5
            self.proceedButtonView.proceedButton.isUserInteractionEnabled = apiCalledFinish ? true: false
        }
    }
}

extension RouteSelectionViewController: ProceedButtonDelegate {

    func didTapProceed() {
        routeSelectionTableDataSource.isFavoriteRoutesTapped = false
        if self.routeSelectionView.originSearchBar.text != emptyString && self.routeSelectionView.destinationSearchBar.text != emptyString && self.origin?.id ?? "" == self.destination?.id ?? "" {
            self.showCustomAlert(alertTitle: "", alertMessage: Constants.sameSourceDestinationMessage.localized,
                                 firstActionTitle: ok, firstActionStyle: .default)
        } else {
            
            if self.origin?.coordinate == nil && self.destination?.coordinate != nil {
                activityIndicator = startActivityIndicator()
                self.setAlphaAtDidTapProceed(apiCalledFinish: false)
                
                searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.origin?.id ?? emptyString) {[weak self] gmsPlace in
                    DispatchQueue.main.async {
                        if let gmsPlace = gmsPlace, self?.origin?.id == gmsPlace.placeID {
                            self?.origin?.coordinate = gmsPlace.coordinate
                        }
                        self?.activityIndicator?.stop()
                        self?.setAlphaAtDidTapProceed(apiCalledFinish: true)
                        self?.redirectToAvailableRouteScreen()
                    }
                }
            } else if self.destination?.coordinate == nil && self.origin?.coordinate != nil {
                activityIndicator = startActivityIndicator()
                self.setAlphaAtDidTapProceed(apiCalledFinish: false)
                searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: self.destination?.id ?? emptyString) {[weak self] gmsPlace in
                    DispatchQueue.main.async {
                        if let gmsPlace = gmsPlace, self?.destination?.id == gmsPlace.placeID {
                            self?.destination?.coordinate = gmsPlace.coordinate
                        }
                        self?.activityIndicator?.stop()
                        self?.setAlphaAtDidTapProceed(apiCalledFinish: true)
                        self?.redirectToAvailableRouteScreen()
                    }
                }
            } else if self.destination?.coordinate == nil && self.origin?.coordinate == nil {
                
                let dispatchGroup = DispatchGroup()
                activityIndicator = startActivityIndicator()
                self.setAlphaAtDidTapProceed(apiCalledFinish: false)
                
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
                        self.activityIndicator?.stop()
                        self.setAlphaAtDidTapProceed(apiCalledFinish: true)
                        self.redirectToAvailableRouteScreen()
                    }
                }
                
            } else {
                redirectToAvailableRouteScreen()
            }
        }
    }
    
    func redirectToAvailableRouteScreen() {
        let availableRoutesViewController: AvailableRoutesViewController = AvailableRoutesViewController.instantiate(appStoryboard: .availableRoutes)
        guard let origin = self.origin, let destination = self.destination else { return }
        let availableRoutesViewModel = AvailableRoutesViewModel()
        availableRoutesViewController.initialize(with: availableRoutesViewModel, origin: origin, destination: destination, travelPreference: travelPreferenceModel)
        availableRoutesViewController.selectedSearchPreferences = self.selectedSearchPreferences
        routeSelectionViewData?.originSearchText = routeSelectionView.originSearchBar.text
        routeSelectionViewData?.destinationSearchText = routeSelectionView.destinationSearchBar.text
        if routeSelectionView.originSearchBar.text == Constants.yourCurrentLocation {
            if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                self.navigationController?.pushViewController(availableRoutesViewController, animated: true)
            } else {
                self.showCustomAlert(alertTitle: Constants.noLocationAlertTitle.localized,
                                     alertMessage: Constants.noLocationAlertMessage.localized,
                                     firstActionTitle: Constants.goToSettings.localized,
                                     secondActionTitle: cancel,
                                     firstActionHandler: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
                    }
                }, secondActionHandler: nil)
            }
        } else {
            self.navigationController?.pushViewController(availableRoutesViewController, animated: true)
        }
    }
    
}

extension RouteSelectionViewController: RouteSelectionViewDelegate {
    
    func tableViewPresented(for searchBar: SearchBars) {
        if self.isBothOriginDestinationTapped {
            self.showProceedButton(true)
           // self.routeSelectionDelegate.stopSelected(stopName:sea)
        } else {
            self.showProceedButton(false)
            clearLocationData(for: searchBar)
        }
    }
    
    func didSelectPlace(for type: SearchBars, location: LocationData) {
        switch type {
        case .origin:
            self.origin = location
        case .destination:
            self.destination = location
        }
        
        let recentSearch = RecentSearch(id: location.id, location: location.subAddress, address: "", latitude: location.coordinate?.latitude, longitude: location.coordinate?.longitude, type: Constants.stop)
        if isPlaceSaved(location: recentSearch) {
            RecentSearchDataRepository.shared.delete(record: recentSearch)
        }
        self.routeSelectionTableDataSource.isShowHistoryTapped = false
        RecentSearchDataRepository.shared.create(record: recentSearch)
        self.routeSelectionTableView.reloadData()
        self.routeSelectionDelegate?.stopSelectedFromSearchList(selectedStop: recentSearch, locationData: location)
        
        
        guard let origin = self.origin, let destination = self.destination else { return }
        if availableRouteViewModel.isRouteFavorite(source: origin, destination: destination) {
           // routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
        } else {
           // routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
        }
        
        
    }

    func searchCancelled(for searchBar: SearchBars, searchBarField: UISearchBar, isBeginEditing: Bool) {
        self.isBothOriginDestinationTapped = false
        if routeSelectionTableDataSource.isFavoriteRoutesTapped {
            DispatchQueue.main.async {
                self.routeSelectionTableDataSource.isFavoriteRoutesTapped = false
                self.routeSelectionTableView.reloadData()
            }
        }
        if !isBeginEditing {
            clearLocationData(for: searchBar)
        }
    }
    
    func didTapButton(tag: Int) {
        if routeSelectionTableDataSource.isFavoriteRoutesTapped {
            DispatchQueue.main.async {
                self.routeSelectionTableDataSource.isFavoriteRoutesTapped = false
                self.routeSelectionTableView.reloadData()
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
            break
        }
    }
    
    private func redirectToMapSelectionViewController(sourceType: SelectionType) {
        
        if sourceType == .origin && self.origin?.coordinate != nil {
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
        } else if sourceType == .destination && self.destination?.coordinate != nil {
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

    func isPlaceSaved(location: RecentSearch) -> Bool {
        if let savedData = RecentSearchDataRepository.shared.fetchAll(),
           savedData.contains(location) {
            return true
        }
        return false
    }

    func didSelect(preferences: SearchPreference) {
        self.searchPreferences = preferences
    }
    
    func didSelectLeaveArriveButton() {
        // Do Something
    }
    
    func buttonHomeWorkFavPressed(placeType: PlaceType) {
        
        if placeType == .favorite {
            /*let viewController: FavoritesViewController = FavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
             viewController.placeType = placeType
             viewController.travelPreferenceModel = self.travelPreferenceModel
             self.navigationController?.pushViewController(viewController, animated: true)*/
            
            if routeSelectionTableDataSource.isFavoriteRoutesTapped {
                self.routeSelectionTableDataSource.isFavoriteRoutesTapped = false
            } else {
                routeSelectionTableDataSource.favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
                routeSelectionTableDataSource.isFavoriteRoutesTapped = true
            }
            DispatchQueue.main.async {
                self.routeSelectionTableView.reloadData()
            }
        } else {
            
            switch placeType {
            case .home:
                let homeData = HomeLocationsDataRepository.shared.fetchAll()
                if let homeData = homeData, homeData.count > 0 {
                    setLocationValueToOriginDestination(savedLocation: homeData[0])
                } else {
                    self.redirectToHomeWorkScreen(placeType: placeType)
                }
            case .work:
                let workData = WorkLocationsDataRepository.shared.fetchAll()
                if let workData = workData, workData.count > 0 {
                    setLocationValueToOriginDestination(savedLocation: workData[0])
                } else {
                    self.redirectToHomeWorkScreen(placeType: placeType)
                }
            default:
                break
            }
        }
    }
    
    func setLocationValueToOriginDestination(savedLocation: SavedLocation) {
        
        if let latitude = savedLocation.latitude, let longitude = savedLocation.longitude {
            if routeSelectionView.activeSearchBar == routeSelectionView.originSearchBar {
                routeSelectionView.originSearchBar.text = savedLocation.location ?? emptyString
                origin = LocationData(id: savedLocation.id, address: savedLocation.location, subAddress: savedLocation.address, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), type: savedLocation.type ?? emptyString == Constants.stop ? .stop: .coordinate)
                routeSelectionView.originSearchBar.text = savedLocation.location ?? emptyString
            } else {
                destination = LocationData(id: savedLocation.id, address: savedLocation.location, subAddress: savedLocation.address, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), type: savedLocation.type ?? emptyString == Constants.stop ? .stop: .coordinate)
                routeSelectionView.destinationSearchBar.text = savedLocation.location ?? emptyString
            }
        }
    }
    
    func redirectToHomeWorkScreen(placeType: PlaceType) {
        let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
        viewController.placeType = placeType
        viewController.travelPreferenceModel = self.travelPreferenceModel
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func addToFavButtonTapped() {
        
        if self.origin == nil || self.destination == nil {
            self.showCustomAlert(alertTitle: "", alertMessage: Constants.favoriteRouteErrorMessage.localized, firstActionTitle: ok.localized, firstActionStyle: .cancel, firstActionHandler: nil)
        } else {
            guard let origin = self.origin, let destination = self.destination else { return }
            
            //if availableRouteViewModel.isSourceAndDestinationSame(source: origin, destination: destination) {
            if self.routeSelectionView.originSearchBar.text != emptyString && self.routeSelectionView.destinationSearchBar.text != emptyString && self.origin?.id ?? "" == self.destination?.id ?? "" {

                self.showCustomAlert(alertTitle: "",
                                     alertMessage: Constants.sameSourceDestinationMessage.localized,
                                     firstActionTitle: ok.localized)
                return
            }
            
            if routeSelectionView.imagePreferences.image == Images.ptAddToFavorite {
                availableRouteViewModel.saveRoute(source: origin, destination: destination)
                routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
            } else {
                availableRouteViewModel.removeRoute(source: origin, destination: destination)
                routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
            }
            
            if routeSelectionTableDataSource.isFavoriteRoutesTapped {
                DispatchQueue.main.async {
                    self.routeSelectionTableDataSource.favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
                    self.routeSelectionTableView.reloadData()
                }
            }
        }
    }
}

extension RouteSelectionViewController: TravelPreferenceViewControllerDelegate {
    
    func updatedTravelPreferences(modal: TravelPreferenceModel) {
        travelPreferenceModel = modal
    }
    
}

extension RouteSelectionViewController: QuickSelectionDelegate {

    func didSelectPlace(_ place: RecentSearch?) {
        guard let place = place else { return }
        var coordinate: CLLocationCoordinate2D?
        if let latitude = place.latitude, let longitude = place.longitude {
            coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        }
        let data = LocationData(id: place.id, address: place.location, subAddress: place.location ?? place.address ?? "", coordinate: coordinate, type: .stop)
        if routeSelectionView.activeSearchBar == routeSelectionView.originSearchBar {
            origin = data
            routeSelectionView.originSearchBar.text = place.location
        } else {
            destination = data
            routeSelectionView.destinationSearchBar.text = place.location
        }
        
        SSLRestConfig.manager.session.getAllTasks { sslRestConfig in
            sslRestConfig.forEach({$0.cancel()})
        }
        
        RestConfig.manager.session.getAllTasks { restConfig in
            restConfig.forEach({$0.cancel()})
        }
        
        routeSelectionDelegate?.stopSelectedFromSearchList(selectedStop: place, locationData: data)
        backButtonAction()
        guard let origin = self.origin, let destination = self.destination else { return }
        
        self.isBothOriginDestinationTapped = true
        proceedButtonView.alpha = 1.0
       // proceedButtonView.isHidden = false
        if availableRouteViewModel.isRouteFavorite(source: origin, destination: destination) {
            routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
        } else {
            routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
        }
        
        
    }

    func navigateTo(_ type: PlaceType) {
        let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
        viewController.placeType = type
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func selectLocationOnMapTapped() {
        let locationSelectionUsingMapViewController: LocationSelectionUsingMapViewController = LocationSelectionUsingMapViewController.instantiate(appStoryboard: .home)
        if self.routeSelectionView.originSearchBar.text == Constants.yourCurrentLocation {
            locationSelectionUsingMapViewController.isSourceCurrentLocation = true
        } else {
            locationSelectionUsingMapViewController.isSourceCurrentLocation = false
            if let latitude = origin?.coordinate?.latitude, let longitude = origin?.coordinate?.longitude {
                locationSelectionUsingMapViewController.source.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            }
        }
        if let latitude = destination?.coordinate?.latitude, let longitude = destination?.coordinate?.longitude {
            locationSelectionUsingMapViewController.destination.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        }
        locationSelectionUsingMapViewController.searchPreferences = self.selectedSearchPreferences
        self.navigationController?.pushViewController(locationSelectionUsingMapViewController, animated: true)
    }
    
    func recentSearchDeleted(recentSearch: RecentSearch) {
        self.showCustomAlert(alertTitle: Constants.deleteRecentSearchTitle.localized, alertMessage: Constants.deleteRecentSearchMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .cancel, firstActionHandler: {
            DispatchQueue.main.async {
                RecentSearchDataRepository.shared.delete(record: recentSearch)
                self.routeSelectionTableView.reloadData()
            }
        }, secondActionHandler: nil)
    }
    
    func deleteAllRecentSearch() {
        self.showCustomAlert(alertTitle: Constants.deleteAllRecentSearchTitle.localized, alertMessage: Constants.deleteAllRecentSearchMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .cancel, firstActionHandler: {
            DispatchQueue.main.async {
                RecentSearchDataRepository.shared.deleteAll(entity: .recentSearches)
                self.routeSelectionTableView.reloadData()
            }
        }, secondActionHandler: nil)
    }
    
    func deleteButtonPressed(button: UIButton, favouriteRoute: FavoriteRoute) {
        self.showCustomAlert(alertTitle: Constants.deleteFavRouteTitle.localized, alertMessage: Constants.deleteFavRouteMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .cancel, firstActionHandler: {
            FavoriteRouteDataRepository.shared.delete(record: favouriteRoute)
            self.routeSelectionTableDataSource.favoriteRoutes?.remove(at: button.tag)
            DispatchQueue.main.async {
                self.routeSelectionTableView.reloadData()
                
                guard let origin = self.origin, let destination = self.destination else { return }
                if self.availableRouteViewModel.isRouteFavorite(source: origin, destination: destination) {
                    self.routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
                } else {
                    self.routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
                }
            }
        }, secondActionHandler: nil)
    }
    
    func popOrPushToAvailableRouteViewController(source: LocationData, destination: LocationData) {
        
        /*if let navigationController = self.navigationController, navigationController.viewControllers.count > 0 {
            if navigationController.viewControllers.contains(where: {$0.isKind(of: AvailableRoutesViewController.self)}) {
                //favoritesViewDelegate?.favoritePopWithData(viewModel: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: self.travelPreferenceModel, data: routeSelectionViewData)
                self.navigationController?.popViewController(animated: true)
                return
            }
        }*/
        
        self.origin = source
        self.destination = destination
        self.routeSelectionView.originSearchBar.text = routeSelectionViewData?.originSearchText
        self.routeSelectionView.destinationSearchBar.text = routeSelectionViewData?.destinationSearchText
        
        let availableRoutesViewController: AvailableRoutesViewController = AvailableRoutesViewController.instantiate(appStoryboard: .availableRoutes)
        availableRoutesViewController.initialize(with: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: self.travelPreferenceModel)
        self.navigationController?.pushViewController(availableRoutesViewController, animated: true)
    }
}

extension RouteSelectionViewController: PlacesOfInterestViewControllerDelegate {
    func didSelectPlaceOfInterest(location: LocationData) {
        if routeSelectionView.activeSearchBar == routeSelectionView.originSearchBar {
            origin = location
            routeSelectionView.originSearchBar.text = origin?.address
        } else {
            routeSelectionView.endEditing(true)
            destination = location
            routeSelectionView.destinationSearchBar.text = destination?.address
        }
    }
}

extension RouteSelectionViewController: PlacesOfInterestCategoryViewControllerDelegate {
    func didSelectPlaceOfInterestFromSearchList(location: LocationData) {
        if routeSelectionView.activeSearchBar == routeSelectionView.originSearchBar {
            origin = location
            routeSelectionView.originSearchBar.text = origin?.address
        } else {
            routeSelectionView.endEditing(true)
            destination = location
            routeSelectionView.destinationSearchBar.text = destination?.address
        }
    }
}

extension RouteSelectionViewController: HomeWorkFavoritesViewControllerDelegate {
    func didSelectPlaceFromHomeWorkFavourites(location: LocationData) {
        if routeSelectionView.activeSearchBar == routeSelectionView.originSearchBar {
            origin = location
            routeSelectionView.originSearchBar.text = origin?.address
        } else {
            routeSelectionView.endEditing(true)
            destination = location
            routeSelectionView.destinationSearchBar.text = destination?.address
        }
    }
}

extension RouteSelectionViewController: RouteSelectionViewBackButtonDelegate {
    func backButtonAction() {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
}

extension RouteSelectionViewController: LocationSelectionOnMapDelegate {
    
    func didSelectOnMap(selectedModel: LocationSelectionModel?) {
        if let selectedModel = selectedModel {
            switch selectedModel.sourceType {
            case .origin:
                self.origin = selectedModel.origin
                self.routeSelectionView.originSearchBar.text = selectedModel.origin?.subAddress ?? selectedModel.origin?.address ?? ""
            case .destination:
                self.destination = selectedModel.destination
                self.routeSelectionView.destinationSearchBar.text = selectedModel.destination?.subAddress ?? selectedModel.destination?.address ?? ""
            }
            
            guard let origin = self.origin, let destination = self.destination else { return }
            if availableRouteViewModel.isRouteFavorite(source: origin, destination: destination) {
                routeSelectionView.imagePreferences.image = Images.ptAddedToFavorite
            } else {
                routeSelectionView.imagePreferences.image = Images.ptAddToFavorite
            }
            
        }
    }
    
}
