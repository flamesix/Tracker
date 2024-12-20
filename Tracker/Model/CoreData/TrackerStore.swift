import CoreData

final class TrackerStore {
    private let context = Store.shared.persistentContainer.viewContext
    
    func addNewTracker(_ tracker: Tracker, _ category: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category)
        do {
            let categories = try context.fetch(fetchRequest)
            if let category = categories.first {
                let trackerCoreData = TrackerCoreData(context: context)
                trackerCoreData.id = tracker.id
                trackerCoreData.title = tracker.title
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.color = tracker.color
                trackerCoreData.isPinned = tracker.isPinned
                let jsonSchedule = try? JSONEncoder().encode(tracker.schedule)
                trackerCoreData.schedule = jsonSchedule
                
                trackerCoreData.category = category
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
            let trackersCoreData = try context.fetch(fetchRequestTracker)
            let categories = try context.fetch(fetchRequestCategory)
            if let trackerCoreData = trackersCoreData.first,
               let category = categories.first {
                
                trackerCoreData.title = tracker.title
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.color = tracker.color
                let jsonSchedule = try? JSONEncoder().encode(tracker.schedule)
                trackerCoreData.schedule = jsonSchedule
                trackerCoreData.isPinned = tracker.isPinned
                
                trackerCoreData.category = category
                
                try context.save()
            }
        } catch {
            print("Error finding category: \(error)")
        }
    }
    
    func pinTracker(_ tracker: Tracker) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as NSUUID)
        
        do {
            let trackes = try context.fetch(fetchRequest)
            if let tracker = trackes.first {
                tracker.isPinned = !tracker.isPinned
                try context.save()
            }
        } catch {
            print("Error while pinning tracker: \(error)")
        }
    }
    
    func getCategoryForTracker(_ tracker: Tracker) -> String {
        var categoryTitle: String = ""
        let request = NSFetchRequest<TrackerCoreData>(entityName: Constants.trackerCoreData)
        request.predicate = NSPredicate(format: "id == %@", tracker.id as NSUUID)
        do {
            let trackers = try context.fetch(request)
            if let tracker = trackers.first {
                if let category = tracker.category {
                    if let title = category.title {
                        categoryTitle = title
                    }
                }
            }
        } catch {
            print("Error while getCategoryForTracker: \(error)")
        }
        return categoryTitle
    }
}
