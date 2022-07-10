import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var keyboardAppeared = false
    
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    
                    if !UserPurchases.shared.allInEnabled {
                        Section {
                            NavigationLink(
                                destination: UpgradeAppView(),
                                isActive: $viewModel.navigateToUpgrateAppView,
                                label: {
                                    IconCellView(imageName: "plus.app", text: "Upgrade App")
                                })
                            
                        }
                        .themedList()
                    }
                    
                    if let challenge = viewModel.activeChallenge {
                        Section(
                            header:
                                VStack(alignment: .leading) {
                                    Text("Active challenge")
                                    HStack {
                                        Text(challenge.goal!.uppercased())
                                            .font(.system(size: 15, weight: .bold))
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            let totalSum = "$" + String(challenge.totalSum.roundedUpTwoDecimals())
                                            Text(totalSum)
                                                .font(.system(size: 15, weight: .medium))
                                            Text(" for \(challenge.days) days")
                                                .font(.system(size: 10, weight: .medium))
                                        }
                                    }
                                }
                        ) {
                            Toggle(isOn: $viewModel.oneEnvelopePerDay.animation()) {
                                IconCellView(imageName: "envelope", text: "One envelope per day")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: colorThemeViewModel.accentColor(for: colorScheme)))
                            
                            Toggle(isOn: $viewModel.showOpenedEnvelopes.animation()) {
                                IconCellView(imageName: "envelope.open", text: "Show opened envelopes")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: colorThemeViewModel.accentColor(for: colorScheme)))
                            
                            NavigationLink(destination: TimePickerNavigationView(viewModel: viewModel.viewModelForTimePicker())) {
                                IconCellView(imageName: "clock", text: "Reminders")
                            }
                            NavigationLink(destination: AppearanceView(viewModel: viewModel.viewModelForAppearanceView())) {
                                IconCellView(imageName: "paintbrush", text: "Appearance")
                            }
                            Button(action: {
                                presentAlert(type:
                                        .actionAlert(message: "Do you want to delete this challenge?",
                                                     cancelTitle: "Cancel",
                                                     cancelAction: cancelAlert,
                                                     successTitle: "Delete",
                                                     successAction: {
                                    viewModel.deleteActiveChallenge()
                                    cancelAlert()
                                }))
                            }) {
                                IconCellView(imageName: "trash", text: "Delete Challenge")
                                    .foregroundColor(.red)
                            }
                        }
                        .themedList()
                    }
                    
                    Section(header: Text("Your challenges")) {
                        ForEach(viewModel.challenges.indices, id: \.self) { index in
                            HStack {
                                Text(viewModel.challenges[index].goal!)
                                    .fontWeight(.medium)
                                Spacer()
                                if viewModel.challenges[index].isActive {
                                    Text("ACTIVE")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 9, weight: .medium))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard viewModel.activeChallenge != viewModel.challenges[index] else { return }
                                presentAlert(type: .actionAlert(message: "Set this challenge as active?",
                                                                cancelTitle: "Cancel",
                                                                cancelAction: cancelAlert,
                                                                successTitle: "Set active",
                                                                successAction: {
                                    viewModel.setActiveChallenge(atIndex: index)
                                    cancelAlert()
                                }))
                            }
                        }
                        NavigationLink(destination: CreateChallengeView(viewModel: CreateChallengeViewModel()).environmentObject(ColorThemeViewModel(type: .newChallenge))) {
                            IconCellView(imageName: "square.and.pencil", text: "Create new challenge")
                                .foregroundColor(colorThemeViewModel.accentColor(for: colorScheme))
                        }
                    }
                    .themedList()
                    Section(header: Text("Other")) {
                        
                        NavigationLink(
                            destination: AboutDevView(),
                            isActive: $viewModel.navigateToCreateView,
                            label: {
                                IconCellView(imageName: "person", text: "About the developer")
                            })
                        
                        
                        NavigationLink(
                            destination: TipJarView(),
                            isActive: $viewModel.navigateToTipJarView,
                            label: {
                                IconCellView(imageName: "dollarsign.circle", text: "Tip Jar")
                            })
                        
                        
                        Button( action: { viewModel.navigateToMailView = true} )
                        {
                            IconCellView(imageName: "paperplane", text: "Leave your feedback")
                        }
                        .foregroundColor(.primary)
                        
                        Link(destination: viewModel.reviewUrl) {
                            IconCellView(imageName: "star", text: "Rate this app")
                        }
                        .foregroundColor(.primary)
                    }
                    .themedList()
                }
                .themedScreenBackground()
                .navigationTitle("Settings")
                .sheet(isPresented: $viewModel.navigateToMailView, content: {
                    MailView(isShowing: $viewModel.navigateToMailView, result: $viewModel.mailResult)
                })
            }
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = UIColor(colorThemeViewModel.backgroundColor(for: colorScheme))
                UINavigationBar.appearance().standardAppearance = appearance
            }
            .blur(radius: viewModel.alertPresented ? 10 : 0)
            .accentColor(colorThemeViewModel.accentColor(for: colorScheme))
            if viewModel.alertPresented {
                AlertView(alertType: viewModel.currentAlertType, appColor: colorThemeViewModel.accentColor(for: colorScheme))
                    .onTapGesture(perform: cancelAlert)
            }
        }
    }
    
    func cancelAlert() {
        withAnimation{
            viewModel.alertPresented = false
        }
    }
    
    func presentAlert(type: AlertType) {
        viewModel.currentAlertType = type
        withAnimation {
            viewModel.alertPresented = true
        }
    }
}

struct IconCellView: View {
    let imageName: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
            Text(text)
                .fontWeight(.medium)
            
        }
    }
}
