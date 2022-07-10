import SwiftUI
import CoreData

struct ChallengeView: View {
    @StateObject var viewModel: ChallengeViewModel
    @EnvironmentObject var themeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
   
    @State private var alertPresented = false
    @State private var alertMessage = ""
    @State var currentAlertType: AlertType!
    
    @State private var presentMenuView = false
    @State private var presentCreateChallengeView = false
    @State private var presentAnalyticsView = false
    
    let gridEdgePadding: CGFloat = 10
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            themeViewModel.backgroundColor(for: colorScheme)
                .ignoresSafeArea(.all)
            if let challenge = viewModel.challenge {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    HStack {
                        Text(challenge.goal!)
                            .padding()
                            .font(.system(size: 34, weight: .bold))
                        Spacer()
                        SettingsButton(tapAction: { presentMenuView = true }, backgroundColor: themeViewModel.accentColor(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    
                    ProgressStackView(viewModel: viewModel.viewModelForProgressView())
                        .background(themeViewModel.foregroundColor(for: colorScheme))
                        .cornerRadius(15)
                        .padding(gridEdgePadding)
//                        .onTapGesture {
//                            presentAnalyticsView = true
//                        }
                    
                    
                    LazyVGrid(columns: columns, spacing: nil) {
                        ForEach(challenge.envelopesArray.indices, id: \.self) { index in
                            let envelope = challenge.envelopesArray[index]
                            
                            if viewModel.showOpenedEnvelopes ||
                            !viewModel.showOpenedEnvelopes && !envelope.isOpened {
                                EnvelopeView(envelope: envelope,
                                             envelopeStatus: viewModel.getEnvelopeStatus(at: index, in: challenge.envelopesArray),
                                             dayText: "Day \(index + 1)",
                                             processEnvelope: processEnvelope)
                                
                                if viewModel.shouldPresentDivider(after: envelope) {
                                    Section(footer: Divider()) {}
                                }
                            }
                        }
                        .padding(10)
                    }
                    .background(themeViewModel.foregroundColor(for: colorScheme))
                    .cornerRadius(15)
                    .padding(gridEdgePadding)
                }
                .padding(gridEdgePadding)
                .edgesIgnoringSafeArea(.bottom)
                .blur(radius: alertPresented ? 10 : 0)
                
                
            } else {
                NoChallengesView(tapAction: { presentCreateChallengeView = true } )
                
                VStack {
                    HStack {
                        Spacer()
                        SettingsButton(tapAction: { presentMenuView = true }, backgroundColor: themeViewModel.accentColor(for: colorScheme))
                    }
                    Spacer()
                }
            }
            if alertPresented {
                AlertView(alertType: currentAlertType, appColor: themeViewModel.accentColor(for: colorScheme))
                    .onTapGesture(perform: cancelAlert)
            }
            
        }
        .sheet(isPresented: $presentMenuView) { SettingsView() }
        .sheet(isPresented: $presentCreateChallengeView) { CreateChallengeView(viewModel: CreateChallengeViewModel())
            .environmentObject(ColorThemeViewModel(type: .newChallenge)) }
        .sheet(isPresented: $viewModel._shouldPresentOnboarding) { OnboardingView() }
        .sheet(isPresented: $viewModel._shouldPresentWhatsNew) { WhatsNewView() }
        .sheet(isPresented: $presentAnalyticsView) { AnalyticsView() }
    }
    
    func cancelAlert() {
        withAnimation{
            alertPresented = false
        }
    }
    
    func presentAlert(type: AlertType) {
        currentAlertType = type        
        withAnimation {
            alertPresented = true
        }
    }
    
    func processEnvelope(_ envelope: Envelope) {
        guard let challenge = viewModel.challenge else { return }
        guard let index = challenge.envelopesArray.firstIndex(of: envelope) else { return }

        let rounded = envelope.sum.roundedUpTwoDecimals()
        
        guard !envelope.isOpened else {
            viewModel.simpleSuccess(.warning)
            let message = "This one has been opened\n\nThere was $\(rounded)"
            presentAlert(type: .infoAlert(message))
            return
        }
        
        guard index == 0 || challenge.envelopesArray[index - 1].isOpened else {
            viewModel.simpleSuccess(.warning)
            let message = "Be patient!\n\nThe time will come for this one"
            presentAlert(type: .infoAlert(message))
            return
        }
        
        if viewModel.oneEnvelopePerDay,
           let envOpenedDate = challenge.lastOpenedDate,
           Calendar.current.isDateInToday(envOpenedDate) {
            viewModel.simpleSuccess(.warning)
            let message = "Only one envelope per day!\n\nPlease, return tomorrow"
            presentAlert(type: .infoAlert(message))
            return
        }
        
        viewModel.currentIndex = index
        viewModel.simpleSuccess(.success)
        let message = "Let's save\n$\(rounded)" + "\n\nAre you ready?"
        presentAlert(type: .actionAlert(message: message,
                                        cancelTitle: "Later",
                                        cancelAction: cancelAlert,
                                        successTitle: "Let's do it!",
                                        successAction: {
                                            viewModel.openEnvelope()
                                            cancelAlert()
                                            presentResultAlert()
        }))
    }
    
    func presentResultAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            presentAlert(type: .infoAlert("Well done!\n\nYou are one step closer!"))
        }
    }
}
