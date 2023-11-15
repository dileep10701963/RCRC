//
//  MapCellViewModel.swift
//  RCRC
//
//  Created by Errol on 28/05/21.
//

import UIKit
import GoogleMaps

class MapCellViewModel {

    var travelTime: String?
    var travelCost: String?
    var routePath = GMSMutablePath()
    var routePaths: [GMSMutablePath]?
    var routePathConfigurations: [(color: UIColor, isDotted: Bool)] = []
    var routeMarkers: [(image: UIImage, offset: CGPoint)]?
    var routeMarkerCoordinates: [CLLocationCoordinate2D] = []
    let journey: Journey
    var originMarker: (image: UIImage, coordinate: CLLocationCoordinate2D)!
    var destinationMarker: (image: UIImage, coordinate: CLLocationCoordinate2D)!
    var isBuyOptionAvailable: Bool = true
    var stopsSequenceMarkers: [(image: UIImage, offset: CGPoint)]?
    var stopMarkerCoordinates: [(stopSequence: StopSequence, coordinate: CLLocationCoordinate2D)] = []
    var fare: Fare?
    
    init(journey: Journey) {
        self.journey = journey
        configureMapCellViewModel(journey: journey)
    }

    private func configureMapCellViewModel(journey: Journey) {
        travelTime = calculateTravelTime(journey.legs)
        travelCost = fetchTravelCost(fare: journey.fare)
        fare = journey.fare
        makeRoutePathWithImages(legs: journey.legs)
        isBuyOptionAvailableForJourney(legs: journey.legs)
        setStopSequenceMarkers(legs: journey.legs)
    }
    
    private func isBuyOptionAvailableForJourney(legs: [Leg?]?) {
        guard let legs = legs, legs.isNotEmpty else { return }
        let isTransportationAvailable = legs.contains(where: {$0?.transportation.product.name == .bus || $0?.transportation.product.name == .BUS || $0?.transportation.product.name == .community || $0?.transportation.product.name == .taxi || $0?.transportation.product.name == .arabBus})
        self.isBuyOptionAvailable = isTransportationAvailable
    }
    
    private func setStopSequenceMarkers(legs: [Leg?]?) {
        guard let legs = legs, legs.isNotEmpty else { return }
        var stopsImages: [[(image: UIImage, offset: CGPoint)]] = []
        for (_, leg) in legs.enumerated() where leg?.stopSequence?.count ?? 0 >= 1 {
            if let legStops = leg?.stopSequence, leg?.transportation.product.name == .bus, leg?.transportation.product.name == .BUS, leg?.transportation.product.name == .community, leg?.transportation.product.name == .arabBus {
                var stopSequences: [StopSequence?] = legStops
                if let originIndex = stopSequences.firstIndex(where: {$0?.name == leg?.origin?.name}) {
                    stopSequences.remove(at: originIndex)
                }
                
                if let destinationIndex = stopSequences.firstIndex(where: {$0?.name == leg?.destination?.name}) {
                    stopSequences.remove(at: destinationIndex)
                }
                
                let stopRouteImages = stopSequences.compactMap({$0}).map { stopSequence -> (UIImage, CGPoint) in
                    if let latitude = stopSequence.coord?.first, let longitude = stopSequence.coord?.last {
                        stopMarkerCoordinates.append((stopSequence, CLLocationCoordinate2D(
                            latitude: latitude,
                            longitude: longitude)))
                    }
                    return (Images.mapBus!, CGPoint(x: 0.5, y: 0.5))
                }
                stopsImages.append(stopRouteImages)
            }
        }
        stopsSequenceMarkers = stopsImages.flatMap{$0.compactMap{$0}}
    }

    private func calculateTravelTime(_ legs: [Leg?]?) -> String? {
        let time = legs?.compactMap({$0}).reduce(0, { $0 + ($1.duration?.minutes ?? 0) })
        switch currentLanguage {
        case .arabic:
            return "\(time ?? 0) \(Constants.minutesRoute.localized)" == "0 \(Constants.minutesRoute.localized)" ? nil : String(format: "عدد (%@) دقيقة", arguments: ["\(time ?? 0)"])
        case .english:
            return "\(time ?? 0) \(Constants.minutesRoute.localized)" == "0 \(Constants.minutesRoute.localized)" ? nil : "\(time ?? 0) \(Constants.minutesRoute.localized)"
        default:
            return nil
        }
    }

    private func fetchTravelCost(fare: Fare?) -> String? {
        let fare = "\(fare?.tickets?.first??.properties?.priceTotalFare ?? "0")\(Constants.currencyTitle.localized)"
        return fare == "0\(Constants.currencyTitle.localized)" ? nil : fare
    }

    private func makeRoutePathWithImages(legs: [Leg?]?) {
        guard let legs = legs, legs.isNotEmpty,
              let originCoordinateArray = legs.first??.coords?.first??.compactMap({$0}),
              let destinationCoordinateArray = legs[legs.count - 1]?.coords?.last??.compactMap({$0}),
              let originLatitude = originCoordinateArray.first,
              let originLongitude = originCoordinateArray.last,
              let destinationLatitude = destinationCoordinateArray.first,
              let destinationLongtitude = destinationCoordinateArray.last
        else { return }

        let originCoordinate = CLLocationCoordinate2D(latitude: originLatitude, longitude: originLongitude)
        let destinationCoordinate = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongtitude)

        // Configure Origin and Destination Marker Images
        self.originMarker = (Images.homeBusStopPin!, originCoordinate)
        self.destinationMarker = (Images.homeBusStopPin!, destinationCoordinate)

        // Configure Stop Images with offsets and get Coordinates of Markers
        let routeImages = legs.compactMap({$0}).map({ leg -> (UIImage, CGPoint) in

            if let markerCoordinateArray = leg.coords?.first??.compactMap({$0}),
               let markerLatitude = markerCoordinateArray.first,
               let markerLongitude = markerCoordinateArray.last {
                self.routeMarkerCoordinates.append(
                    CLLocationCoordinate2D(
                        latitude: markerLatitude,
                        longitude: markerLongitude)
                )
            }

            switch leg.transportation.product.name {
            case .bus, .BUS, .community, .arabBus: return (Images.busStopPin!.imageWithNewSize(), CGPoint(x: 0.5, y: 0.5))
            case .footpath, .FootPath, .arabFootpath: return (Images.walkingIcon!, CGPoint(x: 0.5, y: 0.5))
            case .cycling: return (Images.transportModeCareem!, CGPoint(x: 0.5, y: 0.5))
            case .taxi: return (Images.transportModeUber!, CGPoint(x: 0.5, y: 0.5))
            }

        })
        self.routeMarkers = routeImages
        // Configure Route Paths with Path Color
        self.routePaths = legs.compactMap({$0}).map({ leg -> GMSMutablePath in
            let routePath = GMSMutablePath()
            let coords = leg.coords?.compactMap({$0}).map({ coord -> CLLocationCoordinate2D in
                let coordinate = coord.compactMap({$0})
                return CLLocationCoordinate2D(
                    latitude: coordinate[coordinate.startIndex],
                    longitude: coordinate[coordinate.endIndex - 1])
            })
            coords?.forEach({
                routePath.add($0)
                self.routePath.add($0)
            })
            let transportMode = leg.transportation.product.name
            let isRouteFootpath: Bool = transportMode == .footpath || transportMode == .arabFootpath
            let routeColor: UIColor
            switch transportMode {
            case .footpath, .FootPath, .arabFootpath: routeColor = .lightGray
            case .bus, .BUS, .community, .arabBus: routeColor = Colors.tripBusGreen
            case .cycling: routeColor = Colors.orange
            case .taxi: routeColor = Colors.lightYellow
            }
            self.routePathConfigurations.append((routeColor, isRouteFootpath))
            return routePath
        })
    }
}
