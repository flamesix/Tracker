import Foundation

final class StatisticStorage {
    static let shared = StatisticStorage()
    
    private let userDefaults = UserDefaults.standard
    
    var completedCount: Int {
        get {
            userDefaults.integer(forKey: "completedCount")
        }
        set {
            userDefaults.set(newValue, forKey: "completedCount")
        }
    }
    
    private init() { }
}
