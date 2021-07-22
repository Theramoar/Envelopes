//
//  ChallengeViewModel.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 19/07/2021.
//

import SwiftUI

class ChallengeViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    @Published var challenge: Challenge?
    var currentIndex: Int = 0
    
    init() {
        challenge = coreData.activeChallenge
        NotificationCenter.default.addObserver(self, selector: #selector(updateModel), name: NSNotification.Name("ModelWasUpdated"), object: nil)
    }
    
    @objc func updateModel() {
        challenge = coreData.activeChallenge
    }
    
    func openEnvelope() {
        guard let challenge = challenge else { return }
        coreData.openEnvelope(for: challenge, at: currentIndex)
    }
    
    func simpleSuccess(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(notificationType)
    }
    
    func getColorForEnvelope(at index: Int) -> Color {
        guard let envelopes = challenge?.envelopesArray else { return .primary }
        let appColor = Color(hex: challenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
        
        guard !envelopes[index].isOpened else { return .secondary }
        guard index != 0 else { return appColor }
        guard !envelopes[index - 1].isOpened else {
            if index == envelopes.count - 1 || !envelopes[index + 1].isOpened { return appColor }
            else { return .primary }
        }
        return .primary
    }
}
