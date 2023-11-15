//
//  LiveTrackerViewModel.swift
//  RCRC
//
//  Created by Errol on 10/06/21.
//

import Foundation
import GoogleMaps

struct LiveTrackerViewModel {

    let legs: [Leg]

    init(legs: [Leg]) {
        self.legs = legs
    }

    func getTransportModeImages() -> [TransportModeImage] {
        return legs.map { leg -> TransportModeImage? in
            guard let markerCoordinateArray = leg.coords?.first??.compactMap({$0}),
                  let markerLatitude = markerCoordinateArray.first,
                  let markerLongitude = markerCoordinateArray.last else { return nil }
            let location = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)

            switch leg.transportation.product.name {
            case .bus, .BUS, .community, .arabBus:
                return TransportModeImage(image: Images.mapBus!, offset: CGPoint(x: 0.5, y: 0.5), coordinate: location)
            case .footpath, .FootPath, .arabFootpath:
                return TransportModeImage(image: Images.walkingIcon!, offset: CGPoint(x: 0.5, y: 0.5), coordinate: location)
            case .cycling:
                return TransportModeImage(image: Images.transportModeCareem!, offset: CGPoint(x: 0.5, y: 0.5), coordinate: location)
            case .taxi:
                return TransportModeImage(image: Images.transportModeUber!, offset: CGPoint(x: 0.5, y: 0.5), coordinate: location)
            }
        }.compactMap { $0 }
    }

    func getRoutePath() -> [RoutePath] {
        return legs.map { leg -> RoutePath in
            let gmsPath = GMSMutablePath()
            let coords = leg.coords?.compactMap {$0}.map { coord -> CLLocationCoordinate2D in
                let coordinate = coord.compactMap({$0})
                return CLLocationCoordinate2D(
                    latitude: coordinate[coordinate.startIndex],
                    longitude: coordinate[coordinate.endIndex - 1])
            }
            coords?.forEach { gmsPath.add($0) }

            let routeType: Bool = leg.transportation.product.name == .footpath || leg.transportation.product.name == .arabFootpath
            let routeColor: UIColor = routeType ? .lightGray : Colors.green
            let routePath = RoutePath(path: gmsPath, color: routeColor, type: routeType)

            return routePath
        }
    }

    func calculateETA() -> String {
        let totalTime = legs.reduce(0) { $0 + ($1.duration?.minutes ?? 0) }
        let currentTime = Date()
        let calendar = Calendar.current
        let eta = calendar.date(byAdding: .minute, value: totalTime, to: currentTime)?.toString(withFormat: "hh:mm a", timeZone: .AST)
        return eta ?? currentTime.toString(withFormat: "hh:mm a", timeZone: .AST)
    }
    
    func calculateSpeed() -> CLLocationSpeed {
        
        var distance: CLLocationDistance = 0.0
        var speed: CLLocationSpeed = -1
        
        let coords = legs.compactMap {$0}.map { leg -> [CLLocationCoordinate2D] in
            let coords = leg.coords?.compactMap {$0}.map { coord -> CLLocationCoordinate2D in
                let coordinate = coord.compactMap {$0}
                return CLLocationCoordinate2D(
                    latitude: coordinate[coordinate.startIndex],
                    longitude: coordinate[coordinate.endIndex - 1])
            }
            return coords ?? []
        }.flatMap { $0 }
        
        for index in 0 ..< coords.count - 1 where coords.count > 1 {
            distance += coords[index].distance(to: coords[index + 1])
        }
        
        let time = legs.map({$0.duration ?? 0}).reduce(0, +)
        speed = distance / Double(time)
        
        return speed
        
    }
}
