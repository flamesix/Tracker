import CoreData

final class TrackerRecordStore {
    private let context = Store.shared.persistentContainer.viewContext
    
    func getCompletedTrackers() throws -> [TrackerRecord] {
        var trackerRecord: [TrackerRecord] = []
        let request = NSFetchRequest<TrackerCoreData>(entityName: Constants.trackerCoreData)
        do {
            let trackersCoreData = try context.fetch(request)
            
            for trackerCoreData in trackersCoreData {
                
                let id = trackerCoreData.id
                let records = trackerCoreData.record?.allObjects as? [TrackerRecordCoreData]
                if let records {
                    for record in records {
                        record.willAccessValue(forKey: "data")
                        if let date = record.date,
                           let id {
                            trackerRecord.append(TrackerRecord(id: id, date: date))
                        }
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
                let trackerRecordCoreData = TrackerRecordCoreData(context: context)
                trackerRecordCoreData.date = date
                
                trackerRecordCoreData.tracker = tracker
                tracker.addToRecord(trackerRecordCoreData)
                try context.save()
            }
        } catch {
            print("Error addNewTrackerRecord: \(error)")
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
            print("Error deleteTrackerRecord: \(error)")
        }
    }
    
    func deleteTrackerRecord(_ trackerId: UUID) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as NSUUID)
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                    context.delete(record)
                    try context.save()
            }
        } catch {
            print("Error deleteTrackerRecord: \(error)")
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
