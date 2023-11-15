//
//  CoreDataRecentFavouriteroutes+CoreDataProperties.swift
//  RCRC
//
//  Created by Admin on 24/11/20.
//
//

import Foundation
import CoreData

extension CoreDataRecentFavouriteroutes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataRecentFavouriteroutes> {
        return NSFetchRequest<CoreDataRecentFavouriteroutes>(entityName: "CoreDataRecentFavouriteroutes")
    }

    @NSManaged public var endpointAddress: String?
    @NSManaged public var endPointLatitude: Double
    @NSManaged public var endPointLongitude: Double
    @NSManaged public var isFavourite: Bool
    @NSManaged public var startPointAddress: String?
    @NSManaged public var startPointLatitude: Double
    @NSManaged public var startPointLongitude: Double
    @NSManaged public var travelDate: String?

}
