import SwiftUI

class EnvelopesAppViewModel: ObservableObject {
    private let userSettings: UserSettings
    private let userDefaults: UserDefaults
    private let coreData: CoreDataManager
    private let localNotiManager: LocalNotificationManager
    
    var shouldPresentWhatsNew: Bool = false
    var shouldPresentOnboarding: Bool = false
    
    private var isFirstLaunch: Bool {
        let key = UserSettings.Keys.wasLaunchedBefore.rawValue
        let wasLaunchedBefore = userDefaults.bool(forKey: key)
        if !wasLaunchedBefore {
            userDefaults.set(true, forKey: key)
        }
        return !wasLaunchedBefore
    }
    
    init() {
        userSettings = .shared
        userDefaults = .standard
        coreData = .shared
        localNotiManager = LocalNotificationManager()
        
        if isFirstLaunch {
            createDefaultChallenge()
            shouldPresentOnboarding = true
            userSettings.oneEnvelopePerDay = true
            userSettings.showOpenedEnvelopes = true
        } else {
            checkForUpdate()
        }
        
        configPayments()
        guard let activeChallenge = CoreDataManager.shared.activeChallenge else { return }
        
        localNotiManager.updateNotifications(for: activeChallenge)
    }
    
    private func createDefaultChallenge() {
        coreData.saveChallenge(goal: "100 Envelopes", days: 100, totalSum: 5050, step: 1, correction: 0, isReminderSet: false, notificationTime: CreateChallengeViewModel.defaultTime, notificationStartDate: nil, notificationFrequency: 0)
    }
    
    private func checkForUpdate() {
        let currentVersion = getCurrentAppVersion()
        let savedVersion = userSettings.savedAppVersion

        if savedVersion == currentVersion {
            print("App is up to date!")
        } else {
            self.shouldPresentWhatsNew = true
            userSettings.savedAppVersion = currentVersion
        }
    }
    
    private func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        return version
    }
    
    private func configPayments() {
        IAPManager.shared.setupPurchases { successful in
            if successful {
                print("Can make payments")
                IAPManager.shared.getProducts()
            }
        }
    }
    
    func viewModelForChallengeView() -> ChallengeViewModel {
        ChallengeViewModel(shouldPresentOnboarding: shouldPresentOnboarding,
                           shouldPresentWhatsNew: shouldPresentWhatsNew)
    }
}
