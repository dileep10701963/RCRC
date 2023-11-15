//
//  POISearchController.swift
//  RCRC
//
//  Created by Errol on 09/07/21.
//

import UIKit
import CoreLocation

final class PlacesOfInterestSearchController: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let viewModel = PlacesOfInterestViewModel()
    var places: PlacesOfInterestModel?
    var didSelectPlace: ((PlacesOfInterestResult) -> Void)?
    var favoriteTapped: ((PlacesOfInterestResult) -> Void)?

    func search(_ text: String, location: CLLocationCoordinate2D?, completion: @escaping () -> Void) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: nil) {
            return
        }
        viewModel.fetchPlaces(location: location, pageToken: .none, text: text, category: .none) { [weak self] result in
            switch result {
            case let .success(places):
                self?.places = places
                completion()
            case .failure:
                self?.places = .none
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.results?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecentSearchTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
        if let places = self.places,
           let place = places.results?[safe: indexPath.row] {
            let location = SavedLocation(location: place.name, address: place.vicinity, id: place.placeID, latitude: place.geometry?.location.lat, longitude: place.geometry?.location.lng, type: Constants.coordinate, tag: place.name)
            cell.configure(location: location, screenName: .none)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedPlace = places?.results?[indexPath.row] else { return }
        didSelectPlace?(selectedPlace)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.selectLocationFromSearchResults
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .darkGray
        header.tintColor = Colors.backgroundGray
        header.textLabel?.frame = header.frame
        header.textLabel?.font = Fonts.RptaSignage.fifteen
    }
}
