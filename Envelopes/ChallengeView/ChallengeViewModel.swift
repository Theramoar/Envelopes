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
    
    #warning("try to make it private")
    @Published var challenge: Challenge?
    

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
    
    init(shouldPresentOnboarding: Bool = false, localNotiManager: LocalNotificationManager = LocalNotificationManager()) {
        challenge = coreData.activeChallenge
        self.localNotiManager = localNotiManager
        self.shouldPresentOnboarding = shouldPresentOnboarding
        NotificationCenter.default.addObserver(self, selector: #selector(updateModel), name: .challengeModelWasUpdated, object: nil)
        
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
    
    func getEnvelopeStatus(at index: Int) -> EnvelopeStatus {
        guard let envelopes = challenge?.envelopesArray else { return .closed }
        guard !envelopes[index].isOpened else { return .opened }
        guard index != 0 else { return .active }
        guard !envelopes[index - 1].isOpened else {
            if index == envelopes.count - 1 || !envelopes[index + 1].isOpened { return.active }
            else { return .closed }
        }
        return .closed
    }
    
    func viewModelForProgressView() -> ProgressStackViewModel {
        ProgressStackViewModel(challenge: challenge!)
    }
}
