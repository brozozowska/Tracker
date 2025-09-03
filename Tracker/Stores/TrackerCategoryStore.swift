//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Сергей Розов on 31.08.2025.
//

import UIKit
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
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Public Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    // MARK: - Methods
    func fetchCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        guard let objects = try? context.fetch(request) else { return [] }
        return objects.compactMap { self.mapToCategory($0) }
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = category.title
        entity.trackers = NSSet(array: category.trackers.map { self.mapToCoreData($0) })
        try context.save()
    }
    
    func category(withTitle title: String) -> TrackerCategory? {
        return fetchCategories().first { $0.title == title }
    }
    
    // MARK: - Mapping
    private func mapToCategory(_ object: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = object.title else { return nil }
        let trackers = (object.trackers as? Set<TrackerCoreData>)?
            .compactMap { self.mapToTracker($0) } ?? []
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func mapToTracker(_ object: TrackerCoreData) -> Tracker? {
        guard
            let id = object.id,
            let title = object.title,
            let emoji = object.emoji,
            let color = object.color as? UIColor,
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
        
        if let existing = try? context.fetch(request).first {
            return existing
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
}
