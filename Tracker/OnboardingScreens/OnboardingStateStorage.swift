import Foundation

final class OnboardingStateStorage {
    static let shared = OnboardingStateStorage()
    
    private let userDefaults = UserDefaults.standard
    
    var isShowed: Bool {
        get {
            userDefaults.bool(forKey: "isShowed")
        }
        set {
            userDefaults.set(newValue, forKey: "isShowed")
        }
    }
    
    private init() {}
}
