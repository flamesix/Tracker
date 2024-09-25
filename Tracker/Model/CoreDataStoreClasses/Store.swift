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
    private let appDelegate = AppDelegate()
    
    private init() {
        self.context = appDelegate.persistentContainer.viewContext
    }
}
