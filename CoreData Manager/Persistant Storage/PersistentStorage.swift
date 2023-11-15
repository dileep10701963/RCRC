//
//  PersistentStorage.swift
//  RCRC
//
//  Created by Ganesh Shinde on 10/08/20.
//

import Foundation
import CoreData

final class PersistentStorage {

    private init() {}
    static let shared = PersistentStorage()

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        if ProcessInfo.processInfo.environment["is_testing"] == "true" {
            let container = NSPersistentContainer(name: "RCRC")
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { (description, error) in
                // Check if the data store is in memory
                precondition( description.type == NSInMemoryStoreType )
                // Check if creating container wrong
                if let error = error {
                    fatalError("Create an in-mem coordinator failed \(error)")
                }
            }
            return container
        } else {
            let container = NSPersistentContainer(name: "RCRC")
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    // fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }
    }()

    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func saveContext() {

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }

    }
    // MARK: - Core Data Fetch all objects

    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]? {

        do {
            guard let result = try PersistentStorage.shared.context.fetch(managedObject.fetchRequest()) as? [T] else {return nil}

            return result

        } catch let error {
            debugPrint(error)
        }
        return nil

    }
    // MARK: - Core Data Delete all objects

    func deleteAll(entity: RCRCoreDataEntity) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)

        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false

        do {
            if let items = try PersistentStorage.shared.context.fetch(fetchRequest) as? [NSManagedObject] {

                for item in items {
                    PersistentStorage.shared.context.delete(item)
                }

                // Save Changes
                try PersistentStorage.shared.context.save()
            }

        } catch {
        }
    }

//  Batch delete function commented because XCTestCases doesn't support batch delete
//    func deleteAll(entity: RCRCoreDataEntity) {
//
//        // Create Fetch Request
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
//
//        // Create Batch Delete Request
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try PersistentStorage.shared.context.execute(batchDeleteRequest)
//
//        } catch {
//            // Error Handling
//            let nserror = error as NSError
//             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//
//    }
}
