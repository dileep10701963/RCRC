//
//  EventCellViewModel.swift
//  RCRC
//
//  Created by Errol on 24/06/21.
//

import Foundation
import GoogleMaps

enum EventType: String {
    case upcoming = "Upcoming Events"
    case current = "Current Events"
    case completed
}

class EventCellViewModel {
    let name: String
    var address: String?
    var distance: String?
    let duration: NSAttributedString
    let imageURL: URL
    let entryCost: String
    let entryFee: NSAttributedString
    let description: String
    let coordinate: CLLocationCoordinate2D?
    let eventType: EventType

    init(name: String, duration: NSAttributedString, imageURL: URL, entryFee: NSAttributedString, description: String, coordinate: CLLocationCoordinate2D?, entryCost: String, eventType: EventType) {
        self.name = name
        self.duration = duration
        self.imageURL = imageURL
        self.entryFee = entryFee
        self.description = description
        self.coordinate = coordinate
        self.entryCost = entryCost
        self.eventType = eventType
    }

    func getAddress(completion: @escaping (String?) -> Void) {
        if let coordinate = self.coordinate {
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(coordinate.latitude),\(coordinate.longitude)") { response in
                self.address = response?.results?.first?.formattedAddress
                completion(response?.results?.first?.formattedAddress)
            }
        } else {
            completion(nil)
        }
    }

    func getDistance(from location: CLLocationCoordinate2D?, completion: @escaping (String?) -> Void) {
        if let destination = self.coordinate, let origin = location {
            GoogleApiHelper.SharedInstance.getDistance(origin: origin, destination: destination) { distance in
                self.distance = distance
                completion(distance)
            }
        } else {
            completion(nil)
        }
    }

    func loadImage(completion: @escaping (UIImage?) -> Void) {
        ServiceManager.sharedInstance.downloadImage(url: imageURL) { result in
            switch result {
            case let .success(image):
                completion(image)
            case .failure:
                completion(nil)
            }
        }
    }
}
