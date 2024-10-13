import CoreData

final class TrackerStore {
    private let context = Store.shared.persistentContainer.viewContext
    
    func addNewTracker(_ tracker: Tracker, _ category: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category)
        do {
            let categories = try context.fetch(fetchRequest)
            if let category = categories.first {
                let trackerCoreDate = TrackerCoreData(context: context)
                trackerCoreDate.id = tracker.id
                trackerCoreDate.title = tracker.title
                trackerCoreDate.emoji = tracker.emoji
                trackerCoreDate.color = tracker.color
                trackerCoreDate.isPinned = tracker.isPinned
                let jsonSchedule = try? JSONEncoder().encode(tracker.schedule)
                trackerCoreDate.schedule = jsonSchedule
                
                trackerCoreDate.category = category
                try context.save()
            } else {
                print("Category not found with title: \(category)")
            }
        } catch {
            print("Error finding category: \(error)")
        }
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<TrackerCoreData> {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }
    
    func deleteTracker(_ trackerId: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as NSUUID)
        
        do {
            let tracker = try context.fetch(fetchRequest)
            if let tracker = tracker.first {
                context.delete(tracker)
                try context.save()
            }
        } catch {
            print("Error finding category: \(error)")
        }
    }
    
    func updateTracker(_ tracker: Tracker, _ category: String) {
        let fetchRequestTracker: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequestTracker.predicate = NSPredicate(format: "id == %@", tracker.id as NSUUID)
        
        let fetchRequestCategory: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequestCategory.predicate = NSPredicate(format: "title == %@", category)
        
        do {
            let trackersCoreDate = try context.fetch(fetchRequestTracker)
            let categories = try context.fetch(fetchRequestCategory)
            if let trackerCoreDate = trackersCoreDate.first,
               let category = categories.first {
                
                trackerCoreDate.title = tracker.title
                trackerCoreDate.emoji = tracker.emoji
                trackerCoreDate.color = tracker.color
                let jsonSchedule = try? JSONEncoder().encode(tracker.schedule)
                trackerCoreDate.schedule = jsonSchedule
                
                trackerCoreDate.category = category
                
                try context.save()
            }
        } catch {
            print("Error finding category: \(error)")
        }
    }
}
