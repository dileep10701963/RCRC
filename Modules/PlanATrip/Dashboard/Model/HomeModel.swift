//
//  HomeModel.swift
//  RCRC
//
//  Created by Sagar Tilekar on 06/07/20.
//  Copyright © 2020 Riyadh Journey Planner. All rights reserved.
//

import Foundation
import GoogleMaps

enum LocationType: String {
    case coordinate
    case stop
}

enum SearchPreferences {
    case date
    case mainOption
    case hour
    case minute
}

enum SearchBars {
    case origin
    case destination
}

struct LocationData: Equatable {

    static func == (lhs: LocationData, rhs: LocationData) -> Bool {
        return lhs.id == rhs.id &&
            lhs.address == rhs.address &&
            lhs.subAddress == rhs.subAddress &&
            lhs.coordinate?.latitude == rhs.coordinate?.latitude &&
            lhs.coordinate?.longitude == rhs.coordinate?.longitude &&
            lhs.type == rhs.type
    }

    var id: String?
    var address: String?
    var subAddress: String?
    var coordinate: CLLocationCoordinate2D?
    var type: LocationType?
}

// MARK: Bus Route Model
struct SelectedRouteModel {
    
    var routeNumber: String = ""
    var isSelected: Bool = false
    
}
