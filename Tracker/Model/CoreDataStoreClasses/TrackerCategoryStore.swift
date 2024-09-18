//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Юрий Гриневич on 16.09.2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore {
    private let context = Store.shared.context
    
    func addNewCategory(_ title: String) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = title
        try context.save()
    }
    
    func getCategory() throws -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: Constants.trackerCategoryData)
        do {
            let authors = try context.fetch(request)
            authors.forEach { categories.append(TrackerCategory(title: $0.title!, trackers: [])) }
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
