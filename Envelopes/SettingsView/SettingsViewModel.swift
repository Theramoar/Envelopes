//
//  SettingsViewModel.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 21/07/2021.
//

import Foundation
import MessageUI
import SwiftUI

class SettingsViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    
    @Published var challenges: [Challenge] = []
    @Published var notificationsEnabled: Bool
    @Published var navigateToCreateView = false
    @Published var navigateToMailView = false
    @Published var navigateToTipJarView = false
    @Published var alertPresented = false
    @Published var currentAlertType: AlertType!
    @Published var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    
    
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
        notificationsEnabled = coreData.activeChallenge?.isReminderSet ?? false
        NotificationCenter.default.addObserver(self, selector: #selector(updateModel), name: NSNotification.Name("ModelWasUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert), name: NSNotification.Name("AlertShouldBePresented"), object: nil)
    }
    
    @objc func updateModel() {
        challenges = coreData.challenges
        notificationsEnabled = activeChallenge?.isReminderSet ?? false
        if notificationsEnabled {
            guard let activeChallenge = activeChallenge else { return }

            let activeDaysLeft = activeChallenge.envelopesArray.filter({ !$0.isOpened }).count
            let reminderTime = activeChallenge.reminderTime ?? SettingsViewModel.defaultTime
            
            #warning("Add tomorrow to separate unit")
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            let startDate = activeChallenge.reminderStartDate ?? tomorrow
            let frequency = activeChallenge.frequency

            NotificationManager.setDailyNotificationTime(for: reminderTime, startDate: startDate, frequency: frequency, numberOfNotificcations: activeDaysLeft)
        } else {
            NotificationManager.clearNotificationCenter()
        }
        
        
    }
    
    @objc func presentAlert() {
        currentAlertType = .infoAlert("Thank you!\n\nYour support is very important!")
        withAnimation {
            alertPresented = true
        }
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
    
    func deleteActiveChallenge() {
        if let challenge = activeChallenge {
            coreData.delete(challenge)
            if !challenges.isEmpty {
                setActiveChallenge(atIndex: 0)
            }
        }
    }
    
    
    func viewModelForTimePicker() -> TimePickerViewModel {
        TimePickerViewModel(activeChallenge: activeChallenge)
    }
}
