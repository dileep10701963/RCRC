//
//  FavoriteRoutes.swift
//  RCRC
//
//  Created by Saheba Juneja on 12/06/23.
//

import Foundation
import UIKit
import MapKit

protocol FavoriteRoutesViewDelegate: AnyObject {
    func favoriteViewPopWithData(viewModel: AvailableRoutesViewModel, origin: LocationData, destination: LocationData, travelPreference: TravelPreferenceModel?, data: RouteSelectionViewData?)
    func delete(favoriteRoute:FavoriteRoute, at: Int)
}

class FavoriteRoutes: UIView {

    @IBOutlet weak var myFavTableView: UITableView!
    var favoriteRoutes: [FavoriteRoute]?
    weak var delegate: FavoriteRoutesViewDelegate?
    var travelPreferenceModel: TravelPreferenceModel? = nil

    let coordinate = "coordinate"
    let stop = "stop"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    
    func initSubviews() {
        let nib = UINib(nibName: "FavoriteRoutes", bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        myFavTableView.frame = bounds
        myFavTableView.clipsToBounds = true
        addSubview(myFavTableView)
        configureView()
    }
    
    func configureView() {
        myFavTableView.register(FavoriteRouteTableViewCell.nib, forCellReuseIdentifier: FavoriteRouteTableViewCell.identifier)
        
        favoriteRoutes = FavoriteRouteDataRepository.shared.fetchAll()
        myFavTableView.delegate = self
        myFavTableView.dataSource = self
        myFavTableView.reloadData()
    }
}

extension FavoriteRoutes: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.myFavTableView {
            return self.favoriteRoutes?.count ?? 0 <= 0 ? 1 : self.favoriteRoutes?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.myFavTableView {
            if self.favoriteRoutes?.count ?? 0 > 0 {
                return setupCellForFavouritesRoute(indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    private func setupCellForFavouritesRoute(indexPath: IndexPath) -> UITableViewCell {
        let cell = myFavTableView.dequeueReusableCell(withIdentifier: FavoriteRouteTableViewCell.identifier, for: indexPath) as? FavoriteRouteTableViewCell
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
            delegate?.delete(favoriteRoute: favouriteRoute, at: button.tag)
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.myFavTableView {
            if self.favoriteRoutes?.count ?? 0 <= 0 {
                return
            }
            tapOnFavouriteRoutes(indexPath: indexPath)
        }
    }
    
    private func tapOnFavouriteRoutes(indexPath: IndexPath){
        myFavTableView.deselectRow(at: indexPath, animated: true)
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
        delegate?.favoriteViewPopWithData(viewModel: AvailableRoutesViewModel(), origin: source, destination: destination, travelPreference: self.travelPreferenceModel, data: routeSelectionViewData)
    }
}
