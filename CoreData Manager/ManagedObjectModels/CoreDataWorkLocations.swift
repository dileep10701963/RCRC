//
//  CoreDataWorkLocations.swift
//  RCRC
//
//  Created by Errol on 16/04/21.
//

import Foundation
import CoreData

@objc(CoreDataWorkLocations)
public class CoreDataWorkLocations: NSManagedObject {

}

extension CoreDataWorkLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataWorkLocations> {
        return NSFetchRequest<CoreDataWorkLocations>(entityName: "CoreDataWorkLocations")
    }

    func convertToModel() -> SavedLocation {
        return SavedLocation(location: location, address: address, id: id, latitude: latitude?.toDouble(), longitude: longitude?.toDouble(), type: type, tag: tag)
    }

    @NSManaged var id: String?
    @NSManaged var location: String?
    @NSManaged var address: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var type: String?
    @NSManaged var tag: String?
}
