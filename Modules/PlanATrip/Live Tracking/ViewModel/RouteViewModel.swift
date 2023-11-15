//
//  RouteViewModel.swift
//  DynamicRouteview
//
//  Created by anand madhav on 20/05/20.
//  Copyright © 2020 anand madhav. All rights reserved.
//

import UIKit

class RouteViewModel: NSObject {

    enum TravelMode {
        case walk, bus, endWalk, train, metro, map
    }
    var isMapViewDisabled = false
    public func routeCell (availableRoutesViewModel: AvailableRoutesViewModel, indexPath: IndexPath, index: Int, tableview: UITableView, isActive: Bool = false) -> UITableViewCell {
        let travelMode = availableRoutesViewModel.routeResult.value?.journeys?[indexPath.section]?.legs?[index]?.transportation?.product?.name
        if indexPath.row > 0 || isMapViewDisabled {
            switch travelMode {
            case ViewControllerConstants.AvailableRoutes.RouteTitle.footPathTitle:
                let cell: WalkRouteTableViewCell? = tableview.dequeueReusableCell(withIdentifier: CellTitle.walkRouteTableViewCell) as? WalkRouteTableViewCell
                let travelModeDescription = availableRoutesViewModel.fetchTravelDetails(indexPath: indexPath, index: index)
                cell?.configureCell(travelModeDescription: travelModeDescription, index: index, indexPath: indexPath)
                return cell ?? UITableViewCell()
            case ViewControllerConstants.AvailableRoutes.RouteTitle.busTitle:
                let cell: BusRouteTableViewCell? = tableview.dequeueReusableCell(withIdentifier: CellTitle.busRouteTableViewCell) as? BusRouteTableViewCell
                let travelModeDescription = availableRoutesViewModel.fetchTravelDetails(indexPath: indexPath, index: index)
                cell?.configureCell(travelModeDescription: travelModeDescription, index: index, indexPath: indexPath, isActive: isActive)
                return cell ?? UITableViewCell()
            case ViewControllerConstants.AvailableRoutes.RouteTitle.endWalkTitle:
                let cell: EndRouteWalkTableViewCell? = tableview.dequeueReusableCell(withIdentifier: CellTitle.endRouteWalkTableViewCell) as? EndRouteWalkTableViewCell
                return cell ?? UITableViewCell()
            case ViewControllerConstants.AvailableRoutes.RouteTitle.metroTitle:
                let cell: TrainRouteTableViewCell? = tableview.dequeueReusableCell(withIdentifier: CellTitle.trainRouteTableViewCell) as? TrainRouteTableViewCell
                return cell ?? UITableViewCell()
            default:
                let cell: MapTableViewCell? = tableview.dequeueReusableCell(withIdentifier: CellTitle.mapTableViewCell) as? MapTableViewCell
                return cell ?? UITableViewCell()
            }
        } else {
            let cell: MapTableViewCell? = tableview.dequeueReusableCell(withIdentifier: CellTitle.mapTableViewCell) as? MapTableViewCell
            let travelModeDescription = availableRoutesViewModel.fetchTravelDetails(indexPath: indexPath, index: index)
            cell?.configureCell(travelModeDescription: travelModeDescription, index: indexPath.row, indexPath: indexPath)
            return cell ?? UITableViewCell()
        }
    }

    public func walkMoreArray() -> [String] {
        let routeLists: Array = [ViewControllerConstants.AvailableRoutes.LetterTitle.letterWTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterBTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterMTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterETitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterMTitle]
        return routeLists
    }

    public func walkSameArray() -> [String] {
        let routeLists: Array = [ViewControllerConstants.AvailableRoutes.LetterTitle.letterWTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterBTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterTTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterMTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterETitle]
        return routeLists
    }

    public func defaultRouteArray() -> [String] {
        let routeLists: Array = [ViewControllerConstants.AvailableRoutes.LetterTitle.letterWTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterBTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterWTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterBTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterWTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterBTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterWTitle, ViewControllerConstants.AvailableRoutes.LetterTitle.letterBTitle]
        return routeLists
    }
}
