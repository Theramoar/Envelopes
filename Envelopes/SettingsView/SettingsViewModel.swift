import Foundation
import MessageUI
import SwiftUI

class SettingsViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    private let userSettings: UserSettings = .shared
    private let localNotiManager: LocalNotificationManager
    
    @Published var challenges: [Challenge] = []
    @Published var notificationsEnabled: Bool
    @Published var oneEnvelopePerDay: Bool {
        didSet {
            userSettings.oneEnvelopePerDay = oneEnvelopePerDay
        }
    }
    @Published var navigateToCreateView = false
    @Published var navigateToMailView = false
    @Published var navigateToUpgrateAppView = false
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
    
    init(localNotiManager: LocalNotificationManager = LocalNotificationManager()) {
        self.challenges = coreData.challenges
        notificationsEnabled = coreData.activeChallenge?.isReminderSet ?? false
        oneEnvelopePerDay = userSettings.oneEnvelopePerDay
        self.localNotiManager = localNotiManager
        NotificationCenter.default.addObserver(self, selector: #selector(updateModel), name: .challengeModelWasUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert), name: .purchaseWasSuccesful, object: nil)
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

            localNotiManager.setDailyNotificationTime(for: reminderTime, startDate: startDate, frequency: frequency, numberOfNotificcations: activeDaysLeft)
        } else {
            localNotiManager.clearNotificationCenter()
        }
    }
    
    @objc func presentAlert() {
        currentAlertType = .infoAlert("Thank you for your purchase!")
        withAnimation {
            alertPresented = true
        }
    }
    
    func setActiveChallenge(atIndex index: Int) {
        let newActiveChallenge = coreData.challenges[index]
        coreData.setActive(challenge: newActiveChallenge)
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
        TimePickerViewModel(activeChallenge: activeChallenge, valuesHandler: updateValues)
    }
    
    func viewModelForAppearanceView() -> AppearanceViewModel {
        AppearanceViewModel(newThemeHandler: updateTheme)
    }
    
    func updateTheme(theme: ThemeSet) {
        coreData.setActive(themeSet: theme)
    }
    
    func updateValues(_ notiEnabled: Bool, _ notiTime: Date, _ notiStartDate: Date, _ selectedFrequency: Int) {
        coreData.setNotificationData(notiTime,
                                     notiStartDate,
                                     selectedFrequency,
                                     notiEnabled)
    }
}
