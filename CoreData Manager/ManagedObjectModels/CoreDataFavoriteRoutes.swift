//
//  CoreDataFavoriteRoutes.swift
//  RCRC
//
//  Created by Errol on 18/02/21.
//

import Foundation
import CoreData

@objc(CoreDataFavoriteRoutes)
public class CoreDataFavoriteRoutes: NSManagedObject {

}

extension CoreDataFavoriteRoutes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataFavoriteRoutes> {
        return NSFetchRequest<CoreDataFavoriteRoutes>(entityName: "CoreDataFavoriteRoutes")
    }

    func convertToFavoriteRoute() -> FavoriteRoute {
        return FavoriteRoute(sourceType: self.sourceType, destinationType: self.destinationType, sourceId: self.sourceId, destinationId: self.destinationId, sourceAddress: self.sourceAddress, destinationAddress: self.destinationAddress, sourceLatitude: self.sourceLatitude, destinationLatitude: self.destinationLatitude, sourceLongitude: self.sourceLongitude, destinationLongitude: self.destinationLongitude)
    }

    @NSManaged var sourceType: String?
    @NSManaged var destinationType: String?
    @NSManaged var sourceId: String?
    @NSManaged var destinationId: String?
    @NSManaged var sourceAddress: String?
    @NSManaged var destinationAddress: String?
    @NSManaged var sourceLatitude: String?
    @NSManaged var destinationLatitude: String?
    @NSManaged var sourceLongitude: String?
    @NSManaged var destinationLongitude: String?
}
