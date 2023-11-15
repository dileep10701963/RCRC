//
//  HomeWorkFavoritesViewController.swift
//  RCRC
//
//  Created by Errol on 16/04/21.
//

import UIKit
import GoogleMaps

enum PlaceType: String {
    case home
    case work
    case favorite
    case school
}

struct SavedLocation: Equatable {
    var location: String?
    var address: String?
    var id: String?
    var latitude: Double?
    var longitude: Double?
    var type: String?
    var tag: String?

    static func == (lhs: SavedLocation, rhs: SavedLocation) -> Bool {
        return (lhs.id == rhs.id &&
                    lhs.location == rhs.location &&
                    lhs.address == rhs.address &&
                    lhs.latitude == rhs.latitude &&
                    lhs.longitude == rhs.longitude &&
                    lhs.type == rhs.type)
    }
}

protocol HomeWorkFavoritesViewControllerDelegate: AnyObject {
    func didSelectPlaceFromHomeWorkFavourites(location: LocationData)
}

class HomeWorkFavoritesViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stopFinderTableView: UITableView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet var arrayOfImageView: [UIImageView]!
    
    var recentSearches: [RecentSearch]? = [RecentSearch]()
    var savedLocations: [SavedLocation]? = [SavedLocation]()
    var placeType: PlaceType?
    let searchResultsViewModel = SearchResultsViewModel()
    var stopFinderResults: SearchResults?
    var selected: Bool = false
    var selectedLocation: SavedLocation?
    var travelPreferenceModel: TravelPreferenceModel? = nil
    weak var delegate: HomeWorkFavoritesViewControllerDelegate?
    var activityIndicator: UIActivityIndicatorView?
    var updateViewForEditPlaceType: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: " ".localized)
        switch placeType {
        case .home:
            self.headerTitle.text = "Home Location".localized
        case .work:
            self.headerTitle.text = "Work Location".localized
        case .favorite:
            self.headerTitle.text = "Favourites".localized
        case .school:
            self.headerTitle.text = "School Places".localized
        case .none:
            break
        }
        fetchData()
        searchBar.textField?.textColor = Colors.textColor
        
        self.tableView.isHidden = false
        if updateViewForEditPlaceType {
            self.tableView.isHidden = true
        }
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
        
        for (index, imageView) in arrayOfImageView.enumerated() {
            arrayOfImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
        
    }

    private func fetchData() {
        switch placeType {
        case .home:
            savedLocations = HomeLocationsDataRepository.shared.fetchAll()
            if savedLocations == nil || savedLocations?.count == 0 {
                searchBar.isUserInteractionEnabled = true
                recentSearches = RecentSearchDataRepository.shared.fetchAll()
                recentSearches?.reverse()
                descriptionLabel.text = "You have not added home location.".localized
                searchBar.placeholder = "Search your home location".localized
            } else {
                searchBar.placeholder = "Search address".localized
                let saveLimit = 1 - (savedLocations?.count ?? 0)
                descriptionLabel.text = String(format: NSLocalizedString("Update home location".localized, comment: ""), saveLimit)
            }
        case .work:
            savedLocations = WorkLocationsDataRepository.shared.fetchAll()
            if savedLocations == nil || savedLocations?.count == 0 {
                searchBar.isUserInteractionEnabled = true
                recentSearches = RecentSearchDataRepository.shared.fetchAll()
                recentSearches?.reverse()
                descriptionLabel.text = "You have not added work location.".localized
                searchBar.placeholder = "Search your work location".localized
            } else {
                searchBar.placeholder = "Search address".localized
                let saveLimit = 1 - (savedLocations?.count ?? 0)
                descriptionLabel.text = String(format: NSLocalizedString("Update work location".localized, comment: ""), saveLimit)
            }
        case .favorite:
            savedLocations = FavoriteLocationDataRepository.shared.fetchAll()
            if savedLocations == nil || savedLocations?.count == 0 {
                recentSearches = RecentSearchDataRepository.shared.fetchAll()
                recentSearches?.reverse()
                descriptionLabel.text = "You have not added favorite place.".localized
                searchBar.placeholder = "Search your favorite place".localized
            } else {
                searchBar.placeholder = "Search address".localized
                descriptionLabel.text = "Search and save your favourite places".localized
            }
        case .school:
            savedLocations = SchoolLocationsDataRepository.shared.fetchAll()
            if savedLocations == nil || savedLocations?.count == 0 {
                searchBar.isUserInteractionEnabled = true
                recentSearches = RecentSearchDataRepository.shared.fetchAll()
                recentSearches?.reverse()
                descriptionLabel.text = "You have not added school location.".localized
                searchBar.placeholder = "Search your school location".localized
            } else {
                if savedLocations?.count ?? 0 >= 3 {
                    searchBar.isUserInteractionEnabled = false
                } else {
                    searchBar.isUserInteractionEnabled = true
                }
                searchBar.placeholder = "Search address".localized
                let saveLimit = 3 - (savedLocations?.count ?? 0)
                descriptionLabel.text = String(format: NSLocalizedString("You can save %d more school locations", comment: ""), saveLimit)
            }
        case .none:
            break
        
        }
        tableView.reloadData()
    }

    private func configureTableView() {
        tableView.register(HomeWorkFavoriteTableViewCell.nib, forCellReuseIdentifier: HomeWorkFavoriteTableViewCell.identifier)
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: EmptyTableViewCell.identifier)
        tableView.register(PlacesOfInterestCell.self, forCellReuseIdentifier: PlacesOfInterestCell.identifier)
        tableView.register(PlacesOfInterestNewCell.self)
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
        case .home:
            viewController.headerText = "Favorite location added successfully".localized
            viewController.descriptionText = "".localized
        case .work:
            viewController.headerText = "Favorite location added successfully".localized
            viewController.descriptionText = "".localized
        case .favorite:
            viewController.headerText = "Favorite location added successfully".localized
            viewController.descriptionText = "".localized
            
        case .school:
            viewController.headerText = "Favorite location added successfully".localized
            viewController.descriptionText = "".localized
        case .none:
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
        case .home:
            HomeLocationsDataRepository.shared.deleteAll(entity: .homeLocations)
            HomeLocationsDataRepository.shared.create(record: SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: location.tag))
        case .work:
            WorkLocationsDataRepository.shared.deleteAll(entity: .workLocations)
            WorkLocationsDataRepository.shared.create(record: SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: location.tag))
        case .favorite:
            FavoriteLocationDataRepository.shared.create(record: SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: location.tag))
        case .school:
            SchoolLocationsDataRepository.shared.create(record: SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: location.tag))

        case .none:
            break
        }
    }

    /// $0 -> is location saved, $1-> number of saved locations, $2-> if home and work contain same location
    private func canSaveLocation(_ location: SavedLocation) -> (Bool, Int, Bool) {
        var isSaved: Bool = false
        var locationCount: Int = 0
        var isWorkAndHomeSame: Bool = false
        switch placeType {
        case .home:
            if let savedLocations = HomeLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
                locationCount = savedLocations.count
                savedLocations.forEach { (savedLocation) in
                    if savedLocation == location {
                        isSaved = true
                        return
                    }
                }
            } else if let savedLocations = WorkLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
                savedLocations.forEach { (savedLocation) in
                    if savedLocation == location {
                        isWorkAndHomeSame = true
                        return
                    }
                }
            }
        case .work:
            if let savedLocations = WorkLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
                locationCount = savedLocations.count
                savedLocations.forEach { (savedLocation) in
                    if savedLocation == location {
                        isSaved = true
                        return
                    }
                }
            } else if let savedLocations = HomeLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
                savedLocations.forEach { (savedLocation) in
                    if savedLocation == location {
                        isWorkAndHomeSame = true
                        return
                    }
                }
            }
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
            
        case .school:
            if let savedLocations = SchoolLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
                locationCount = savedLocations.count
                savedLocations.forEach { (savedLocation) in
                    if savedLocation == location {
                        isSaved = true
                        return
                    }
                }
            } else if let savedLocations = SchoolLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
                savedLocations.forEach { (savedLocation) in
                    if savedLocation == location {
                        isWorkAndHomeSame = true
                        return
                    }
                }
            }
        case .none:
            break
        }
        return (isSaved, locationCount, isWorkAndHomeSame)
    }

    func save(_ location: SavedLocation) {
        let canSave = canSaveLocation(location)
        if canSave.0 {
            self.showCustomAlert(alertTitle: "Already Saved".localized, alertMessage: "You have already saved this location".localized, firstActionTitle: ok, firstActionStyle: .default)
        } else if canSave.1 >= 1, placeType != .favorite , updateViewForEditPlaceType == true {
            self.saveLocation(location)
            self.navigateToConfirmationView()
            /*self.showCustomAlert(alertTitle: "Limit Reached".localized, alertMessage: "You cannot save more than 1 \(placeType?.rawValue ?? emptyString) locations", firstActionTitle: ok, firstActionStyle: .default)*/
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
}

// MARK: - TableView Delegate
extension HomeWorkFavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView && placeType == .favorite {
            return 2
        }
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if section == 0, placeType == .favorite {
                return 1
            }

            if let savedLocations = self.savedLocations, !savedLocations.isEmpty {
                return savedLocations.count
            } else {
                if let recentSearches = self.recentSearches, !recentSearches.isEmpty {
                    return recentSearches.count
                } else {
                    return 1
                }
            }
        } else {
            guard let stopFinderResults = self.stopFinderResults else { return 0 }
            return stopFinderResults.googleLocations?.count ?? 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if indexPath.section == 0, placeType == .favorite {
                let cell: PlacesOfInterestNewCell = tableView.dequeue(cellForRowAt: indexPath)
                return cell
            }

            if let savedLocations = self.savedLocations, !savedLocations.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeWorkFavoriteTableViewCell.identifier, for: indexPath) as? HomeWorkFavoriteTableViewCell
                switch placeType {
                case .home:
                    cell?.cellImage.image = Images.home
                case .work:
                    cell?.cellImage.image = Images.work
                case .favorite:
                    cell?.cellImage.image = Images.myFav
                case .school:
                    cell?.cellImage.image = Images.school
                case .none:
                    break
                }
                cell?.configureSavedLocation(result: savedLocations[indexPath.row])
                let deleteButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                deleteButton.setImage(Images.removeSavedLocation, for: .normal)
                deleteButton.setTitle(emptyString, for: .normal)
                deleteButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
                deleteButton.tag = indexPath.row
                cell?.accessoryView = deleteButton
                
                cell?.editButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
                cell?.editButton.tag = indexPath.row
                
                return cell ?? UITableViewCell()
            } else {
                if let recentSearches = self.recentSearches, !recentSearches.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: HomeWorkFavoriteTableViewCell.identifier, for: indexPath) as? HomeWorkFavoriteTableViewCell
                    cell?.cellImage.image = Images.recentSearch
                    cell?.configureRecentSearch(result: recentSearches[indexPath.row])
                    cell?.accessoryView = nil
                    return cell ?? UITableViewCell()
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
                    cell?.textLabel?.text = "No Recent Searches".localized
                    cell?.textLabel?.textAlignment = .center
                    cell?.textLabel?.font = Fonts.CodecRegular.eighteen
                    cell?.accessoryView = nil
                    return cell ?? UITableViewCell()
                }
            }
        } else {
            guard let stopFinderResults = self.stopFinderResults, let googleLocations = stopFinderResults.googleLocations else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeWorkFavoriteTableViewCell.identifier, for: indexPath) as? HomeWorkFavoriteTableViewCell
            cell?.cellImage.image = Images.stopFinderSearch
            cell?.configure(result: googleLocations[indexPath.row])
            return cell ?? UITableViewCell()
        }
    }

    @objc func editTapped(_ sender: UIButton) {
        guard let savedLocations = self.savedLocations else { return }
        let location = savedLocations[sender.tag]
        let savedLocation = savedLocations[sender.tag]
        
        showUpdateTextAlert(title: Constants.doYouWantToEdit.localized, message: "", placeholder: "", textToEdit: location.tag ?? "") { [weak self] result in
            print(result)
            let newLocation = SavedLocation(location: location.location, address: location.address, id: location.id, latitude: location.latitude, longitude: location.longitude, type: location.type, tag: result)
            self?.saveLocation(newLocation)
            
            switch self?.placeType {
            case .home:
                HomeLocationsDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type, tag: savedLocation.tag))
            case .work:
                WorkLocationsDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type, tag: savedLocation.tag))
            default:
                break
            }
            
            self?.fetchData()
            
        } onSave: {
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Colors.textColor
        header.tintColor = .white
        header.textLabel?.frame = header.frame
        header.textLabel?.font = Fonts.CodecRegular.sixteen
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            if section == 0, placeType == .favorite {
                return .none
            }
            if let savedLocations = self.savedLocations, !savedLocations.isEmpty {
                switch placeType {
                case .home:
                    return "List of Saved Home Locations".localized
                case .work:
                    return "List of Saved Work Locations".localized
                case .favorite:
                    return "List of Saved Favorite Places".localized
                case .school:
                    return "List of Saved School Locations".localized
                case .none:
                    return emptyString
                }
            } else {
                if let recentSearches = self.recentSearches, !recentSearches.isEmpty {
                    return "Select location from Recent Searches".localized
                } else {
                    return emptyString
                }
            }
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            if section == 0, placeType == .favorite {
                return Constants.regularTableViewHeaderHeight
            }
            return Constants.largeTableViewHeaderHeightForHomeWorkFav
        }
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableView {
            if indexPath.section == 0, placeType == .favorite {
                let viewController = PlacesOfInterestCategoryViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                if let savedLocations = self.savedLocations, savedLocations.isNotEmpty {
                    let savedLocation = savedLocations[indexPath.row]
                    var location = LocationData()
                    location.address = savedLocation.address
                    if let latitude = savedLocation.latitude, let longitude = savedLocation.longitude {
                        location.id = savedLocation.id
                        location.address = savedLocation.location
                        location.subAddress = savedLocation.address
                        location.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    } else { // Latitude & Longitude is empty
                        location.id = savedLocation.id
                        location.address = savedLocation.location
                        location.subAddress = savedLocation.address
                        location.type = .coordinate
                    }
                    (savedLocation.type ?? emptyString == Constants.stop) ? (location.type = .stop) : (location.type = .coordinate)
                    
                    guard let navigationController = self.navigationController else { return  }
                    let viewControllers: [UIViewController] = navigationController.viewControllers
                    for routeSelectionViewController in viewControllers {
                        if routeSelectionViewController is RouteSelectionViewController {
                            let rvc = routeSelectionViewController as! RouteSelectionViewController
                            self.delegate = rvc
                            delegate?.didSelectPlaceFromHomeWorkFavourites(location: location)
                            navigationController.popToViewController(rvc, animated: true)
                        }
                    }
                    
                    if viewControllers.filter({$0.isKind(of: RouteSelectionViewController.classForCoder())}).count == 0 {
                        let viewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
                        viewController.destination = location
                        viewController.travelPreferenceModel = self.travelPreferenceModel
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    
                } else {
                    if let recentSearches = self.recentSearches, !recentSearches.isEmpty {
                        let location = recentSearches[indexPath.row]
                        var savedLocation = SavedLocation(location: location.location, address: location.address, id: location.id,
                                                          latitude: location.latitude, longitude: location.longitude, type: location.type)
                        if location.latitude == nil || location.longitude == nil {
                            self.activityIndicator = self.startActivityIndicator()
                            searchResultsViewModel.fetchCoordinateForAutoCompleteResponse(placeID: location.id ?? emptyString) {[weak self] gmsPlace in
                                DispatchQueue.main.async {
                                    self?.activityIndicator?.stop()
                                    if let gmsPlace = gmsPlace {
                                        if let index = self?.recentSearches?.firstIndex(where: {$0.id == savedLocation.id}) {
                                            self?.recentSearches?[index].latitude = gmsPlace.coordinate.latitude
                                            self?.recentSearches?[index].latitude = gmsPlace.coordinate.longitude
                                            savedLocation.latitude = gmsPlace.coordinate.latitude
                                            savedLocation.longitude = gmsPlace.coordinate.longitude
                                        }
                                    }
                                    self?.save(savedLocation)
                                }
                            }
                            
                        } else {
                            save(savedLocation)
                        }
                    }
                }
            }

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

    @objc func deleteTapped(_ sender: UIButton) {
        guard let savedLocations = self.savedLocations else { return }
        let savedLocation = savedLocations[sender.tag]
        switch placeType {
        case .home:
            self.showCustomAlert(alertTitle: Constants.deleteFavLocationTitle.localized, alertMessage: Constants.deleteFavLocationMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .default, firstActionHandler: {
                HomeLocationsDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type))
                self.fetchData()
            }, secondActionHandler: nil)
        case .work:
            self.showCustomAlert(alertTitle: Constants.deleteFavLocationTitle.localized, alertMessage: Constants.deleteFavLocationMessage.localized, firstActionTitle: Constants.buttonYes.localized.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .default, firstActionHandler: {
                WorkLocationsDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type))
                self.fetchData()
            }, secondActionHandler: nil)
        case .school:
            self.showCustomAlert(alertTitle: Constants.deleteFavLocationTitle.localized, alertMessage: Constants.deleteFavLocationMessage.localized, firstActionTitle: Constants.buttonNo.localized.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonYes.localized, secondActionStyle: .default, secondActionHandler: {
                SchoolLocationsDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type))
                self.fetchData()
            })
        case .favorite:
            self.showCustomAlert(alertTitle: Constants.deleteFavLocationTitle.localized, alertMessage: Constants.deleteFavLocationMessage.localized, firstActionTitle: Constants.buttonYes.localized.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .default, firstActionHandler: {
                FavoriteLocationDataRepository.shared.delete(record: SavedLocation(location: savedLocation.location, address: savedLocation.address, id: savedLocation.id, latitude: savedLocation.latitude, longitude: savedLocation.longitude, type: savedLocation.type, tag: savedLocation.tag))
                self.fetchData()
            }, secondActionHandler: nil)
        case .none:
            break
        }
    }
}

// MARK: - Search Bar Delegate
extension HomeWorkFavoritesViewController: UISearchBarDelegate {

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

extension HomeWorkFavoritesViewController: SuccessViewDelegate {

    func didTapProceed() {
        self.resetTableViewAndSearchBar()
        self.fetchData()
        if let viewController = self.navigationController?.viewControllers.first(where: { $0.isKind(of: RouteSelectionViewController.self) }) {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
