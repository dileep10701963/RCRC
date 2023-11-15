//
//  RecentSearchesRepository.swift
//  RCRC
//
//  Created by Errol on 22/02/21.
//

import Foundation
import CoreData

protocol RecentSearchRepository: BaseRepository {
    func delete(record: T)
}

class RecentSearchDataRepository: RecentSearchRepository {

    static let shared = RecentSearchDataRepository()
    typealias T = RecentSearch

    func create(record: RecentSearch) {

        let location = CoreDataRecentSearches(context: PersistentStorage.shared.context)
        location.id = record.id
        location.location = record.location
        location.address = record.address
        location.latitude = record.latitude?.string
        location.longitude = record.longitude?.string
        location.type = record.type
        PersistentStorage.shared.saveContext()
    }

    func fetchAll() -> [RecentSearch]? {

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataRecentSearches.self)
        guard records != nil && records?.count != 0 else { return nil }

        var results: [RecentSearch] = []
        records!.forEach({ (location) in
            results.append(location.convertToRecentSearch())
        })
        return results

    }

    func delete(record: RecentSearch) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataRecentSearches")
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "id = %@", record.id ?? NSNull()))
        predicates.append(NSPredicate(format: "location = %@", record.location ?? NSNull()))
        predicates.append(NSPredicate(format: "type = %@", record.type ?? NSNull()))
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
        PersistentStorage.shared.deleteAll(entity: .recentSearches)
    }
}

struct RecentSearch: Equatable {
    var id: String?
    var location: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var type: String?

    static func == (lhs: RecentSearch, rhs: RecentSearch) -> Bool {
        return (lhs.location == rhs.location
                    && lhs.id == rhs.id
                    && lhs.type == rhs.type)
    }
}
