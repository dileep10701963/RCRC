//
//  CoreDataHomeLocations.swift
//  RCRC
//
//  Created by Errol on 16/04/21.
//

import Foundation
import CoreData

@objc(CoreDataHomeLocations)
public class CoreDataHomeLocations: NSManagedObject {

}

extension CoreDataHomeLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataHomeLocations> {
        return NSFetchRequest<CoreDataHomeLocations>(entityName: "CoreDataHomeLocations")
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
