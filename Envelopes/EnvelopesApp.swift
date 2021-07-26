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
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    init() {
        userDefaults = .standard
        
        if isFirstLaunch {
            setInitialSettings()
        }
    }
    
    private func setInitialSettings() {
        NotificationManager.requestNotificationAuthorization()
    }
}
