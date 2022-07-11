import Foundation

class UserSettings {
    static let shared = UserSettings()
    
    enum Keys: String {
        case remindersEnabled = "kRemindersEnabled"
        case wasLaunchedBefore = "kWasLaunchedBefore"
        case oneEnvelopePerDay = "kOneEnvelopePerDay"
        case showOpenedEnvelopes = "kShowOpenedEnvelopes"
        case savedAppVersion = "kSavedAppVersion"
    }
    
    private var userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter
    
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
    var showOpenedEnvelopes: Bool {
        didSet {
            userDefaults.set(showOpenedEnvelopes, forKey: Keys.showOpenedEnvelopes.rawValue)
            notificationCenter.post(name: .userSettingsWereUpdated, object: nil)
        }
    }
    
    var savedAppVersion: String {
        didSet {
            userDefaults.set(savedAppVersion, forKey: Keys.savedAppVersion.rawValue)
        }
    }
    
    init(userDefaults: UserDefaults = .standard, notificationCenter: NotificationCenter = .default) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        remindersEnabled = userDefaults.bool(forKey: Keys.remindersEnabled.rawValue)
        oneEnvelopePerDay = userDefaults.bool(forKey: Keys.oneEnvelopePerDay.rawValue)
        showOpenedEnvelopes = userDefaults.bool(forKey: Keys.showOpenedEnvelopes.rawValue)
        savedAppVersion = userDefaults.string(forKey: Keys.savedAppVersion.rawValue) ?? ""
    }
}
