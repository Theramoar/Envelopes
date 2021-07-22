//
//  SettingsViewModel.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 21/07/2021.
//

import Foundation

class SettingsViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    
    @Published var challenges: [Challenge] = []
    @Published var notificationTime: Date
    @Published var notificationsEnabled: Bool
    @Published var navigateToCreateView = false
    
    
    var activeChallenge: Challenge? {
        challenges.first { $0.isActive }
    }
    
    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    init() {
        self.challenges = coreData.challenges
        notificationTime = coreData.activeChallenge?.reminderTime ?? SettingsViewModel.defaultTime
        notificationsEnabled = coreData.activeChallenge?.isReminderSet ?? false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateModel), name: NSNotification.Name("ModelWasUpdated"), object: nil)
    }
    
    @objc func updateModel() {
        challenges = coreData.challenges
        notificationTime = activeChallenge?.reminderTime ?? SettingsViewModel.defaultTime
        notificationsEnabled = activeChallenge?.isReminderSet ?? false
    }
    
    func setActiveChallenge(atIndex index: Int) {
        coreData.setActiveChallenge(atIndex: index)
    }
    
    func saveCurrentColor(accentColor: AppColor) {
        coreData.saveCurrentColor(accentColor: accentColor)
    }
    
    func updateChallengeInContainer() {
        coreData.saveContext()
    }
    
    func deleteChallengesAt(indexSet: IndexSet) {
        for index in indexSet {
            let challenge = challenges.remove(at: index)
            coreData.delete(challenge)
        }
        
    }
}
