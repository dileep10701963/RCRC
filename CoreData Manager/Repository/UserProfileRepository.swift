//
//  UserProfileRepository.swift
//  RCRC
//
//  Created by Admin on 13/11/20.
//

import Foundation
import UIKit
import CoreData

protocol UserProfileRepository: BaseRepository {
    // Add additional functions here
    func delete()
    func update(record: T)
    func fetchImage() -> UIImage
}

struct UserProfileDataRepository: UserProfileRepository {

    // MARK: - API RESPONSE MODEL
    typealias T = ProfileInformation
    static let shared = UserProfileDataRepository()

    // MARK: - Save Response object into coredata

    func create(record: ProfileInformation) {

        let contact = CoreDataUserProfile(context: PersistentStorage.shared.context)
        contact.emailAddress = record.emailAddress
        contact.fullName = record.fullName
        contact.mobileNumber = record.mobileNumber
        contact.image = record.image
        PersistentStorage.shared.saveContext()

    }

    // MARK: - Fetch Response Model from coredata

    func fetchAll() -> [ProfileInformation]? {

        let records = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataUserProfile.self)
        guard records != nil && records?.count != 0 else {return nil}

        var results: [ProfileInformation] = []
        records?.forEach({ (cdPerson) in
            results.append(cdPerson.convertToProfileInformation())
        })
        return results
    }

    // MARK: - Update data if record exists, else create new record
    func update(record: ProfileInformation) {
        if let savedRecords = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataUserProfile.self),
           let savedRecord = savedRecords.first {
            savedRecord.fullName = record.fullName
            savedRecord.emailAddress = record.emailAddress
            savedRecord.mobileNumber = record.mobileNumber
            savedRecord.image = record.image
            do {
                try PersistentStorage.shared.context.save()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            create(record: record)
        }
    }

    func fetchImage() -> UIImage {
        guard let savedRecords = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataUserProfile.self),
              let savedRecord = savedRecords.first,
              let imageData = savedRecord.image,
              let image = UIImage(data: imageData) else { return Images.profileImagePlaceholder ?? UIImage() }
        return image
    }

    func delete() {
        guard let savedRecords = PersistentStorage.shared.fetchManagedObject(managedObject: CoreDataUserProfile.self),
              let savedRecord = savedRecords.first else { return }
        PersistentStorage.shared.context.delete(savedRecord)
        do {
            try PersistentStorage.shared.context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Delete all data
    func deleteAll(entity: RCRCoreDataEntity) {
        PersistentStorage.shared.deleteAll(entity: .profile)
    }
}

struct ProfileInformation {
    var emailAddress: String?
    var mobileNumber: String?
    var fullName: String?
    var image: Data?

    static func == (lhs: ProfileInformation, rhs: ProfileInformation) -> Bool {
        return (lhs.fullName == rhs.fullName
                    && lhs.emailAddress == rhs.emailAddress
                    && lhs.mobileNumber == rhs.mobileNumber
                    && lhs.image == rhs.image)
    }
}

// Sample code for saving and fetching objects from coredata

// let _contactRepo = UserProfileDataRepository()
// let info = ProfileInfo(email: "test@gmail.com", mobile: "99ooo00000", name: "Test", job: "Tester")
// _contactRepo.create(record: info)
// let records = _contactRepo.fetchAll()
// print(records)
