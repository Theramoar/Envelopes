//
//  ChallengeViewModel.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 19/07/2021.
//

import SwiftUI

class ChallengeViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    private let calendar: Calendar = .current
    private let userSettings: UserSettings = .shared
    private let localNotiManager: LocalNotificationManager
    @Published var challenge: Challenge?
    var appTheme: AppTheme {
        challenge?.appTheme ?? defaultTheme
    }

    var currentIndex: Int = 0
    var oneEnvelopePerDay: Bool {
        userSettings.oneEnvelopePerDay
    }
    
    @Published var _shouldPresentOnboarding: Bool = false
    private var shouldPresentOnboarding: Bool {
        set {
            guard newValue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self._shouldPresentOnboarding = true
            }
        }
        get {
            _shouldPresentOnboarding
        }
    }
    
    init(shouldPresentOnboarding: Bool = false, colorScheme: ColorScheme, localNotiManager: LocalNotificationManager = LocalNotificationManager()) {
        challenge = coreData.activeChallenge
        self.localNotiManager = localNotiManager
        self.shouldPresentOnboarding = shouldPresentOnboarding
        NotificationCenter.default.addObserver(self, selector: #selector(updateModel), name: NSNotification.Name("ModelWasUpdated"), object: nil)
        
    }
    
    @objc func updateModel() {
        DispatchQueue.main.async {
            self.challenge = self.coreData.activeChallenge
        }
    }
    
    func openEnvelope() {
        guard let challenge = challenge else { return }
        coreData.openEnvelope(for: challenge, at: currentIndex)
        localNotiManager.updateNotifications(for: challenge)
    }
    
    func simpleSuccess(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(notificationType)
    }
    
    func getColorForEnvelope(at index: Int) -> Color {
        guard let envelopes = challenge?.envelopesArray else { return .primary }
        let appColor = challenge?.accentColor.color ?? AppColor.blue.color
        
        guard !envelopes[index].isOpened else { return .secondary }
        guard index != 0 else { return appColor }
        guard !envelopes[index - 1].isOpened else {
            if index == envelopes.count - 1 || !envelopes[index + 1].isOpened { return appColor }
            else { return .primary }
        }
        return .primary
    }
}
