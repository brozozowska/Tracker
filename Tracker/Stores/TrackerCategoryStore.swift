//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Сергей Розов on 31.08.2025.
//

import CoreData

// MARK: - Protocol
protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate(_ categories: [TrackerCategory])
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: NSObject {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Не удалось выполнить выборку категорий: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - Public Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
    }

    // MARK: - Methods
    func fetchCategories() -> [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects.compactMap { self.mapToCategory($0) }
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        if let existing = fetchCategoryObject(withTitle: category.title) {
            let existingTrackers = (existing.trackers as? Set<TrackerCoreData>) ?? []
            var resultSet = existingTrackers
            for tracker in category.trackers {
                let core = mapToCoreData(tracker)
                resultSet.insert(core)
                core.category = existing
            }
            existing.trackers = NSSet(set: resultSet)
        } else {
            let entity = TrackerCategoryCoreData(context: context)
            entity.title = category.title
            let mapped = category.trackers.map { self.mapToCoreData($0) }
            mapped.forEach { $0.category = entity }
            entity.trackers = NSSet(array: mapped)
        }
        
        do {
            try context.save()
        } catch {
            print("❌ Не удалось сохранить категорию '\(category.title)': \(error.localizedDescription)")
            throw error
        }
    }
    
    func category(withTitle title: String) -> TrackerCategory? {
        return fetchCategories().first { $0.title == title }
    }
    
    func fetchCategoryObject(withTitle title: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Не удалось найти категорию '\(title)': \(error.localizedDescription)")
            return nil
        }
    }
    
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        let categoryObject: TrackerCategoryCoreData
        if let existing = fetchCategoryObject(withTitle: title) {
            categoryObject = existing
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = title
            categoryObject = newCategory
        }
        
        let trackerObject = mapToCoreData(tracker)
        trackerObject.category = categoryObject
        
        do {
            try context.save()
        } catch {
            print("❌ Не удалось добавить трекер '\(tracker.title)' в категорию '\(title)': \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateCategoryTitle(oldTitle: String, newTitle: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)
        request.fetchLimit = 1
        do {
            if let object = try context.fetch(request).first {
                object.title = newTitle
                try context.save()
            }
        } catch {
            print("❌ Не удалось обновить категорию '\(oldTitle)' -> '\(newTitle)': \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteCategory(withTitle title: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        do {
            let objects = try context.fetch(request)
            for object in objects {
                context.delete(object)
            }
            try context.save()
        } catch {
            print("❌ Не удалось удалить категорию '\(title)': \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Mapping
    private func mapToCategory(_ object: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = object.title else { return nil }
        let trackers = (object.trackers as? Set<TrackerCoreData>)?
            .compactMap { self.mapToTracker($0) }
            .sorted { $0.title < $1.title } ?? []
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func mapToTracker(_ object: TrackerCoreData) -> Tracker? {
        guard
            let id = object.id,
            let title = object.title,
            let emoji = object.emoji,
            let color = object.color,
            let schedule = object.schedule as? [WeekDay]
        else { return nil }
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    private func mapToCoreData(_ tracker: Tracker) -> TrackerCoreData {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            if let existing = try context.fetch(request).first {
                existing.title = tracker.title
                existing.emoji = tracker.emoji
                existing.color = tracker.color
                existing.schedule = tracker.schedule as NSObject
                return existing
            }
        } catch {
            print("❌ Не удалось выполнить выборку существующего трекера: \(error.localizedDescription)")
        }

        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.color = tracker.color
        entity.schedule = tracker.schedule as NSObject
        return entity
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        delegate?.storeDidUpdate(fetchCategories())
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(fetchCategories())
    }
}
