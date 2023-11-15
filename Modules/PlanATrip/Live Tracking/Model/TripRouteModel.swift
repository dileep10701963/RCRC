//
//  TripRouteModel.swift
//  RCRC
//
//  Created by Errol on 11/06/21.
//

import UIKit
import GoogleMaps

struct TransportModeImage {
    let image: UIImage
    let offset: CGPoint
    let coordinate: CLLocationCoordinate2D
}

struct RoutePath {
    let path: GMSMutablePath
    let color: UIColor
    let type: Bool
}

struct RoutePathForStop {
    let path: GMSMutablePath
    let color: UIColor
}
