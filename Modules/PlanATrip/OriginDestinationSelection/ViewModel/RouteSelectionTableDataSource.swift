//
//  SelectOriginDestinationTableViewModel.swift
//  RCRC
//
//  Created by Errol on 16/07/20.
//

import Foundation
import UIKit
import GoogleMaps

extension Constants {

    static let selectLocationButtonTitle = "Select Location On Map"

    struct TableViewHeaderTitles {
        static let quickSelect = "Quick Select"
        static let selectLocationOnMap = " "
        static let recentSearches = "Recent Searches"
    }
}

protocol QuickSelectionDelegate: AnyObject {
    func didSelectPlace(id: String?, address: String?)
    func didSelectPlace(_ place: RecentSearch?)
    func navigateTo(_ type: PlaceType)
    func selectLocationOnMapTapped()
    func recentSearchDeleted(recentSearch: RecentSearch)
    func deleteAllRecentSearch()
    func deleteButtonPressed(button: UIButton, favouriteRoute: FavoriteRoute)
    func popOrPushToAvailableRouteViewController(source: LocationData, destination: LocationData)
}

extension QuickSelectionDelegate {
    func didSelectPlace(_ place: RecentSearch?) {}
    func didSelectPlace(id: String?, address: String?) {}
    func navigateTo(_ type: PlaceType) {}
    func selectLocationOnMapTapped() {}
    func recentSearchDeleted(recentSearch: RecentSearch) {}
    func deleteAllRecentSearch() {}
    func deleteButtonPressed(button: UIButton, favouriteRoute: FavoriteRoute) {}
    func popOrPushToAvailableRouteViewController(source: LocationData, destination: LocationData) {}
}

class RouteSelectionTableDataSource: NSObject {

    weak var delegate: QuickSelectionDelegate?
    var recentSearches: [RecentSearch]? = [RecentSearch]()
    var isShowHistoryTapped: Bool = false
    
    var favoriteRoutes: [FavoriteRoute]? = [FavoriteRoute]()
    var isFavoriteRoutesTapped: Bool = false
    let coordinate = "coordinate"
    let stop = "stop"
    
    var isHomeSaved: Bool {
        if let savedLocations = HomeLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
            return true
        } else {
            return false
        }
    }
    var isWorkSaved: Bool {
        if let savedLocations = WorkLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
            return true
        } else {
            return false
        }
    }
    var isFavoriteSaved: Bool {
        if let savedLocations = FavoriteLocationDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
            return true
        } else {
            return false
        }
    }

    var isSchoolSaved: Bool {
        if let savedLocations = SchoolLocationsDataRepository.shared.fetchAll(), savedLocations.isNotEmpty {
            return true
        } else {
            return false
        }
    }
    func isLocationFavorite(location: SavedLocation) -> Bool {
        var isFavorite: Bool = false
        if let savedData = FavoriteLocationDataRepository.shared.fetchAll() {
            for x in savedData {
                if location == x {
                    isFavorite = true
                    break
                } else {
                    isFavorite = false
                }
            }
        }
        return isFavorite
    }

    func saveFavorite(location: SavedLocation) {
        FavoriteLocationDataRepository.shared.create(record: location)
    }

    func removeFavorite(location: SavedLocation) {
        if isLocationFavorite(location: location) {
            FavoriteLocationDataRepository.shared.delete(record: location)
        }
    }

    @objc func addButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            delegate?.navigateTo(.home)
        case 1:
            delegate?.navigateTo(.work)
        case 2:
            delegate?.navigateTo(.favorite)
        case 3:
            delegate?.navigateTo(.school)
        default:
            break
        }

    }
}

extension RouteSelectionTableDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isFavoriteRoutesTapped {
            return UIView()
        }
        else {
            if self.recentSearches?.count ?? 0 > 1 {
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String.className(RecentSearchHeaderView.self)) as? RecentSearchHeaderView
                headerView?.delegate = self
                return headerView
            } else {
                return tableView.tempHeaderView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isFavoriteRoutesTapped {
            if self.favoriteRoutes?.count ?? 0 <= 0 {
                return
            }
            tapOnFavouriteRoutes(indexPath: indexPath)
        } else {
            /*let recentSearchCount = self.recentSearches?.count ?? 0
             if recentSearchCount > 5 && isShowHistoryTapped == false && indexPath.row == 5 {
             isShowHistoryTapped = true
             tableView.reloadData()
             } else {*/
            if let currentCell = tableView.cellForRow(at: indexPath) as? EmptyTableViewCell {
                if currentCell.textLabel?.text == Constants.noRecentSearches.localized {
                    return
                }
            } else {
                delegate?.didSelectPlace(recentSearches?[indexPath.row])
            }
            // }
        }
    }
    
    private func tapOnFavouriteRoutes(indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
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

        delegate?.popOrPushToAvailableRouteViewController(source: source, destination: destination)
    }
}

extension RouteSelectionTableDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFavoriteRoutesTapped {
            return self.favoriteRoutes?.count ?? 0 <= 0 ? 1 : self.favoriteRoutes?.count ?? 0
        } else {
            self.recentSearches = RecentSearchDataRepository.shared.fetchAll()
            self.recentSearches?.reverse()
            let count = self.recentSearches?.count ?? 0
            if count > 0 {
                /*if count <= 5 {
                 return count
                 } else {
                 if count > 5 && isShowHistoryTapped {
                 if count > 20 {
                 for i in 20..<count {
                 if let recentSearch = self.recentSearches?[i] {
                 RecentSearchDataRepository.shared.delete(record: recentSearch)
                 }
                 }
                 return 20
                 } else {
                 return count
                 }
                 } else {
                 return 6
                 }
                 }*/
                
                if count > 10 {
                    for i in 10..<count {
                        if let recentSearch = self.recentSearches?[i] {
                            RecentSearchDataRepository.shared.delete(record: recentSearch)
                        }
                    }
                    return 10
                } else {
                    return count
                }
            } else {
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isFavoriteRoutesTapped {
            if self.favoriteRoutes?.count ?? 0 > 0 {
                return setupCellForFavouritesRoute(indexPath: indexPath, tableView: tableView)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
                cell?.textLabel?.text = Constants.noFavorites.localized
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.font = Fonts.CodecRegular.eighteen
                cell?.accessoryView = nil
                return cell ?? UITableViewCell()
            }
        } else {
            let recentSearchCount = self.recentSearches?.count ?? 0
            if recentSearchCount == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
                cell?.textLabel?.text = Constants.noRecentSearches.localized
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.font = Fonts.CodecRegular.eighteen
                return cell ?? UITableViewCell()
            } /*else if recentSearchCount > 5 && isShowHistoryTapped == false && indexPath.row == 5 {
               let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
               cell?.textLabel?.text = Constants.showMoreHistory.localized
               cell?.textLabel?.textAlignment = .center
               cell?.textLabel?.font = Fonts.CodecBold.fourteen
               cell?.textLabel?.textColor = Colors.textDarkColor
               return cell ?? UITableViewCell()
               }*/else {
                   let cell: RecentSearchTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                   let recentSearch = self.recentSearches?[indexPath.row]
                   let location = SavedLocation(location: recentSearch?.location, address: recentSearch?.address, id: recentSearch?.id, latitude: recentSearch?.latitude, longitude: recentSearch?.longitude, type: recentSearch?.type)
                   cell.configure(location: location, screenName: .RouteSelectionView)
                   cell.favoriteTapped = { [weak tableView] in
                       let favoritesCellIndexPath = IndexPath(row: 2, section: 0)
                       tableView?.reloadRows(at: [favoritesCellIndexPath], with: .fade)
                   }
                   
                   let deleteButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                   deleteButton.setImage(Images.removeSavedLocation, for: .normal)
                   deleteButton.setTitle(emptyString, for: .normal)
                   deleteButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
                   deleteButton.tag = indexPath.row
                   cell.accessoryView = deleteButton
                   
                   return cell
               }
        }
    }
    
    private func setupCellForFavouritesRoute(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteRouteTableViewCell.identifier, for: indexPath) as? FavoriteRouteTableViewCell
        if let favoriteRoutes = self.favoriteRoutes {
            if let source = favoriteRoutes[indexPath.row].sourceAddress, let destination = favoriteRoutes[indexPath.row].destinationAddress {
                cell?.source.attributedText = Utilities.shared.getAttributedText(source, nil,Fonts.CodecRegular.fourteen)
                cell?.destination.attributedText = Utilities.shared.getAttributedText(destination, nil, Fonts.CodecRegular.fourteen)
                cell?.source.setAlignment()
                cell?.destination.setAlignment()
                cell?.deleteButton.tag = indexPath.row
                cell?.deleteButton.addTarget(self, action: #selector(deleteButtonPressed(button:)), for: .touchUpInside)
            }
        }
        return cell ?? UITableViewCell()
    }
    
    @objc func deleteButtonPressed(button: UIButton) {
        if let favouriteRoute = favoriteRoutes?[button.tag] {
            delegate?.deleteButtonPressed(button: button, favouriteRoute: favouriteRoute)
        }
    }
    
    @objc func deleteTapped(_ sender: UIButton) {
        guard let recentSearch = self.recentSearches else { return }
        let recentS = recentSearch[sender.tag]
        delegate?.recentSearchDeleted(recentSearch: recentS)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if RecentSearchDataRepository.shared.fetchAll()?.count ?? 0 > 1 && !isFavoriteRoutesTapped {
            return 42
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension RouteSelectionTableDataSource: QuickSelectionDelegate {

    func selectLocationOnMapTapped() {
        delegate?.selectLocationOnMapTapped()
    }
}

extension RouteSelectionTableDataSource: RecentSearchHeaderViewDelegate {
    
    func deleteAllButtonPressed() {
        delegate?.deleteAllRecentSearch()
    }
}
