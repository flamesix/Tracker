import Foundation

enum Filters: String, CaseIterable {
    case allTrackers
    case todayTrackers
    case doneTrackers
    case activeTrackers
    
    var description: String {
        switch self {
        case .allTrackers:
            return Constants.allTrackers
        case .todayTrackers:
            return Constants.todayTrackers
        case .doneTrackers:
            return Constants.doneTrackers
        case .activeTrackers:
            return Constants.activeTrackers
        }
    }
}
