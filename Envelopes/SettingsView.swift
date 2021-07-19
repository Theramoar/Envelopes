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
    
}


struct SettingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Challenge.entity(), sortDescriptors: []) var challenges: FetchedResults<Challenge>
    
    @StateObject var viewModel = SettingsViewModel()
    
    var activeChallenge: Challenge? {
        challenges.first { $0.isActive }
    }
    
    func saveCurrentColor(accentColor: AppColor) {
        guard let challenge = challenges.first(where: { $0.isActive }) else { return }
        challenge.colorString = accentColor.rawValue
        try? moc.save()
    }
    
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
                if let challenge = activeChallenge {
                    Section(header: Text("Active challenge")) {
                        Text(challenge.goal!)
                        Group {
                            Toggle(isOn: $notificationsEnabled.animation()) {
                                Text("Allow daily notifications")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: challenge.accentColor.rawValue)))
                            .onChange(of: notificationsEnabled, perform: { value in
                                activeChallenge?.isReminderSet = notificationsEnabled
                                try? moc.save()
                            })
                            if notificationsEnabled {
                                HStack {
                                    Text("Notification time")
                                    DatePicker("Notification time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .onChange(of: notificationTime, perform: { value in
                                            print("notificationTime WAS SET!!!")
                                            activeChallenge?.reminderTime = notificationTime
                                            try? moc.save()
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
                                                     tapAction: saveCurrentColor)
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
                                        .background(Color(hex: activeChallenge?.accentColor.rawValue ?? AppColor.blue.rawValue))
                                        .cornerRadius(15)
                                        .padding()
                                    Spacer()
                                }
                            }
                        
                        ) {
                    ForEach(challenges.indices, id: \.self) { index in
                        HStack {
                            Text(challenges[index].goal!)
                            Spacer()
                            if challenges[index].isActive {
                                Text("ACTIVE")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 9, weight: .medium))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            challenges.forEach { $0.isActive = false }
                            challenges[index].isActive = true
                            notificationTime = challenges[index].reminderTime ?? SettingsView.defaultTime
                            notificationsEnabled = challenges[index].isReminderSet
                            try? self.moc.save()
                        }
                    }
                    
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            moc.delete(challenges[index])
                        }
                        try? self.moc.save()
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
