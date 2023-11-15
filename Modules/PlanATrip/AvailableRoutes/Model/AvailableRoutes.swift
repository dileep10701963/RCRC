//
//  AvailableRoutesModel.swift
//  RCRC
//
//  Created by Errol on 21/07/20.
//

import Foundation

struct RouteSelectionViewData {
    var originSearchText: String?
    var destinationSearchText: String?
    var availability: String = Constants.now
    var date: String = Constants.date
    var hour: String = Constants.hour
    var minute: String = Constants.minute
}

var routeSelectionViewData: RouteSelectionViewData? = RouteSelectionViewData()

struct ErrorMessage {
    let title: String
    let description: String
}

enum TripResult {
    case success(Trip)
    case failure(ErrorMessage)
}

enum LineType {
    case solid
    case dotted
}
