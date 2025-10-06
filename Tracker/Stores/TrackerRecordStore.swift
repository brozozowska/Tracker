//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Сергей Розов on 31.08.2025.
//

import CoreData

// MARK: - Protocol
protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdate(_ records: [TrackerRecord])
}

// MARK: - Error
enum TrackerRecordStoreError: Error {
    case trackerNotFound(UUID)
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
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Не удалось выполнить выборку записей: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - Public Properties
    weak var delegate: TrackerRecordStoreDelegate?

    
    // MARK: - Initializers
    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
    }
    
    // MARK: - Methods
    func fetchRecords() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
       
        do {
            let objects = try context.fetch(request)
            return objects.compactMap { self.mapToRecord($0) }
        } catch {
            print("❌ Не удалось выполнить выборку записей: \(error.localizedDescription)")
            return []
        }
    }
    
    func record(for trackerId: UUID, on date: Date) -> TrackerRecord? {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            trackerId as CVarArg,
            startOfDay as CVarArg
        )
        
        request.fetchLimit = 1
        
        do {
            if let result = try context.fetch(request).first {
                return mapToRecord(result)
            }
        } catch {
            print("❌ Не удалось выполнить поиск записи трекера \(trackerId) за \(startOfDay): \(error.localizedDescription)")
        }
        return nil
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let entity = TrackerRecordCoreData(context: context)
        
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
        
        do {
            guard let trackerObject = try context.fetch(trackerRequest).first else {
                print("❌ Трекер с id=\(record.trackerId) не найден в БД")
                throw TrackerRecordStoreError.trackerNotFound(record.trackerId)
            }
            entity.trackerId = record.trackerId
            entity.date = record.date
            entity.tracker = trackerObject
            try context.save()
        } catch {
            print("❌ Не удалось сохранить запись трекера \(record.trackerId) за \(record.date): \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: record.date)

        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            startOfDay as CVarArg
        )
        
        do {
            if let objectToDelete = try context.fetch(request).first {
                context.delete(objectToDelete)
                try context.save()
            }
        } catch {
            print("❌ Не удалось удалить запись трекера \(record.trackerId) за \(startOfDay): \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteAllRecords(for trackerId: UUID) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        do {
            let objects = try context.fetch(request)
            for object in objects {
                context.delete(object)
            }
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("❌ Не удалось удалить все записи трекера id=\(trackerId): \(error.localizedDescription)")
            throw error
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
