import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    private let localNotiManager = LocalNotificationManager()
    private let buttonTitles = ["What are the rules?", "What else?", "Let's go!"]
    private let slideInfos = [
        PresentationSlideInfo(imageName: "onboarding_envelope_1", title: "Hey there!", descriptions: ["Would you like to save extra $5,050?", "We dare you to take the viral Envelopes Challenge!"]),
        PresentationSlideInfo(imageName: "onboarding_envelope_2", title: "Rules:", descriptions: ["1. You have 100 envelopes with random number from $1 to $100.", "2. Open 1 envelope per day and save the written amount of money.", "3. By the time you open the last envelope you’ll save $5050!"]),
        PresentationSlideInfo(imageName: "onboarding_envelope_3", title: "Customize!", descriptions: ["Do you feel that this challenge is not for you? Make your own then!", "Set up the sum of money and amount of envelopes, that suites you!"])
    ]
   

    var body: some View {
        PresentationView(slideInfos: slideInfos,
                         buttonTitles: buttonTitles,
                         finishAction: dismissOnboarding)
    }
    
    func dismissOnboarding() {
        localNotiManager.requestNotificationAuthorization { success in
            CoreDataManager.shared.setNotificationEnable(success)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}


