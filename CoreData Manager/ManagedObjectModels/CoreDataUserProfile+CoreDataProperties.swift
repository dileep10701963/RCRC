//
//  CoreDataUserProfile+CoreDataProperties.swift
//  RCRC
//
//  Created by Admin on 24/11/20.
//
//

import Foundation
import CoreData

extension CoreDataUserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataUserProfile> {
        return NSFetchRequest<CoreDataUserProfile>(entityName: "CoreDataUserProfile")
    }

    @NSManaged public var emailAddress: String?
    @NSManaged public var fullName: String?
    @NSManaged public var mobileNumber: String?
    @NSManaged public var image: Data?

}
