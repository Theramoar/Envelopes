import SwiftUI

class ChallengeViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    private let calendar: Calendar = .current
    private let userSettings: UserSettings
    private let localNotiManager: LocalNotificationManager
    
    #warning("try to make it private")
    @Published var challenge: Challenge?
    @Published var _shouldPresentOnboarding: Bool = false
    @Published var _shouldPresentWhatsNew: Bool = false
    @Published var showOpenedEnvelopes: Bool

    var currentIndex: Int = 0
    var oneEnvelopePerDay: Bool {
        userSettings.oneEnvelopePerDay
    }
    

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
    
    private var shouldPresentWhatsNew: Bool {
        set {
            guard newValue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self._shouldPresentWhatsNew = true
            }
        }
        get {
            _shouldPresentWhatsNew
        }
    }
    
    init(shouldPresentOnboarding: Bool = false, shouldPresentWhatsNew: Bool = false, localNotiManager: LocalNotificationManager = LocalNotificationManager(), userSettings: UserSettings = .shared, notificationCenter: NotificationCenter = .default) {
        challenge = coreData.activeChallenge
        self.localNotiManager = localNotiManager
        self.userSettings = userSettings
        self.showOpenedEnvelopes = userSettings.showOpenedEnvelopes
        self.shouldPresentOnboarding = shouldPresentOnboarding
        self.shouldPresentWhatsNew = shouldPresentWhatsNew
        notificationCenter.addObserver(self, selector: #selector(updateModel), name: .challengeModelWasUpdated, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateUserSettingsModel), name: .userSettingsWereUpdated, object: nil)
        
    }
    
    @objc func updateModel() {
        DispatchQueue.main.async {
            self.challenge = self.coreData.activeChallenge
        }
    }
    
    @objc func updateUserSettingsModel() {
        showOpenedEnvelopes = userSettings.showOpenedEnvelopes
    }
    
    func openEnvelope() {
        guard let challenge = challenge else { return }
        coreData.openEnvelope(for: challenge, at: currentIndex)
        localNotiManager.updateNotifications(for: challenge)
    }
    
    func shouldPresentDivider(after envelope: Envelope) -> Bool {
        guard let challenge = challenge else { return false }
        
        let envs = userSettings.showOpenedEnvelopes ? challenge.envelopesArray : challenge.envelopesArray.filter( {!$0.isOpened} )
        guard let index = envs.firstIndex(of: envelope) else { return false }
        
        return index != 0 && (envs.endIndex - 1) != index && (index + 1) % 16 == 0
    }
    
    func simpleSuccess(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(notificationType)
    }
    
    func getEnvelopeStatus(at index: Int, in envelopes: [Envelope]) -> EnvelopeStatus {
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
