//
//  TrackerStore.swift
//  Tracker
//
//  Created by Сергей Розов on 31.08.2025.
//

import UIKit
import CoreData

// MARK: - Protocol
protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdate(_ trackers: [Tracker])
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
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
            print("❌ Не удалось выполнить выборку трекеров: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - Public Properties
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: - Methods
    func fetchTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { self.mapToTracker($0) }
    }
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.color = tracker.color
        entity.schedule = tracker.schedule as NSObject
        entity.category = category
        
        do {
            try context.save()
        } catch {
            print("❌ Не удалось сохранить новый трекер '\(tracker.title)': \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Mapping
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let trackers = controller.fetchedObjects as? [TrackerCoreData] else { return }
        let mapped = trackers.compactMap(mapToTracker)
        delegate?.storeDidUpdate(mapped)
    }
}
