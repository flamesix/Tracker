import Foundation

enum WeekDay: String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var long: String {
        switch self {
        case .monday:
            Constants.monday
        case .tuesday:
            Constants.tuesday
        case .wednesday:
            Constants.wednesday
        case .thursday:
            Constants.thursday
        case .friday:
            Constants.friday
        case .saturday:
            Constants.saturday
        case .sunday:
            Constants.sunday
        }
    }
    
    var short: String {
        switch self {
        case .monday:
            Constants.mon
        case .tuesday:
            Constants.tue
        case .wednesday:
            Constants.wed
        case .thursday:
            Constants.thu
        case .friday:
            Constants.fri
        case .saturday:
            Constants.sat
        case .sunday:
            Constants.sun
        }
    }
    
    var sort: Int {
        switch self {
        case .monday:
            1
        case .tuesday:
            2
        case .wednesday:
            3
        case .thursday:
            4
        case .friday:
            5
        case .saturday:
            6
        case .sunday:
            7
        }
    }
}
