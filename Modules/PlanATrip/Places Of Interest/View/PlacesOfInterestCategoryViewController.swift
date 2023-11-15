//
//  POICategoryViewController.swift
//  RCRC
//
//  Created by Errol on 07/07/21.
//

import UIKit
import CoreLocation

protocol PlacesOfInterestCategoryViewControllerDelegate: AnyObject {
    func didSelectPlaceOfInterestFromSearchList(location: LocationData)
}

final class PlacesOfInterestCategoryViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitle: UILabel!

    private let searchController = PlacesOfInterestSearchController()
    private let categories = PlacesOfInterestCategory.allCases
    private var isSearching: Bool = false {
        didSet {
            searchBar.layer.borderColor = isSearching ? Colors.green.cgColor : UIColor.clear.cgColor
        }
    }
    private var workItem: DispatchWorkItem?
    private var currentLocation: CLLocationCoordinate2D?
    weak var delegate: PlacesOfInterestCategoryViewControllerDelegate?

    private var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }()

    @objc private func handleTapGesture() {
        isSearching = false
        workItem?.cancel()
    }

    convenience init() {
        self.init(nibName: PlacesOfInterestCategoryViewController.nibName, bundle: nil)
    }

    static var nibName: String {
        String(describing: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .plaesOfInterestCategory)
        configureNavigationBar(title: Constants.placesOfInterest.localized)
        headerTitle.text = Constants.placesOfInterest.localized
        configureView()

        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { [weak self] location in
            self?.currentLocation = location?.coordinate
        }
        self.disableLargeNavigationTitleCollapsing()
    }

    func configureView() {
        self.searchBar.textAlignment()
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.textField?.backgroundColor = .clear
        self.searchBar.textField?.background = UIImage()
        self.searchBar.placeholder = Constants.searchForLocation.localized
        self.searchBar.textField?.font = Fonts.CodecBold.fourteen
        self.searchBar.setImage(UIImage(), for: .search, state: .normal)
        self.searchBar.textField?.textColor = Colors.textColor
        self.searchBar.delegate = self
        
        tableView.register(TableViewCellWithAccessoryIndicator.self, forCellReuseIdentifier: TableViewCellWithAccessoryIndicator.identifier)
        tableView.register(RecentSearchTableViewCell.nib, forCellReuseIdentifier: RecentSearchTableViewCell.identifier)
        tableView.delegate = isSearching ? searchController : self
        tableView.dataSource = isSearching ? searchController : self
        tableView.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }

        view.addGestureRecognizer(tapGesture)
        guard let navigationController = self.navigationController else { return }
        let viewControllers: [UIViewController] = navigationController.viewControllers
        
        searchController.didSelectPlace = { [weak self] place in
            self?.isSearching = false
            self?.searchBar.isLoading = false
            self?.searchBar.resignFirstResponder()
            
            guard let geometry = place.geometry else { return }

            let coordinate = CLLocationCoordinate2D(latitude: geometry.location.lat, longitude: geometry.location.lng)
            let location = LocationData(id: place.placeID, address: place.name, subAddress: place.vicinity, coordinate: coordinate, type: .coordinate)
                        
            if viewControllers.contains(where: {$0 is RouteSelectionViewController}) {
                for routeSelectionViewController in viewControllers where routeSelectionViewController is RouteSelectionViewController {
                    let rvc = routeSelectionViewController as! RouteSelectionViewController
                    self?.delegate = rvc
                    self?.delegate?.didSelectPlaceOfInterestFromSearchList(location: location)
                    navigationController.popToViewController(rvc, animated: true)
                }
            } else {
                if navigationController.viewControllers.contains(where: {$0.isKind(of: MyAccountViewController.self)}) {
                    navigationController.viewControllers.removeAll(where: {$0.isKind(of: MyAccountViewController.self) == false})
                    let viewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
                    viewController.destination = location
                    navigationController.pushViewController(viewController, animated: true)
                } else {
                    if let index = navigationController.viewControllers.firstIndex(where: {$0.isKind(of: PlacesOfInterestCategoryViewController.self)}) {
                        navigationController.viewControllers.remove(at: index)
                        let viewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
                        viewController.destination = location
                        navigationController.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
}

extension PlacesOfInterestCategoryViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        tableView.dataSource = searchController
        tableView.delegate = searchController
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        workItem?.cancel()
        if searchText.count > 2 {
            searchBar.isLoading = true
            workItem = DispatchWorkItem { self.searchController.search(searchText,
                                                                       location: self.currentLocation, completion: self.updateView) }
            if let workItem = self.workItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
            }
        } else if searchText.count == 0 {
            DispatchQueue.main.async {
                self.isSearching = false
                searchBar.isLoading = false
                searchBar.endEditing(true)
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.reloadData()
            }
        } else {
            searchBar.isLoading = false
        }
    }

    private func updateView() {
        searchBar.isLoading = false
        tableView.reloadData()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.isLoading = false
        isSearching = false
        if searchBar.text?.count == 0 {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
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

extension PlacesOfInterestCategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.selectLocationFromCategory.localized
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.largeTableViewHeaderHeightForHomeWorkFav
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Colors.textColor
        header.tintColor = .white
        header.textLabel?.frame = header.frame
        header.textLabel?.font = Fonts.CodecRegular.sixteen
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCellWithAccessoryIndicator = tableView.dequeue(cellForRowAt: indexPath)
        cell.configure(text: categories[indexPath.row].displayName.localized, isPlaceOfInterest: true)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCategory = categories[indexPath.row]
        navigateToSelectedCategory(selectedCategory)
    }

    private func navigateToSelectedCategory(_ category: PlacesOfInterestCategory) {
        let viewController = PlacesOfInterestViewController(category: category)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension UISearchBar {
    
    func textAlignment() {
        if currentLanguage == .arabic || currentLanguage == .urdu {
            self.textField?.textAlignment = .right
        } else {
            self.textField?.textAlignment = .left
        }
    }
    
}
