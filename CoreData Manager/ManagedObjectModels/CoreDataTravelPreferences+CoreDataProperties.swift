//
//  CoreDataTravelPreferences+CoreDataProperties.swift
//  RCRC
//
//  Created by Admin on 24/11/20.
//
//

import Foundation
import CoreData

extension CoreDataTravelPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataTravelPreferences> {
        return NSFetchRequest<CoreDataTravelPreferences>(entityName: "CoreDataTravelPreferences")
    }

    @NSManaged public var mobilityImpairedFriendly: String?
    @NSManaged public var sortingType: String?
    @NSManaged public var transportMethod: String?

}
