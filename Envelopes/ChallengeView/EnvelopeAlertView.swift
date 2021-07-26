//
//  EnvelopeAlertView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 19/07/2021.
//

import SwiftUI

struct EnvelopeAlertView: View {
    @State var alertType: AlertType
    let appColor: Color
    var alertMessage: String {
        switch alertType {
        case .envelopeAlreadyOpened (let envSum):
            return "This one has been opened\n\nThere was $\(envSum)"
        case .envelopeUnavailable:
            return "Be patient!\n\nThe time will come for this one"
        case .shouldOpenEnvelope (let envSum):
            return "Let's save\n$\(envSum)" + "!\n\nAre you ready?"
        case .envelopeResult (let envSum):
            return "Great!\n\nYou've saved $\(envSum)"
        }
    }
     
    var cancelAction: () -> Void?
    var successAction: () -> Void?
    
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
                case .shouldOpenEnvelope(let envSum):
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
                            alertType = .envelopeResult(envSum)
                            
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
                default: EmptyView()
                }
            }
        }
    }
}
