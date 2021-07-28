//
//  EnvelopeAlertView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 19/07/2021.
//

import SwiftUI

enum AlertType {
    case actionAlert(message: String, cancelAction: () -> Void, successAction: () -> Void)
    case infoAlert(String)
}

struct AlertView: View {
    @State var alertType: AlertType
    let appColor: Color
    
    var alertMessage: String {
        switch alertType {
        case .actionAlert(let message, _ , _):
            return message
        case .infoAlert(let message):
            return message
        }
    }
    
    var body: some View {
        ZStack {
            appColor.opacity(0.5)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Text(alertMessage)
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                switch alertType {
                case .actionAlert(_, let cancelAction, let successAction):
                    EmptyView()
                    HStack {
                        Button {
                            cancelAction()
                        } label: {
                            Text("Later")
                                .foregroundColor(Color.white)
                                .frame(width: 100, height: 50, alignment: .center)
                                .background(appColor)
                                .cornerRadius(30)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .shadow(radius: 5, x: 2, y: 2)
                                .padding()
                        }
                        Button {
                            successAction()
//                            alertType = .infoAlert("Well done!\n\nYou are one step closer!")
                            
                        } label: {
                            Text("Let's do it!")
                                .foregroundColor(Color.white)
                                .frame(width: 100, height: 50, alignment: .center)
                                .background(appColor)
                                .cornerRadius(30)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .shadow(radius: 5, x: 2, y: 2)
                                .padding()
                        }
                    }
                case .infoAlert(_):
                    EmptyView()
                }
            }
        }
    }
}
