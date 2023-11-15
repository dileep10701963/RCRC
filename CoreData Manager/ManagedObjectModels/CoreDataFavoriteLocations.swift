//
//  CoreDataFavoriteLocations.swift
//  RCRC
//
//  Created by Errol on 19/02/21.
//

import Foundation
import CoreData

@objc(CoreDataFavoriteLocations)
public class CoreDataFavoriteLocations: NSManagedObject {

}

extension CoreDataFavoriteLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataFavoriteLocations> {
        return NSFetchRequest<CoreDataFavoriteLocations>(entityName: "CoreDataFavoriteLocations")
    }

    func convertToFavoriteLocation() -> SavedLocation {
        return SavedLocation(location: self.location, address: self.address, id: self.id, latitude: self.latitude?.toDouble(), longitude: self.longitude?.toDouble(), type: self.type, tag: self.tag)
    }

    @NSManaged var id: String?
    @NSManaged var location: String?
    @NSManaged var address: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var type: String?
    @NSManaged var tag: String?

}
