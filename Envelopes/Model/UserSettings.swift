import Foundation

class UserSettings {
    static let shared = UserSettings()
    
    enum Keys: String {
        case remindersEnabled = "kRemindersEnabled"
        case wasLaunchedBefore = "kWasLaunchedBefore"
        case oneEnvelopePerDay = "kOneEnvelopePerDay"
    }
    
    private var userDefaults: UserDefaults
    
    var remindersEnabled: Bool {
        didSet {
            userDefaults.set(remindersEnabled, forKey: Keys.remindersEnabled.rawValue)
        }
    }
    
    var oneEnvelopePerDay: Bool {
        didSet {
            userDefaults.set(oneEnvelopePerDay, forKey: Keys.oneEnvelopePerDay.rawValue)
        }
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        remindersEnabled = userDefaults.bool(forKey: Keys.remindersEnabled.rawValue)
        oneEnvelopePerDay = userDefaults.bool(forKey: Keys.oneEnvelopePerDay.rawValue)
    }
}
