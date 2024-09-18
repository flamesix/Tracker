//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Юрий Гриневич on 16.09.2024.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    private let context = Store.shared.context
    
    func getCompletedTrackers() throws -> [TrackerRecord] {
        var trackerRecord: [TrackerRecord] = []
        let request = NSFetchRequest<TrackerCoreData>(entityName: Constants.trackerCoreData)
        do {
            let trackersCoreData = try context.fetch(request)
            
            for trackerCoreData in trackersCoreData {
                
                let id = trackerCoreData.id
                var recordTracker: [Date] = []
                let records = trackerCoreData.record?.allObjects as? [TrackerRecordCoreData]
                if let records {
                    for record in records {
                        record.willAccessValue(forKey: "data")
                        if let date = record.date {
                            recordTracker.append(date)
                        }
                    }
                    if let id, !recordTracker.isEmpty {
                        trackerRecord.append(TrackerRecord(id: id, date: recordTracker))
                    }
                }
            }
        } catch {
            throw error
        }
        return trackerRecord
    }
    
    func addNewTrackerRecord(id: UUID, date: Date) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        do {
            let trackers = try context.fetch(fetchRequest)
            if let tracker = trackers.first {
                let trackerRecordCoreDate = TrackerRecordCoreData(context: context)
                trackerRecordCoreDate.date = date
                
                trackerRecordCoreDate.tracker = tracker
                tracker.addToRecord(trackerRecordCoreDate)
                try context.save()
            }
        } catch {
            print("Error finding category: \(error)")
        }
    }
    
    func deleteTrackerRecord(id: UUID, date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@ AND date == %@", id as NSUUID, date as NSDate)
        
        do {
            let records = try context.fetch(fetchRequest)
            if let record = records.first {
                context.delete(record)
                try context.save()
            }
        } catch {
            print("Ошибка поиска записи: \(error)")
        }
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<TrackerRecordCoreData> {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        return controller
    }
}
