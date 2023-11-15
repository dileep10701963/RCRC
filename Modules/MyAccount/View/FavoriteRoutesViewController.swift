//
//  FavoriteRoutesViewController.swift
//  RCRC
//
//  Created by Errol on 19/02/21.
//

import UIKit
import GoogleMaps

class FavoriteRoutesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitle: UILabel!
    var favoriteRoutes: [FavoriteRoute]?
    let coordinate = "coordinate"
    let stop = "stop"
    private var travelPreferenceModel: TravelPreferenceModel? = nil
    var travelPreferencesViewModel = TravelPreferencesViewModel()
    var activityIndicator: UIActivityIndicatorView?
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.favoriteRoutes.localized)
        headerTitle.text = Constants.favoriteRoutes.localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .favouriteRoute)
        tableView.register(FavoriteRouteTableViewCell.nib, forCellReuseIdentifier: FavoriteRouteTableViewCell.identifier)
        tableView.delegate = self
        favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
        self.activityIndicator = self.startActivityIndicator()
        self.disableLargeNavigationTitleCollapsing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        fetchTravelPreferences()
    }

    private func fetchTravelPreferences() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.disableUserInteractionWhenAPICalls()
        travelPreferencesViewModel.fetchTravelPreferencesResult()
        travelPreferencesViewModel.travelPreferencesResult.bind { (preferences, error) in
            DispatchQueue.main.async {
                self.enableUserInteractionWhenAPICalls()
                self.activityIndicator?.stop()
                if let preferences = preferences {
                    self.travelPreferenceModel = preferences
                }
            }
        }
    }
    @objc func deleteButtonPressed(button: UIButton) {
        if let favouriteRoute = favoriteRoutes?[button.tag] {
            self.showCustomAlert(alertTitle: "", alertMessage: "\(Constants.origin) \(favouriteRoute.sourceAddress ?? "") \n \(Constants.destination) \(String(describing: favouriteRoute.destinationAddress ?? emptyString))", firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: cancel, secondActionStyle: .cancel, firstActionHandler: {
                FavoriteRouteDataRepository.shared.delete(record: favouriteRoute)
                self.favoriteRoutes?.remove(at: button.tag)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, secondActionHandler: nil)
        }
    }
}

extension FavoriteRoutesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let favoriteRoutes = self.favoriteRoutes {
            self.tableView.restore()
            return favoriteRoutes.count
        } else {
            self.tableView.setEmptyMessage(Constants.noFavoriteRouteAvailable)
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteRouteTableViewCell.identifier, for: indexPath) as? FavoriteRouteTableViewCell
        if let favoriteRoutes = self.favoriteRoutes {
            if let source = favoriteRoutes[indexPath.row].sourceAddress, let destination = favoriteRoutes[indexPath.row].destinationAddress {
                cell?.source.attributedText = Utilities.shared.getAttributedText(source, favoriteRoutes[indexPath.row].sourceType, Fonts.Regular.fourteen!, Fonts.Light.fourteen!)
                cell?.destination.attributedText = Utilities.shared.getAttributedText(destination, favoriteRoutes[indexPath.row].destinationType, Fonts.Regular.fourteen!, Fonts.Light.fourteen!)
                cell?.deleteButton.addTarget(self, action: #selector(deleteButtonPressed(button:)), for: .touchUpInside)
            }
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        case stop:
            if let sourceLatitude = route.sourceLatitude?.toDouble(), let sourceLongitude = route.sourceLongitude?.toDouble() {
                source.coordinate = CLLocationCoordinate2D(latitude: sourceLatitude, longitude: sourceLongitude)
            }
            source.address = route.sourceAddress
            source.id = route.sourceId
            source.type = .stop
        default:
            break
        }
        source.address = route.sourceAddress
        switch favoriteRoutes[indexPath.row].destinationType {
        case coordinate:
            guard let destinationLatitude = route.destinationLatitude?.toDouble(), let destinationLongitude = route.destinationLongitude?.toDouble() else { return }
            destination.coordinate = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
            destination.type = .coordinate
        case stop:
            if let destinationLatitude = route.destinationLatitude?.toDouble(), let destinationLongitude = route.destinationLongitude?.toDouble() {
                destination.coordinate = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
            }
            destination.address = route.destinationAddress
            destination.id = route.destinationId
            destination.type = .stop
        default:
            break
        }
        destination.address = route.destinationAddress
        let availableRoutesViewController: AvailableRoutesViewController = AvailableRoutesViewController.instantiate(appStoryboard: .availableRoutes)
        routeSelectionViewData?.originSearchText = source.address ?? emptyString
        routeSelectionViewData?.destinationSearchText = destination.address ?? emptyString
        availableRoutesViewController.initialize(with: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: travelPreferenceModel)
        self.navigationController?.pushViewController(availableRoutesViewController, animated: true)
    }
}
