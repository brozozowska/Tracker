//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Сергей Розов on 31.08.2025.
//

import UIKit
import CoreData

// MARK: - Protocol
protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdate(_ records: [TrackerRecord])
}

// MARK: - TrackerRecordStore
final class TrackerRecordStore: NSObject {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
    weak var delegate: TrackerRecordStoreDelegate?

    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: - Methods
    func fetchRecords() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        guard let objects = try? context.fetch(request) else { return [] }
        return objects.compactMap { self.mapToRecord($0) }
    }
    
    func record(for trackerId: UUID, on date: Date) -> TrackerRecord? {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            trackerId as CVarArg,
            startOfDay as CVarArg,
        )
        
        request.fetchLimit = 1
        
        guard let result = try? context.fetch(request).first else { return nil }
        return mapToRecord(result)
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let entity = TrackerRecordCoreData(context: context)
        
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
        
        guard let trackerObject = try context.fetch(trackerRequest).first
        else { fatalError("Трекер не найден в БД") }
        
        entity.trackerId = record.trackerId
        entity.date = record.date
        entity.tracker = trackerObject
        
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: record.date)

        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            startOfDay as CVarArg
        )
        
        if let objectToDelete = try context.fetch(request).first {
            context.delete(objectToDelete)
            try context.save()
        }
    }
    
    // MARK: - Mapping
    private func mapToRecord(_ object: TrackerRecordCoreData) -> TrackerRecord? {
        guard
            let trackerId = object.trackerId,
            let date = object.date
        else { return nil }
        
        return TrackerRecord(
            trackerId: trackerId,
            date: date
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let records = controller.fetchedObjects as? [TrackerRecordCoreData] else { return }
        let mapped = records.compactMap(mapToRecord)
        delegate?.storeDidUpdate(mapped)
    }
}
