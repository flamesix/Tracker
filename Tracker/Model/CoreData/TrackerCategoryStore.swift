//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Юрий Гриневич on 16.09.2024.
//

import Foundation
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
    
    private func map(categoryCoreData: TrackerCategoryCoreData) -> [Tracker] {
        var trackers: [Tracker] = []
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
                    
                    let tracker = Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
                    trackers.append(tracker)
                }
            }
        }
        return trackers
    }
    
    func getCategoriesTracker() throws -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: Constants.trackerCategoryData)
        do {
            let categoriesCoreData = try context.fetch(request)
            categoriesCoreData.forEach { categoryCoreData in
                let trackers = map(categoryCoreData: categoryCoreData)
                if let title = categoryCoreData.title {
                    let category = TrackerCategory(title: title, trackers: trackers)
                    categories.append(category)
                }
            }
        } catch {
            throw error
        }
        return categories
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
