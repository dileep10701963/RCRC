//
//  PlacesOfInterestViewController.swift
//  RCRC
//
//  Created by Errol on 25/06/21.
//

import UIKit
import CoreLocation

protocol PlacesOfInterestViewControllerDelegate: AnyObject {
    func didSelectPlaceOfInterest(location: LocationData)
}

final class PlacesOfInterestViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitle: UILabel!
    
    private let viewModel = PlacesOfInterestViewModel()
    private var currentLocation: CLLocationCoordinate2D?
    private var placesOfInterestData: PlacesOfInterestModel?
    private var category: PlacesOfInterestCategory!
    private var nextPageToken: String?
    private var results: [PlacesOfInterestResult] = []
    weak var delegate: PlacesOfInterestViewControllerDelegate?

    private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = Colors.green
        refresh.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return refresh
    }()

    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        fetchPlaces()
    }

    convenience init(category: PlacesOfInterestCategory) {
        self.init(nibName: PlacesOfInterestViewController.nibName, bundle: nil)
        self.category = category
    }

    static var nibName: String {
        String(describing: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .placesOfInterest)
        tableView.register(RecentSearchTableViewCell.nib, forCellReuseIdentifier: RecentSearchTableViewCell.identifier)
        tableView.register(PlacesOfInterestListCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { [weak self] location in
            self?.currentLocation = location?.coordinate
        }
        fetchPlaces()
        self.disableLargeNavigationTitleCollapsing()
        headerTitle.text = Constants.placesOfInterest.localized
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(title: Constants.placesOfInterest.localized)
    }

    private func fetchPlaces() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        refreshControl.beginRefreshing()
        viewModel.fetchPlaces(location: currentLocation,
                              pageToken: nextPageToken,
                              text: .none,
                              category: category) { [weak self] result in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            switch result {
            case let .success(placesOfInterest):
                self.placesOfInterestData = placesOfInterest
                self.nextPageToken = placesOfInterest.nextPageToken
                if let placesOfInterest = placesOfInterest.results {
                    self.results +=  placesOfInterest
                    self.tableView.reloadData()
                }
            case .failure:
                break
            }
        }
    }
}

extension PlacesOfInterestViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlacesOfInterestListCell = tableView.dequeue(cellForRowAt: indexPath)
        if let result = self.results[safe: indexPath.row] {
            let location = SavedLocation(location: result.name, address: result.vicinity, id: result.placeID, latitude: result.geometry?.location.lat, longitude: result.geometry?.location.lng, type: Constants.coordinate, tag: result.name)
            cell.configure(location: location)
        }
        if indexPath.row == self.results.count - 1 && nextPageToken != nil {
            self.fetchPlaces()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.largeTableViewHeaderHeightForHomeWorkFav
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.headerViewWithSectionText(text: category.displayName.localized)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedPlace = self.results[safe: indexPath.row] else { return }
        guard let geometry = selectedPlace.geometry else { return }
        let coordinate = CLLocationCoordinate2D(latitude: geometry.location.lat, longitude: geometry.location.lng)
        let location = LocationData(id: selectedPlace.placeID, address: selectedPlace.name, subAddress: selectedPlace.vicinity, coordinate: coordinate, type: .coordinate)
        guard let navigationController = self.navigationController else { return  }
        let viewControllers: [UIViewController] = navigationController.viewControllers

        if viewControllers.contains(where: {$0 is RouteSelectionViewController}) {
            for routeSelectionViewController in viewControllers where routeSelectionViewController is RouteSelectionViewController {
                let rvc = routeSelectionViewController as! RouteSelectionViewController
                self.delegate = rvc
                delegate?.didSelectPlaceOfInterest(location: location)
                navigationController.popToViewController(rvc, animated: true)
            }
        } else {
            navigationController.viewControllers.removeSubrange(1...3)
            let viewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
            viewController.destination = location
            navigationController.pushViewController(viewController, animated: true)
        }
        
    }
}
