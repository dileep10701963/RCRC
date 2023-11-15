//
//  CoreDataSchoolLocations+CoreDataProperties.swift
//  RCRC
//
//  Created by Saheba Juneja on 18/05/22.
//
//

import Foundation
import CoreData


extension CoreDataSchoolLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataSchoolLocations> {
        return NSFetchRequest<CoreDataSchoolLocations>(entityName: "CoreDataSchoolLocations")
    }
    
    func convertToModel() -> SavedLocation {
        return SavedLocation(location: location, address: address, id: id, latitude: latitude?.toDouble(), longitude: longitude?.toDouble(), type: type, tag: tag)
    }
    
    @NSManaged public var address: String?
    @NSManaged public var id: String?
    @NSManaged public var latitude: String?
    @NSManaged public var location: String?
    @NSManaged public var longitude: String?
    @NSManaged public var tag: String?
    @NSManaged public var type: String?

}
