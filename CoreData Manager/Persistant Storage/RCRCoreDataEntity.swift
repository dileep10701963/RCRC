//
//  RCRCoreDataEntity.swift
//  RCRC
//
//  Created by Ganesh Shinde on 20/08/20.
//

import Foundation

// MARK: - Core Data Entity

enum RCRCoreDataEntity: String {

    case contact          = "CoreDataContactInformation"
    case travel           = "CoreDataTravelPreferences"
    case faq              = "CoreDataFAQ"
    case profile          = "CoreDataUserProfile"
    case quickAddress     = "CoreDataQuickAddress"
    case recentFavourite  = "CoreDataRecentFavouriteroutes"
    case favoriteRoute = "CoreDataFavoriteRoutes"
    case favoriteLocation = "CoreDataFavoriteLocations"
    case recentSearches = "CoreDataRecentSearches"
    case homeLocations = "CoreDataHomeLocations"
    case workLocations = "CoreDataWorkLocations"
    case schoolLocations = "CoreDataSchoolLocations"

}
