//
//  Tracker.swift
//  Tracker
//
//  Created by Юрий Гриневич on 27.08.2024.
//

import Foundation

struct Tracker {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: String
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}
