//
//  FavoriteLocationsViewController.swift
//  RCRC
//
//  Created by Errol on 19/02/21.
//

import UIKit
import GoogleMaps

class FavoriteLocationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var stopfinderTableView: UITableView!
    var favoriteLocations: [SavedLocation]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .favouriteLocation)
        self.configureNavigationBar(title: Constants.favoritePlaces.localized)
        self.searchBar.delegate = self
        tableView.register(FavoriteLocationTableViewCell.nib, forCellReuseIdentifier: FavoriteLocationTableViewCell.identifier)
        tableView.register(PlacesOfInterestCell.self, forCellReuseIdentifier: PlacesOfInterestCell.identifier)
        favoriteLocations = FavoriteLocationDataRepository.shared.fetchAll()
    }
}

extension FavoriteLocationsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return favoriteLocations?.count ?? 0
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: PlacesOfInterestCell = tableView.dequeue(cellForRowAt: indexPath)
            return cell
        }
        let cell: FavoriteLocationTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
        if let favoriteLocations = self.favoriteLocations {
            let location =  favoriteLocations[indexPath.row]
            if location.tag == "" || location.tag == nil  {
                cell.location.text = favoriteLocations[indexPath.row].location
            } else {
                cell.location.text = favoriteLocations[indexPath.row].tag
            }
            cell.locationType.text = favoriteLocations[indexPath.row].address
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let favoritePlaces = self.favoriteLocations else { return }
        let favoritePlace = favoritePlaces[indexPath.row]
        var location = LocationData()
        location.id = favoritePlace.id
        location.address = favoritePlace.address
        if let latitude = favoritePlace.latitude, let longitude = favoritePlace.longitude {
            location.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        let routeSelectionViewController: RouteSelectionViewController = RouteSelectionViewController.instantiate(appStoryboard: .routeSelection)
        routeSelectionViewController.destination = location
        self.navigationController?.pushViewController(routeSelectionViewController, animated: true)
    }
}

// MARK: - Search Implementation

extension FavoriteLocationsViewController: UISearchBarDelegate {
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
