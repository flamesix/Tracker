import Foundation

final class FilterStateStorage {
    static let shared = FilterStateStorage()
    
    private let userDefaults = UserDefaults.standard
    
    var filter: Filters? {
        get {
            if let filterDescription = userDefaults.string(forKey: "filter") {
                return Filters(rawValue: filterDescription)
            }
            return nil
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: "filter")
        }
    }
    
    private init() {}
}
