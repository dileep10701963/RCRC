//
//  FavoritesViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 26/04/23.
//

import UIKit
import GoogleMaps

protocol FavoritesViewDelegate: AnyObject {
    func favoritePopWithData(viewModel: AvailableRoutesViewModel, origin: LocationData, destination: LocationData, travelPreference: TravelPreferenceModel?, data: RouteSelectionViewData?)
}

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stopFinderTableView: UITableView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet var arrayImageView: [UIImageView]!
    @IBOutlet weak var buttonAddToFav: UIButton!
    
    var recentSearches: [RecentSearch]? = [RecentSearch]()
    var savedLocations: [SavedLocation]? = [SavedLocation]()
    var favoriteRoutes: [FavoriteRoute]?
    var placeType: PlaceType?
    let searchResultsViewModel = SearchResultsViewModel()
    var stopFinderResults: SearchResults?
    var selected: Bool = false
    var selectedLocation: SavedLocation?
    var travelPreferenceModel: TravelPreferenceModel? = nil
    weak var delegate: HomeWorkFavoritesViewControllerDelegate?
    var activityIndicator: UIActivityIndicatorView?
    private let categories = PlacesOfInterestCategory.allCases
    private let headerHeight: CGFloat = 59
    var isPOIExpand: Bool = false
    let coordinate = "coordinate"
    let stop = "stop"
    weak var favoritesViewDelegate: FavoritesViewDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: " ".localized)
        switch placeType {
        case .favorite:
            //self.headerTitle.text = Constants.myFavoriteRoutes.localized
            self.headerTitle.isHidden = true
        default:
            break
        }
        fetchData()
        searchBar.textField?.textColor = Colors.textColor
        favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .favourite)
        configureSearchBar()
        configureTableView()
        fetchData()
        searchBar.textField?.setAlignment()
        descriptionLabel.setAlignment()
        configureSearchObserver()
        if let selectedLocation = self.selectedLocation {
            save(selectedLocation)
        }
        self.disableLargeNavigationTitleCollapsing()
        self.stopFinderTableView.separatorStyle = .none
        self.tableView.separatorStyle = .none
        
        if #available(iOS 15.0, *) {
            self.stopFinderTableView.sectionHeaderTopPadding = 0
            self.tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        for (index, imageView) in arrayImageView.enumerated() {
            arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
        
    }
    
    @IBAction func buttonAddToFavTapped(_ sender: UIButton) {
        let locationSelectionOnMapController: LocationSelectionOnMapController = LocationSelectionOnMapController.instantiate(appStoryboard: .home)
        locationSelectionOnMapController.delegate = self
        locationSelectionOnMapController.isFromFavorite = true
        self.navigationController?.pushViewController(locationSelectionOnMapController, animated: true)
    }
    
    private func fetchData() {
        switch placeType {
        case .favorite:
            savedLocations = FavoriteLocationDataRepository.shared.fetchAll()
            if savedLocations == nil || savedLocations?.count == 0 {
                recentSearches = RecentSearchDataRepository.shared.fetchAll()
                recentSearches?.reverse()
                descriptionLabel.text = "You have not added favorite place.".localized
                searchBar.placeholder = "Search your favorite place".localized
            } else {
                searchBar.placeholder = "Search address".localized
                descriptionLabel.text = "Search and save your favorite places".localized
            }
        default:
            break
            
        }
        tableView.reloadData()
    }
    
    private func configureTableView() {
        tableView.register(HomeWorkFavoriteTableViewCell.nib, forCellReuseIdentifier: HomeWorkFavoriteTableViewCell.identifier)
        tableView.register(PlacesOfInterestCell.self, forCellReuseIdentifier: PlacesOfInterestCell.identifier)
        tableView.register(PlacesOfInterestNewCell.self)
        tableView.register(QuickSelectTableViewCell.self)
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: EmptyTableViewCell.identifier)
        tableView.registerHeaderFooterViewNib(POIHeaderView.self)
        tableView.register(TableViewCellWithAccessoryIndicator.self, forCellReuseIdentifier: TableViewCellWithAccessoryIndicator.identifier)
        tableView.register(FavoriteRouteTableViewCell.nib, forCellReuseIdentifier: FavoriteRouteTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        stopFinderTableView.register(HomeWorkFavoriteTableViewCell.nib, forCellReuseIdentifier: HomeWorkFavoriteTableViewCell.identifier)
        stopFinderTableView.dataSource = self
        stopFinderTableView.delegate = self
        stopFinderTableView.tableFooterView = UIView()
        stopFinderTableView.isHidden = true
        
    }
    
    private func configureSearchBar() {
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.textField?.backgroundColor = .clear
        self.searchBar.textField?.background = UIImage()
        self.searchBar.placeholder = Constants.enterOrigin.localized
        self.searchBar.textField?.font = Fonts.CodecBold.fourteen
        self.searchBar.setImage(UIImage(), for: .search, state: .normal)
        self.searchBar.showsBookmarkButton = true
        self.searchBar.setImage(Images.tripMap, for: .bookmark, state: .normal)
        self.searchBar.setImage(UIImage(), for: .search, state: .normal)
        self.searchBar.delegate = self
    }
    
    private func configureSearchObserver() {
        searchResultsViewModel.stopFinderResults.bind { [weak self] (result, error) in
            guard let self = self else { return }
            if let result = result, error == nil, !self.selected {
                self.searchBar.isLoading = false
                self.stopFinderResults = result
                self.stopFinderTableView.isHidden = false
                self.stopFinderTableView.reloadData()
            } else if let error = error, result == nil {
                self.showCustomAlert(alertTitle: Constants.error, alertMessage: error.localizedDescription, firstActionTitle: ok, firstActionStyle: .default)
                self.searchBar.isLoading = false
                self.stopFinderTableView.isHidden = true
                self.searchBar.endEditing(true)
            }
        }
    }
    
    private func navigateToConfirmationView() {
        
        let viewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
        switch placeType {
        case .favorite:
            viewController.headerText = "Favorite location added successfully".localized
            viewController.descriptionText = "".localized
        default:
            break
        }
        viewController.proceedButtonText = "Proceed".localized
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self?.dismiss(animated: true, completion: {
                    self?.resetTableViewAndSearchBar()
                    self?.fetchData()
                })
                self?.resetTableViewAndSearchBar()
                self?.fetchData()
            }
        })
    }
    
    func resetTableViewAndSearchBar() {
        stopFinderTableView.isHidden = true
        self.searchBar.text = nil
    }
    
    private func saveLocation(_ location: SavedLocation) {
        switch placeType {
        case .favorite:
            FavoriteLocationDataRepository.shared.create(record: SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: location.tag))
            
        default:
            break
        }
    }
    
    /// $0 -> is location saved, $1-> number of saved locations, $2-> if home and work contain same location
    private func canSaveLocation(_ location: SavedLocation) -> (Bool, Int, Bool) {
        var isSaved: Bool = false
        var locationCount: Int = 0
        var isWorkAndHomeSame: Bool = false
        switch placeType {
        case .favorite:
            if let savedLocations = FavoriteLocationDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
                locationCount = savedLocations.count
                savedLocations.forEach { (savedLocation) in
                    if savedLocation == location {
                        isSaved = true
                        return
                    }
                }
            }
        default:
            break
        }
        return (isSaved, locationCount, isWorkAndHomeSame)
    }
    
    func save(_ location: SavedLocation) {
        let canSave = canSaveLocation(location)
        if canSave.0 {
            self.showCustomAlert(alertTitle: "Already Saved".localized, alertMessage: "You have already saved this location".localized, firstActionTitle: ok, firstActionStyle: .default)
        } else if canSave.1 >= 3, placeType != .favorite {
            self.showCustomAlert(alertTitle: "Limit Reached".localized, alertMessage: "You cannot save more than 3 \(placeType?.rawValue ?? emptyString) locations", firstActionTitle: ok, firstActionStyle: .default)
        } else if canSave.2, placeType != .favorite {
            self.showCustomAlert(alertTitle: "Work and Home cannot be same".localized, alertMessage: "You have already saved this location".localized, firstActionTitle: ok, firstActionStyle: .default)
        } else if placeType == .home || placeType == .work || placeType == .school || placeType == .favorite {
            showAlertWithTextField(title: "\(Constants.saveLocationAlertTitle.localized)", message: "", placeholder: "Please enter an alias.".localized, enteredText: { [weak self] result in
                print(result)
                let newLocation = SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: result)
                self?.saveLocation(newLocation)
            }, onSave: { [weak self] in
                self?.navigateToConfirmationView()
            })
        } else {
            self.saveLocation(location)
            self.navigateToConfirmationView()
        }
    }
    
    var isSchoolSaved: Bool {
        if let savedLocations = SchoolLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
            return true
        } else {
            return false
        }
    }
    
}

// MARK: - TableView Delegate
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.favoriteRoutes?.count ?? 0 <= 0 ? 1 : self.favoriteRoutes?.count ?? 0
        } else {
            guard let stopFinderResults = self.stopFinderResults else { return 0 }
            return stopFinderResults.googleLocations?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if self.favoriteRoutes?.count ?? 0 > 0 {
                return setupCellForFavouritesRoute(indexPath: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
                cell?.textLabel?.text = Constants.noRoutesAlertTitle.localized
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.font = Fonts.CodecRegular.eighteen
                cell?.accessoryView = nil
                return cell ?? UITableViewCell()
            }
        } else {
            guard let stopFinderResults = self.stopFinderResults, let googleLocations = stopFinderResults.googleLocations else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeWorkFavoriteTableViewCell.identifier, for: indexPath) as? HomeWorkFavoriteTableViewCell
            cell?.cellImage.image = Images.stopFinderSearch
            cell?.configure(result: googleLocations[indexPath.row])
            return cell ?? UITableViewCell()
        }
    }
    
    private func setupCellForCategoryText(indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCellWithAccessoryIndicator = tableView.dequeue(cellForRowAt: indexPath)
        cell.selectionStyle = .none
        cell.configureForCategory(text: Constants.selectLocationFromCategory.localized)
        return cell
    }
    
    private func setupCellForFavouritesRoute(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteRouteTableViewCell.identifier, for: indexPath) as? FavoriteRouteTableViewCell
        if let favoriteRoutes = self.favoriteRoutes {
            if let source = favoriteRoutes[indexPath.row].sourceAddress, let destination = favoriteRoutes[indexPath.row].destinationAddress {
                cell?.source.attributedText = Utilities.shared.getAttributedText(source, nil,Fonts.CodecRegular.fourteen)
                cell?.destination.attributedText = Utilities.shared.getAttributedText(destination, nil, Fonts.CodecRegular.fourteen)
                cell?.source.setAlignment()
                cell?.destination.setAlignment()
                cell?.deleteButton.addTarget(self, action: #selector(deleteButtonPressed(button:)), for: .touchUpInside)
            }
        }
        return cell ?? UITableViewCell()
    }
    
    @objc func deleteButtonPressed(button: UIButton) {
        if let favouriteRoute = favoriteRoutes?[button.tag] {
            self.showCustomAlert(alertTitle: Constants.deleteFavRouteTitle.localized, alertMessage: Constants.deleteFavRouteMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .cancel, firstActionHandler: {
                FavoriteRouteDataRepository.shared.delete(record: favouriteRoute)
                self.favoriteRoutes?.remove(at: button.tag)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, secondActionHandler: nil)
        }
    }
    
    private func setupCellForRecentOrFavLocation(indexPath: IndexPath) -> UITableViewCell {
        if let savedLocations = self.savedLocations, !savedLocations.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeWorkFavoriteTableViewCell.identifier, for: indexPath) as? HomeWorkFavoriteTableViewCell
            cell?.cellImage.image = Images.myFav
            cell?.configureSavedLocationForFav(result: savedLocations[indexPath.row])
            
            let deleteButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24)))
            deleteButton.setImage(Images.editProfile, for: .normal)
            deleteButton.setTitle(emptyString, for: .normal)
            deleteButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
            deleteButton.tag = indexPath.row
            cell?.accessoryView = deleteButton
            
            cell?.editButton.setImage(Images.removeSavedLocation, for: .normal)
            cell?.editButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
            cell?.editButton.tag = indexPath.row
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableView {
            if self.favoriteRoutes?.count ?? 0 <= 0 {
                return
            }
            tapOnFavouriteRoutes(indexPath: indexPath)
        } else {
            self.selected = true
            guard let stopFinderResults = self.stopFinderResults, let place = stopFinderResults.googleLocations?[indexPath.row] else { return }
            var locationToSave = SavedLocation(location: place.name, address: place.vicinity, id: place.placeID, latitude: place.geometry?.location.lat, longitude: place.geometry?.location.lng, type: Constants.coordinate, tag: place.name)
            
            searchBar.endEditing(true)
            if place.geometry?.location.lat == nil || place.geometry?.location.lng == nil {
                self.activityIndicator = self.startActivityIndicator()
                searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: place.placeID ?? emptyString) {[weak self] gmsPlace in
                    DispatchQueue.main.async {
                        self?.activityIndicator?.stop()
                        if let gmsPlace = gmsPlace {
                            let location = PlacesOfInterestLocation(lat: gmsPlace.coordinate.latitude, lng: gmsPlace.coordinate.longitude)
                            if let index = self?.stopFinderResults?.googleLocations?.firstIndex(where: {$0.placeID == place.placeID ?? emptyString}) {
                                self?.stopFinderResults?.googleLocations?[index].geometry = PlacesOfInterestGeometry(location: location)
                                locationToSave.latitude = gmsPlace.coordinate.latitude
                                locationToSave.longitude = gmsPlace.coordinate.longitude
                            }
                        }
                        self?.save(locationToSave)
                    }
                }
                
            } else {
                save(locationToSave)
            }
        }
    }
    
    private func tapOnFavouriteRoutes(indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
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

        if let navigationController = self.navigationController, navigationController.viewControllers.count > 0 {
            if navigationController.viewControllers.contains(where: {$0.isKind(of: AvailableRoutesViewController.self)}) {
                favoritesViewDelegate?.favoritePopWithData(viewModel: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: travelPreferenceModel, data: routeSelectionViewData)
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        
        let availableRoutesViewController: AvailableRoutesViewController = AvailableRoutesViewController.instantiate(appStoryboard: .availableRoutes)
        availableRoutesViewController.initialize(with: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: travelPreferenceModel)
        self.navigationController?.pushViewController(availableRoutesViewController, animated: true)
    }
    
    
    @objc func deleteTapped(_ sender: UIButton) {
        guard let savedLocations = self.savedLocations else { return }
        let savedLocation = savedLocations[sender.tag]
        switch placeType {
        case .favorite:
            self.showCustomAlert(alertTitle: Constants.deleteFavLocationTitle.localized, alertMessage: Constants.deleteFavLocationMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .default, firstActionHandler: {
                FavoriteLocationDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type, tag: savedLocation.tag))
                self.fetchData()
            })
        default:
            break
        }
    }
    
    @objc func editTapped(_ sender: UIButton) {
        guard let savedLocations = self.savedLocations else { return }
        let location = savedLocations[sender.tag]
        let savedLocation = savedLocations[sender.tag]
        
        switch placeType {
            
        case .favorite:
            showUpdateTextAlert(title: Constants.doYouWantToEdit.localized, message: "", placeholder: "", textToEdit: location.tag ?? "") { [weak self] result in
                print(result)
                let newLocation = SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: result)
                self?.saveLocation(newLocation)
                
                FavoriteLocationDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type, tag: savedLocation.tag))
                self?.fetchData()
                
            } onSave: {
                self.tableView.reloadData()
            }
            
            showAlertWithTextField(title: "", message: "\(location.address ?? "")\(Constants.saveLocationAlertMessage.localized) \(placeType?.rawValue.localized ?? "")\(Constants.saveLocAlertMessage.localized)", placeholder: "Please enter an alias.".localized, enteredText: { [weak self] result in
                print(result)
                let newLocation = SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: result)
                self?.saveLocation(newLocation)
            }, onSave: { [weak self] in
                self?.navigateToConfirmationView()
            })
        default:
            break
        }
    }
}

// MARK: - Search Bar Delegate
extension FavoritesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.textField?.borderColor = .clear
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            selected = false
            searchBar.isLoading = true
            searchResultsViewModel.searchText = searchText
        } else {
            searchBar.isLoading = false
            stopFinderTableView.isHidden = true
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.textField?.borderColor = .clear
        searchBar.isLoading = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let searchBarText = searchBar.textField?.text, let textRange = Range(range, in: searchBarText) {
            let updatedText = searchBarText.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
        }
        return true
    }
    
}

extension FavoritesViewController: SuccessViewDelegate {
    
    func didTapProceed() {
        self.resetTableViewAndSearchBar()
        self.fetchData()
    }
}

extension FavoritesViewController: POIHeaderViewDelegate {
    
    func buttonExpandArrowTapped(sender: UIButton) {
        isPOIExpand = !isPOIExpand
        self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }
    
}

extension FavoritesViewController: QuickSelectCellDelegate {
    
    func editProfileTapped(placeType: PlaceType) {
        
        switch placeType {
        case .home:
            if let homeData = HomeLocationsDataRepository.shared.fetchAll(), homeData.count > 0 {
                redirectToHomeWorkFavScreen(placeType: placeType, updatePlace: true)
            } else {
                redirectToHomeWorkFavScreen(placeType: placeType)
            }
        case .work:
            if let workData = WorkLocationsDataRepository.shared.fetchAll(), workData.count > 0 {
                redirectToHomeWorkFavScreen(placeType: placeType, updatePlace: true)
            } else {
                redirectToHomeWorkFavScreen(placeType: placeType)
            }
        default:
            break
        }
        
    }
    
    func redirectToHomeWorkFavScreen(placeType: PlaceType, updatePlace: Bool = false) {
        let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
        viewController.placeType = placeType
        viewController.updateViewForEditPlaceType = updatePlace
        viewController.travelPreferenceModel = self.travelPreferenceModel
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension FavoritesViewController: LocationSelectionOnMapDelegate {
    
    func didSelectOnMapForFav(favLocation: SavedLocation?) {
        if let savedLocation = favLocation {
            self.save(savedLocation)
        }
    }
}
