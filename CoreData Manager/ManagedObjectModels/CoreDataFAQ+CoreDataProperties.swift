//
//  CoreDataFAQ+CoreDataProperties.swift
//  RCRC
//
//  Created by Admin on 24/11/20.
//
//

import Foundation
import CoreData

extension CoreDataFAQ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataFAQ> {
        return NSFetchRequest<CoreDataFAQ>(entityName: "CoreDataFAQ")
    }

    @NSManaged public var answer: String?
    @NSManaged public var question: String?

}
