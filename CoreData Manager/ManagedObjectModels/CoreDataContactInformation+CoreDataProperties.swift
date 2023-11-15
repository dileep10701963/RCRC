//
//  CoreDataContactInformation+CoreDataProperties.swift
//  RCRC
//
//  Created by Admin on 24/11/20.
//
//

import Foundation
import CoreData

extension CoreDataContactInformation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataContactInformation> {
        return NSFetchRequest<CoreDataContactInformation>(entityName: "CoreDataContactInformation")
    }

    @NSManaged public var address: String?
    @NSManaged public var emailId: String?
    @NSManaged public var mobileNumber: String?

}
