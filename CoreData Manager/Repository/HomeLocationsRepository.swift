//
//  HomeLocationsRepository.swift
//  RCRC
//
//  Created by Errol on 16/04/21.
//

import Foundation
import CoreData

protocol HomeLocationsRepository: BaseRepository {
    func delete(record: T)
}

class HomeLocationsDataRepository: HomeLocationsRepository {

    static let shared = HomeLocationsDataRepository()
    typealias T = SavedLocation

    func create(record: SavedLocation) {

        let location = CoreDataHomeLocations(context: PersistentStorage.shared.context)
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

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataHomeLocations.self)
        guard records != nil && records?.count != 0 else { return nil }

        var results: [SavedLocation] = []
        records!.forEach({ (location) in
            results.append(location.convertToModel())
        })
        return results

    }

    func delete(record: SavedLocation) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataHomeLocations")
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "id = %@", record.id ?? NSNull()))
        predicates.append(NSPredicate(format: "location = %@", record.location ?? NSNull()))
        predicates.append(NSPredicate(format: "address = %@", record.address ?? NSNull()))
        predicates.append(NSPredicate(format: "latitude = %@", record.latitude?.string ?? NSNull()))
        predicates.append(NSPredicate(format: "longitude = %@", record.longitude?.string ?? NSNull()))
        predicates.append(NSPredicate(format: "type = %@", record.type ?? NSNull()))

        if predicates.count > 0 {
            let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
            fetchRequest.predicate = predicate
        }
        do {
            let test = try PersistentStorage.shared.context.fetch(fetchRequest)
            let recordToDelete = test[safe: 0] as? NSManagedObject
            if let recordToDelete = recordToDelete {
                PersistentStorage.shared.context.delete(recordToDelete)
            }
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
        PersistentStorage.shared.deleteAll(entity: .homeLocations)
    }
}
