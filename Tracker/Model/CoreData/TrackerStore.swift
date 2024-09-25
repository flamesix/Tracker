//
//  TrackerStore.swift
//  Tracker
//
//  Created by Юрий Гриневич on 16.09.2024.
//

import Foundation
import CoreData

final class TrackerStore {
    private let context = Store.shared.context
    
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
}
