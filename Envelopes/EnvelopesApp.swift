//
//  EnvelopesApp.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 09/06/2021.
//

import SwiftUI

@main
struct EnvelopesApp: App {
    let coreData: CoreDataManager = .shared
    
    private let userDefaults: UserDefaults
    private let userSettings: UserSettings
    
    private var isFirstLaunch: Bool {
        let key = UserSettings.Keys.wasLaunchedBefore.rawValue
        let wasLaunchedBefore = userDefaults.bool(forKey: key)
        if !wasLaunchedBefore {
            userDefaults.set(true, forKey: key)
        }
        return !wasLaunchedBefore
    }
    
    var shouldPresentOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            ChallengeView(viewModel: ChallengeViewModel(shouldPresentOnboarding: shouldPresentOnboarding))
        }
    }
    
    init() {
        userDefaults = .standard
        userSettings = .shared
        
        if isFirstLaunch {
            createDefaultChallenge()
            shouldPresentOnboarding = true
            userSettings.oneEnvelopePerDay = true
        }
        configPayments()
        
        
        guard let activeChallenge = CoreDataManager.shared.activeChallenge else { return }
        NotificationManager.updateNotifications(for: activeChallenge)
    }
    
    private func createDefaultChallenge() {
        coreData.saveChallenge(goal: "100 Envelopes", days: 100, totalSum: 5050, step: 1, correction: 0, currentColor: AppColor.blue, isReminderSet: false, notificationTime: CreateChallengeViewModel.defaultTime, notificationStartDate: nil, notificationFrequency: 0)
    }
    
    private func configPayments() {
        IAPManager.shared.setupPurchases { successful in
            if successful {
                print("Can make payments")
                IAPManager.shared.getProducts()
            }
        }
    }
}
