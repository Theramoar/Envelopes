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
                                    .padding(.vertical, 10)
                                },
                            
                            footer:
                                HStack {
                                    Spacer()
                                    Button("Delete challenge", action: {
                                        presentAlert(type: .actionAlert(message: "Do you want to delete this challenge?",
                                                                        cancelTitle: "Cancel",
                                                                        cancelAction: cancelAlert,
                                                                        successTitle: "Delete",
                                                                        successAction: {
                                                                            viewModel.deleteActiveChallenge()
                                                                            cancelAlert()
                                                                        }))
                                    })
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding()
                                    Spacer()
                                }
                        ) {
                            Toggle(isOn: $viewModel.oneEnvelopePerDay.animation()) {
                                Text("One envelope per day")
                                    .fontWeight(.medium)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: colorThemeViewModel.accentColor(for: colorScheme)))
                            NavigationLink(destination: TimePickerNavigationView(viewModel: viewModel.viewModelForTimePicker())) {
                                Text("Reminders")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            NavigationLink(destination: AppearanceView(viewModel: viewModel.viewModelForAppearanceView())) {
                                Text("Appearance")
                                    .font(.system(size: 15, weight: .medium))
                            }
                        }
                        .themedList()
                    }
                    
                    Section(header: Text("Your challenges"), footer:
                                NavigationLink(
                                    destination: CreateChallengeView(viewModel: CreateChallengeViewModel()).environmentObject(ColorThemeViewModel(type: .newChallenge))) {
                                    HStack {
                                        Spacer()
                                        Text("Create new challenge")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color.blue)
                                            .padding()
                                        Spacer()
                                    }
                                }
                            
                    ) {
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
                    }
                    .themedList()
                    Section(header: Text("Other")) {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .font(.system(size: 20, weight: .thin))
                            NavigationLink(
                                destination: UpgradeAppView(),
                                isActive: $viewModel.navigateToUpgrateAppView,
                                label: {
                                    Text("Upgrade App")
                                        .fontWeight(.medium)
                                })
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigateToUpgrateAppView = true
                        }
                        
                        HStack {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .font(.system(size: 20, weight: .thin))
                            NavigationLink(
                                destination: AboutDevView(),
                                isActive: $viewModel.navigateToCreateView,
                                label: {
                                    Text("About the Developer")
                                        .fontWeight(.medium)
                                })
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigateToCreateView = true
                        }
                        
                        HStack {
                            Image(systemName: "paperplane")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .font(.system(size: 20, weight: .thin))
                            Text("Leave your feedback")
                                .fontWeight(.medium)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigateToMailView = true
                        }
                        

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
