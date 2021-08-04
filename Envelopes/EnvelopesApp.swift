//
//  EnvelopesApp.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 09/06/2021.
//

import SwiftUI

@main
struct EnvelopesApp: App {
    let persistenceController = PersistenceController.shared
    
    private let userDefaults: UserDefaults
    
    private var isFirstLaunch: Bool {
        let key = UserSettings.Keys.wasLaunchedBefore.rawValue
        let wasLaunchedBefore = userDefaults.bool(forKey: key)
        if !wasLaunchedBefore {
            userDefaults.set(true, forKey: key)
        }
        return !wasLaunchedBefore
    }

    var body: some Scene {
        WindowGroup {
            ChallengeView()
        }
    }
    
    init() {
        userDefaults = .standard
        
        if isFirstLaunch {
            setInitialSettings()
        }
        
        configPayments()
    }
    
    private func setInitialSettings() {
        NotificationManager.requestNotificationAuthorization()
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
