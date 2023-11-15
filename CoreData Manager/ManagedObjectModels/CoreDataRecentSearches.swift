//
//  CoreDataRecentSearches.swift
//  RCRC
//
//  Created by Errol on 22/02/21.
//

import Foundation
import CoreData

@objc(CoreDataRecentSearches)
public class CoreDataRecentSearches: NSManagedObject {

}

extension CoreDataRecentSearches {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataRecentSearches> {
        return NSFetchRequest<CoreDataRecentSearches>(entityName: "CoreDataRecentSearches")
    }

    func convertToRecentSearch() -> RecentSearch {
        return RecentSearch(id: self.id, location: self.location, address: self.address, latitude: self.latitude?.toDouble(), longitude: self.longitude?.toDouble(), type: self.type)
    }

    @NSManaged var id: String?
    @NSManaged var location: String?
    @NSManaged var address: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var type: String?
}
