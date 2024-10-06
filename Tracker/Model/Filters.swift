import Foundation

enum Filters: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case doneTrackers = "Завершенные"
    case activeTrackers = "Не завершенные"
}
