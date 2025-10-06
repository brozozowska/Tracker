//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Сергей Розов on 04.09.2025.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        
        let description = container.persistentStoreDescriptions.first
        description?.shouldAddStoreAsynchronously = true
        
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("❌ Core Data error: \(error)")
                return
            }
            print("Core Data store loaded: \(desc)")
        }
        
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
        
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ Ошибка сохранения: \(error)")
            context.rollback()
        }
    }
}
