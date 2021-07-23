//
//  UserSettings.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 22/07/2021.
//

import Foundation

class UserSettings {
    static let shared = UserSettings()
    
    enum Keys: String {
        case remindersEnabled = "kRemindersEnabled"
        case wasLaunchedBefore = "kWasLaunchedBefore"
    }
    
    private var userDefaults: UserDefaults
    
    var remindersEnabled: Bool {
        didSet {
            userDefaults.set(remindersEnabled, forKey: Keys.remindersEnabled.rawValue)
        }
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        remindersEnabled = userDefaults.bool(forKey: Keys.remindersEnabled.rawValue)
    }
}
