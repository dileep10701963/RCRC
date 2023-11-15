//
//  FavoriteLocationsRepository.swift
//  RCRC
//
//  Created by Errol on 19/02/21.
//

import Foundation
import CoreData

protocol FavoriteLocationRepository: BaseRepository {
    func delete(record: T)
}

class FavoriteLocationDataRepository: FavoriteLocationRepository {

    static let shared = FavoriteLocationDataRepository()
    typealias T = SavedLocation

    func create(record: SavedLocation) {

        let location = CoreDataFavoriteLocations(context: PersistentStorage.shared.context)
        location.id = record.id
        location.location = record.location
        location.address = record.address
        location.latitude = record.latitude?.string
        location.longitude = record.longitude?.string
        location.type = record.type
        location.tag = record.tag
        PersistentStorage.shared.saveContext()
    }

    func fetchAll() -> [SavedLocation]? {

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataFavoriteLocations.self)
        guard records != nil && records?.count != 0 else { return nil }

        var results: [SavedLocation] = []
        records!.forEach({ (favoriteRoute) in
            results.append(favoriteRoute.convertToFavoriteLocation())
        })
        return results

    }

    func delete(record: SavedLocation) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataFavoriteLocations")
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "id = %@", record.id ?? NSNull()))
        predicates.append(NSPredicate(format: "location = %@", record.location ?? NSNull()))
        predicates.append(NSPredicate(format: "address = %@", record.address ?? NSNull()))
        predicates.append(NSPredicate(format: "latitude = %@", record.latitude?.string ?? NSNull()))
        predicates.append(NSPredicate(format: "longitude = %@", record.longitude?.string ?? NSNull()))
        predicates.append(NSPredicate(format: "type = %@", record.type ?? NSNull()))
        predicates.append(NSPredicate(format: "tag = %@", record.tag ?? NSNull()))

        if predicates.count > 0 {
            let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
            fetchRequest.predicate = predicate
        }
        do {
            let test = try PersistentStorage.shared.context.fetch(fetchRequest)
            guard let recordToDelete = test[safe: 0] as? NSManagedObject else { return }
            PersistentStorage.shared.context.delete(recordToDelete)
            do {
                try PersistentStorage.shared.context.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }

    func deleteAll(entity: RCRCoreDataEntity) {
        PersistentStorage.shared.deleteAll(entity: .favoriteLocation)
    }
}

struct FavoriteLocation: Equatable {
    var id: String?
    var location: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var type: String?

    static func == (lhs: FavoriteLocation, rhs: FavoriteLocation) -> Bool {
        return (lhs.location == rhs.location
                    && lhs.latitude == rhs.latitude
                    && lhs.longitude == rhs.longitude
                    && lhs.address == rhs.address
                    && lhs.id == rhs.id
                    && lhs.type == rhs.type)
    }
}
