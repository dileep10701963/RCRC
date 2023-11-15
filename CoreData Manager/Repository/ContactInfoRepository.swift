//
//  ContactInfoRepository.swift
//  RCRC
//
//  Created by Ganesh Shinde on 13/08/20.
//

import Foundation

protocol ContactInfoRepository: BaseRepository {
    // Add additional functions here
}

struct ContactInfoDataRepository: ContactInfoRepository {

    // MARK: - API RESPONSE MODEL
    typealias T = ContactInformation

    // MARK: - Save Response object into coredata

    func create(record: ContactInformation) {

        let contact = CoreDataContactInformation(context: PersistentStorage.shared.context)
        contact.address = record.address
        contact.emailId = record.emailId
        contact.mobileNumber = record.phoneNumber
        PersistentStorage.shared.saveContext()

    }

    // MARK: - Fetch Response Model from coredata

    func fetchAll() -> [ContactInformation]? {

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataContactInformation.self)
        guard records != nil && records?.count != 0 else {return nil}

        var results: [ContactInformation] = []
        records!.forEach({ (cdPerson) in
            results.append(cdPerson.convertToContactInformation())
        })
        return results

    }

    // MARK: - Delete all data

    func deleteAll(entity: RCRCoreDataEntity) {

        PersistentStorage.shared.deleteAll(entity: .contact)

    }
}

struct ContactInformation {
    var address: String?
    var phoneNumber: String?
    var emailId: String?
}

// Sample code for saving and fetching objects from coredata

// let _contactRepo = ContactInfoDataRepository()
// let info = ContactInfo(address: "Satara", phoneNumber: "9900000000", emailId: "shindenganesh@gmail.com")
// _contactRepo.create(record: info)
// let records = _contactRepo.fetchAll()
// print(records)
