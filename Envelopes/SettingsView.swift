//
//  MainMenuView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 08/07/2021.
//

import SwiftUI

import UIKit
import MessageUI

class MenuViewModel: ObservableObject {
    
}

extension Color {
    init(hex: String) {
        let a, r, g, b: UInt64
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()

        Scanner(string: hexString).scanHexInt64(&int)

        switch hexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppColorWrapper: Identifiable {
    var id = UUID()
    static let appColors: [AppColor] = AppColor.allCases
}

enum AppColor: String, CaseIterable {
    case blue = "007AFF"
    case red = "FF3B30"
    case yellow = "FFCC00"
    case green = "34C759"
    case purple = "AF52DE"
    case orange = "FF9500"
    case pink = "FF2D55"
}

struct AppColorView: View {
    let accentColor: AppColor
    let currentColor: Bool
    
    var tapAction: (AppColor) -> Void
    
    var body: some View {
        ZStack {
            Color(hex: accentColor.rawValue)
                .cornerRadius(30)
                .frame(width: 40, height: 40, alignment: .center)
            if currentColor {
                Image(systemName: "checkmark")
            }
        }
        .onTapGesture {
            tapAction(accentColor)
        }
    }
}

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Challenge.entity(), sortDescriptors: []) var challenges: FetchedResults<Challenge>
    
    
    @ObservedObject var viewModel: MenuViewModel
    
    func saveCurrentColor(accentColor: AppColor) {
        guard let challenge = challenges.first(where: { $0.isActive }) else { return }
        challenge.colorString = accentColor.rawValue
        try? self.moc.save()
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let challenge = challenges.first { $0.isActive } {
                    Section(header: Text("Active challenge")) {
                        Text(challenge.goal!)
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
                Section(header: Text("Your challenges")) {
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
                            print(challenges[index].isActive)
                            try? self.moc.save()
                        }
                    }
                    
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            moc.delete(challenges[index])
                        }
                        try? self.moc.save()
                    })
                    ZStack {
                        Text("Create new challenge")
                            .foregroundColor(.blue)
                        NavigationLink(
                            destination: CreateChallengeView(viewModel: CreateChallengeViewModel())) { EmptyView() }
                    }
                }
                Section(header: Text("About the developer")) {
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .font(.system(size: 20, weight: .thin))
                        NavigationLink("Let me introduce myself", destination: AboutDevView())
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
