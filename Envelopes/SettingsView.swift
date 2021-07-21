//
//  MainMenuView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 08/07/2021.
//

import SwiftUI
import CoreData
import UIKit
import MessageUI


class SettingsViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    
    @Published var challenges: [Challenge] = []
    var activeChallenge: Challenge? {
        challenges.first { $0.isActive }
    }
    
    @Published var currentAppColor: String
    @Published var activeIndex: Int?
    
    
    init() {
        let challenges = coreData.loadDataFromContainer(ofType: Challenge.self)
        let challenge = challenges.first { $0.isActive }
        self.challenges = challenges
        currentAppColor = challenge?.accentColor.rawValue ?? AppColor.blue.rawValue
        
        for index in challenges.indices {
            if challenges[index].isActive {
                activeIndex =  index
            }
        }
    }
    
    
    func saveCurrentColor(accentColor: AppColor) {
        guard let challenge = activeChallenge else { return }
        challenge.colorString = accentColor.rawValue
        currentAppColor = accentColor.rawValue
        updateChallengeInContainer()
    }
    
    func updateChallengeInContainer() {
        coreData.saveContext()
    }
    
    func deleteChallengesAt(indexSet: IndexSet) {
        for index in indexSet {
            let challenge = challenges.remove(at: index)
            coreData.delete(challenge)
        }
        
    }
}


struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    
    @State var notificationTime: Date
    @State var notificationsEnabled: Bool
    @State var navigateToCreateView = false
    
    
    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let challenge = viewModel.activeChallenge {
                    Section(header: Text("Active challenge")) {
                        Text(challenge.goal!)
                        Group {
                            Toggle(isOn: $notificationsEnabled.animation()) {
                                Text("Allow daily notifications")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: challenge.accentColor.rawValue)))
                            .onChange(of: notificationsEnabled, perform: { value in
                                viewModel.activeChallenge?.isReminderSet = notificationsEnabled
                                viewModel.updateChallengeInContainer()
                            })
                            if notificationsEnabled {
                                HStack {
                                    Text("Notification time")
                                    DatePicker("Notification time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .onChange(of: notificationTime, perform: { value in
                                            print("notificationTime WAS SET!!!")
                                            viewModel.activeChallenge?.reminderTime = notificationTime
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
                                        .background(Color(hex: viewModel.currentAppColor))
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
                            if viewModel.activeIndex == index {
                                Text("ACTIVE")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 9, weight: .medium))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.challenges.forEach { $0.isActive = false }
                            viewModel.challenges[index].isActive = true
                            viewModel.activeIndex = index
                            
                            notificationTime = viewModel.challenges[index].reminderTime ?? SettingsView.defaultTime
                            notificationsEnabled = viewModel.challenges[index].isReminderSet
                            viewModel.updateChallengeInContainer()
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
                        NavigationLink("About the Developer", destination: AboutDevView(), isActive: $navigateToCreateView)
                        EmptyView()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigateToCreateView = true
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
        .onAppear(perform: {
            viewModel.challenges = CoreDataManager.shared.loadDataFromContainer(ofType: Challenge.self)
        })
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
