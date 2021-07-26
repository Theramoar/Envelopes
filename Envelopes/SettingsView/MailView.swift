//
//  MailView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 22/07/2021.
//

import SwiftUI
import UIKit
import MessageUI

// https://stackoverflow.com/questions/56784722/swiftui-send-email
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    var appColor: AppColor

    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        var appColor: AppColor

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>,
             appColor: AppColor) {
            _isShowing = isShowing
            _result = result
            self.appColor = appColor
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result,
                           appColor: appColor)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["mkuzdev@gmail.com"])
        vc.setSubject("App feedback")
        vc.view.tintColor = UIColor(Color(hex: appColor.rawValue))
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
