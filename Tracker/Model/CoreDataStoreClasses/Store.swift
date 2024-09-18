//
//  Store.swift
//  Tracker
//
//  Created by Юрий Гриневич on 17.09.2024.
//

import UIKit
import CoreData

final class Store {
    
    static let shared = Store()
    let context: NSManagedObjectContext
    
    private convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getCategoriesTracker() throws -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: Constants.trackerCategoryData)
        do {
            let categoriesCoreData = try context.fetch(request)
            categoriesCoreData.forEach { categoryCoreData in
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
}
