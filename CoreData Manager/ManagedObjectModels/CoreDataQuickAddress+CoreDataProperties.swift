//
//  CoreDataQuickAddress+CoreDataProperties.swift
//  RCRC
//
//  Created by Admin on 24/11/20.
//
//

import Foundation
import CoreData

extension CoreDataQuickAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataQuickAddress> {
        return NSFetchRequest<CoreDataQuickAddress>(entityName: "CoreDataQuickAddress")
    }

    @NSManaged public var address: String?
    @NSManaged public var isFavourite: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var placeName: String?
    @NSManaged public var type: String?

}
