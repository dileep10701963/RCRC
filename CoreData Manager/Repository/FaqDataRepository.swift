//
//  FaqDataRepository.swift
//  RCRC
//
//  Created by Ganesh Shinde on 12/08/20.
//

import UIKit
import CoreData

protocol FaqRepository: BaseRepository {
    // Add additional functions here
}

class FaqDataRepository: FaqRepository {

    // MARK: - API RESPONSE MODEL

    typealias T = FAQResponse

    // MARK: - Save Response object into coredata

    func create(record: FAQResponse) {

        let faq = CoreDataFAQ(context: PersistentStorage.shared.context)
        faq.question = record.question
        faq.answer = record.answer
        PersistentStorage.shared.saveContext()

    }

    // MARK: - Fetch Response Model from coredata

    func fetchAll() -> [FAQResponse]? {

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataFAQ.self)
        guard records != nil && records?.count != 0 else {return nil}

        var results: [FAQResponse] = []
        records!.forEach({ (cdPerson) in
            results.append(cdPerson.convertToFAQResponse())
        })
        return results
    }

    // MARK: - Delete all data

    func deleteAll(entity: RCRCoreDataEntity) {

        PersistentStorage.shared.deleteAll(entity: .faq)
    }

}

struct FAQResponse {
    let question: String?
    let answer: String?

}
