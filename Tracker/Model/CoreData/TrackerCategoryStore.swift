import CoreData

final class TrackerCategoryStore {
    private let context = Store.shared.persistentContainer.viewContext
    
    func addNewCategory(_ title: String) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = title
        try context.save()
    }
    
    func getCategory() throws -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: Constants.trackerCategoryData)
        do {
            let trackerCategories = try context.fetch(request)
            trackerCategories.forEach { categories.append(TrackerCategory(title: $0.title ?? "", trackers: [])) }
        } catch {
            throw error
        }
        return categories
    }
    
    private func map(categoryCoreData: TrackerCategoryCoreData) -> ([Tracker], [Tracker]) {
        var trackers: [Tracker] = []
        var pinnedTrackers: [Tracker] = []
        categoryCoreData.tracker?.forEach { trackerCoreDataOptional in
            if let trackerCoreData = trackerCoreDataOptional as? TrackerCoreData {
                if let id = trackerCoreData.id,
                   let title = trackerCoreData.title,
                   let color = trackerCoreData.color,
                   let emoji = trackerCoreData.emoji {
                    
                    var schedule: [Int] = []
                    if let jsonSchedule = trackerCoreData.schedule as? NSData {
                        let daysOfWeek = try? JSONDecoder().decode([Int].self, from: jsonSchedule as Data)
                        schedule = daysOfWeek ?? []
                    }
                    let isPinned = trackerCoreData.isPinned
                    let tracker = Tracker(id: id, title: title, color: color, emoji: emoji, isPinned: isPinned, schedule: schedule)
                    isPinned ? pinnedTrackers.append(tracker) : trackers.append(tracker)
                }
            }
        }
        return (trackers, pinnedTrackers)
    }
    
    func getCategoriesTracker() throws -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: Constants.trackerCategoryData)
        do {
            let categoriesCoreData = try context.fetch(request)
            categoriesCoreData.forEach { categoryCoreData in
                let (trackers, pinnedTrackers) = map(categoryCoreData: categoryCoreData)
                if let title = categoryCoreData.title {
                    let category = TrackerCategory(title: title, trackers: trackers)
                    categories.append(category)
                }
                
                if !pinnedTrackers.isEmpty {
                    let pinnedCategories = TrackerCategory(title: Constants.pinned, trackers: pinnedTrackers)
                    categories.insert(pinnedCategories, at: 0)
                }
            }
        } catch {
            throw error
        }
        return categories
    }
    
    func deleteCategoriesTracker(_ category: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category as NSString)
        
        do {
            let category = try context.fetch(fetchRequest)
            if let category = category.first {
                context.delete(category)
                try context.save()
            }
        } catch {
            print("Error deleteCategoriesTracker: \(error)")
        }
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<TrackerCategoryCoreData> {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        return controller
    }
}
