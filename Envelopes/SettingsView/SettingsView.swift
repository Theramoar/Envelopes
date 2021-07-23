//
//  MainMenuView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 08/07/2021.
//

import SwiftUI


struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    if let challenge = viewModel.activeChallenge {
                        Section(header: Text("Active challenge")) {
                            Text(challenge.goal!)
                            Group {
                                Toggle(isOn: $viewModel.notificationsEnabled.animation()) {
                                    Text("Allow daily notifications")
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: challenge.accentColor.rawValue)))
                                .onChange(of: viewModel.notificationsEnabled, perform: { enabled in
                                    if enabled {
                                        if UserSettings.shared.remindersEnabled {
                                            viewModel.activeChallenge?.isReminderSet = viewModel.notificationsEnabled
                                            viewModel.updateChallengeInContainer()
                                        } else {
                                            NotificationManager.requestNotificationAuthorization { success in
                                                //Wait for 0.5 seconds to finish the animation
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    viewModel.notificationsEnabled = success
                                                }
                                            }
                                        }
                                    }
                                })
                                if viewModel.notificationsEnabled {
                                    HStack {
                                        Text("Notification time")
                                        DatePicker("Notification time", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(GraphicalDatePickerStyle())
                                            .onChange(of: viewModel.notificationTime, perform: { value in
                                                print("notificationTime WAS SET!!!")
                                                viewModel.activeChallenge?.reminderTime = viewModel.notificationTime
                                                viewModel.updateChallengeInContainer()
                                                NotificationManager.setDailyNotificationTime(for: viewModel.notificationTime)
                                            })
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Accent Color:")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(AppColorWrapper.appColors, id: \.self) { color in
                                            AppColorView(accentColor: color,
                                                         currentColor: challenge.accentColor == color,
                                                         tapAction: viewModel.saveCurrentColor)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Section(header: Text("Your challenges"), footer:
                                NavigationLink(
                                    destination: CreateChallengeView(viewModel: CreateChallengeViewModel())) {
                                    HStack {
                                        Spacer()
                                        Text("Create new challenge")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color.white)
                                            .frame(width: 300, height: 45, alignment: .center)
                                            .background(Color(hex: viewModel.activeChallenge?.accentColor.rawValue ?? AppColor.blue.rawValue))
                                            .cornerRadius(15)
                                            .padding()
                                        Spacer()
                                    }
                                }
                            
                    ) {
                        ForEach(viewModel.challenges.indices, id: \.self) { index in
                            HStack {
                                Text(viewModel.challenges[index].goal!)
                                Spacer()
                                if viewModel.challenges[index].isActive {
                                    Text("ACTIVE")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 9, weight: .medium))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                #warning("Create Generic for Alert reuse")
//                                presentAlert(type: .envelopeUnavailable)
                                viewModel.setActiveChallenge(atIndex: index)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            viewModel.deleteChallengesAt(indexSet: indexSet)
                        })
                    }
                    Section(header: Text("About the developer")) {
                        HStack {
                            Image(systemName: "paperplane")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .font(.system(size: 20, weight: .thin))
                            Text("Leave your feedback")
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigateToMailView = true
                        }
                        HStack {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .font(.system(size: 20, weight: .thin))
                            NavigationLink("About the Developer", destination: AboutDevView(), isActive: $viewModel.navigateToCreateView)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigateToCreateView = true
                        }
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .font(.system(size: 20, weight: .thin))
                            NavigationLink("Tip Jar", destination: TipJarView(), isActive: $viewModel.navigateToTipJarView)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigateToTipJarView = true
                        }
                    }
                }
                .navigationTitle("Settings")
                .onTapGesture {
                    hideKeyboard()
                }
                .sheet(isPresented: $viewModel.navigateToMailView, content: {
                    MailView(isShowing: $viewModel.navigateToMailView, result: $viewModel.mailResult, appColor: viewModel.activeChallenge?.accentColor ?? AppColor.blue)
                })
            }
            .blur(radius: viewModel.alertPresented ? 10 : 0)
            .accentColor(Color(hex: viewModel.activeChallenge?.accentColor.rawValue ?? AppColor.blue.rawValue))
            if viewModel.alertPresented {
                let color = Color(hex: viewModel.activeChallenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
                EnvelopeAlertView(alertType: viewModel.currentAlertType, appColor: color, cancelAction: cancelAlert, successAction: {})
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
