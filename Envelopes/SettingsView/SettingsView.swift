//
//  MainMenuView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 08/07/2021.
//

import SwiftUI
import UIKit
import MessageUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    
    var body: some View {
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
                            .onChange(of: viewModel.notificationsEnabled, perform: { value in
                                viewModel.activeChallenge?.isReminderSet = viewModel.notificationsEnabled
                                viewModel.updateChallengeInContainer()
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
                            viewModel.setActiveChallenge(atIndex: index)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        viewModel.deleteChallengesAt(indexSet: indexSet)
                    })
                }
                Section(header: Text("About the developer")) {
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .font(.system(size: 20, weight: .thin))
                        NavigationLink("About the Developer", destination: AboutDevView(), isActive: $viewModel.navigateToCreateView)
                        EmptyView()
                    }
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
                    }
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .font(.system(size: 20, weight: .thin))
                        Text("Tip Jar")
                    }

                }
            }
            .navigationTitle("Settings")
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    

}
// https://stackoverflow.com/questions/56784722/swiftui-send-email
//struct MailView: UIViewControllerRepresentable {
//    typealias UIViewControllerType = <#type#>
//
//
//    @Binding var isShowing: Bool
//    @Binding var result: Result<MFMailComposeResult, Error>?
//
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//
//        @Binding var isShowing: Bool
//        @Binding var result: Result<MFMailComposeResult, Error>?
//
//        init(isShowing: Binding<Bool>,
//             result: Binding<Result<MFMailComposeResult, Error>?>) {
//            _isShowing = isShowing
//            _result = result
//        }
//
//        func mailComposeController(_ controller: MFMailComposeViewController,
//                                   didFinishWith result: MFMailComposeResult,
//                                   error: Error?) {
//            defer {
//                isShowing = false
//            }
//            guard error == nil else {
//                self.result = .failure(error!)
//                return
//            }
//            self.result = .success(result)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(isShowing: $isShowing,
//                           result: $result)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
//        let vc = MFMailComposeViewController()
//        vc.mailComposeDelegate = context.coordinator
//        return vc
//    }
//
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
//                                context: UIViewControllerRepresentableContext<MailView>) {
//
//    }
//}
