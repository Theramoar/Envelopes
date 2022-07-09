import SwiftUI

struct WhatsNewView: View {
    @Environment(\.presentationMode) var presentationMode
    
    private let buttonTitles = ["What else?", "Got it"]
    private let slideInfos = [
        PresentationSlideInfo(imageName: "whats_new_1.07_1", title: "Hide opened envelopes", descriptions: ["- Got tired of the huge list of opened envelopes?","- Use the new switch to hide them"]),
        PresentationSlideInfo(imageName: "whats_new_1.07_2", title: "Rate the app", descriptions: ["- Did you like the app?","- Use the new button to rate it in the App Store"])
    ]
   

    var body: some View {
        NavigationView {
            PresentationView(slideInfos: slideInfos,
                             buttonTitles: buttonTitles,
                             finishAction: dismissOnboarding)
            .navigationTitle("What's new?")
        }
        
    }
    
    func dismissOnboarding() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
