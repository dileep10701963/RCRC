//
//  TravelfPreferenceRepository.swift
//  RCRC
//
//  Created by Ganesh on 07/05/21.
//

import Foundation
import CoreData

protocol TravewlPreferenceRepository: BaseRepository {
//    func delete(record: T)
}

class TravewlPreferenceDataRepository: TravewlPreferenceRepository {

    // MARK: - API RESPONSE MODEL

    typealias T = TravelPreference

    // MARK: - Save Response object into coredata

    func create(record: TravelPreference) {

        let travalPref = CoreDataTravelPreferences(context: PersistentStorage.shared.context)
        travalPref.mobilityImpairedFriendly = record.mobilityImpairedFriendly
        travalPref.sortingType = record.sortingType
        travalPref.transportMethod = record.transportMethod
        PersistentStorage.shared.saveContext()
    }

    // MARK: - Fetch Response Model from coredata

    func fetchAll() -> [TravelPreference]? {

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataTravelPreferences.self)
        guard records != nil && records?.count != 0 else {return nil}

        var results: [TravelPreference] = []
        records!.forEach({ (cdPerson) in
            results.append(cdPerson.convertToTravelPreference())
        })
        return results
    }

    // MARK: - Delete all data

    func deleteAll(entity: RCRCoreDataEntity) {

        PersistentStorage.shared.deleteAll(entity: .travel)
    }

}

struct TravelPreference {
    var mobilityImpairedFriendly: String?
    var sortingType: String?
    var transportMethod: String?
}
