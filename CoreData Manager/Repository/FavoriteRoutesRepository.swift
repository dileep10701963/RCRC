//
//  FavoriteRoutesRepository.swift
//  RCRC
//
//  Created by Errol on 18/02/21.
//

import Foundation
import CoreData

protocol FavoriteRouteRepository: BaseRepository {
    func delete(record: T)
}

class FavoriteRouteDataRepository: FavoriteRouteRepository {

    static let shared = FavoriteRouteDataRepository()
    typealias T = FavoriteRoute

    func create(record: FavoriteRoute) {

        let favoriteRoute = CoreDataFavoriteRoutes(context: PersistentStorage.shared.context)
        favoriteRoute.sourceType = record.sourceType
        favoriteRoute.destinationType = record.destinationType
        favoriteRoute.sourceId = record.sourceId
        favoriteRoute.destinationId = record.destinationId
        favoriteRoute.sourceAddress = record.sourceAddress
        favoriteRoute.destinationAddress = record.destinationAddress
        favoriteRoute.sourceLatitude = record.sourceLatitude
        favoriteRoute.destinationLatitude = record.destinationLatitude
        favoriteRoute.sourceLongitude = record.sourceLongitude
        favoriteRoute.destinationLongitude = record.destinationLongitude
        PersistentStorage.shared.saveContext()
    }

    func fetchAll() -> [FavoriteRoute]? {

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataFavoriteRoutes.self)
        guard records != nil && records?.count != 0 else {return nil}

        var results: [FavoriteRoute] = []
        records!.forEach({ (favoriteRoute) in
            results.append(favoriteRoute.convertToFavoriteRoute())
        })
        return results

    }

    func delete(record: FavoriteRoute) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataFavoriteRoutes")
        var predicates = [NSPredicate]()
        if let sourceType = record.sourceType {
            predicates.append(NSPredicate(format: "sourceType = %@", sourceType))
        }
        if let sourceId = record.sourceId {
            predicates.append(NSPredicate(format: "sourceId = %@", sourceId))
        }
        if let sourceAddress = record.sourceAddress {
            predicates.append(NSPredicate(format: "sourceAddress = %@", sourceAddress))
        }

        if let destinationType = record.destinationType {
            predicates.append(NSPredicate(format: "destinationType = %@", destinationType))
        }
        if let destinationId = record.destinationId {
            predicates.append(NSPredicate(format: "destinationId = %@", destinationId))
        }
        if let destinationAddress = record.destinationAddress {
            predicates.append(NSPredicate(format: "destinationAddress = %@", destinationAddress))
        }
        
        if predicates.count > 0 {
            let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
            fetchRequest.predicate = predicate
        }
        do {
            let test = try PersistentStorage.shared.context.fetch(fetchRequest)
            guard let recordToDelete = test[0] as? NSManagedObject else { return }
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
        PersistentStorage.shared.deleteAll(entity: .favoriteRoute)
    }
}

struct FavoriteRoute: Equatable {
    var sourceType: String?
    var destinationType: String?
    var sourceId: String?
    var destinationId: String?
    var sourceAddress: String?
    var destinationAddress: String?
    var sourceLatitude: String?
    var destinationLatitude: String?
    var sourceLongitude: String?
    var destinationLongitude: String?

    static func == (lhs: FavoriteRoute, rhs: FavoriteRoute) -> Bool {
        return (lhs.sourceType == rhs.sourceType && lhs.sourceId == rhs.sourceId && lhs.sourceAddress == rhs.sourceAddress && lhs.destinationType == rhs.destinationType && lhs.destinationId == rhs.destinationId && lhs.destinationAddress == rhs.destinationAddress )
        }
}
