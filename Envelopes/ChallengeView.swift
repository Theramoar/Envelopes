//
//  ContentView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 09/06/2021.
//

import SwiftUI
import CoreData

enum AlertType: Equatable {
    case envelopeAlreadyOpened(Float)
    case envelopeUnavailable
    case shouldOpenEnvelope(Float)
    case envelopeResult(Float)
}

struct ChallengeView: View {
    @ObservedObject var challenge: Challenge
    
    @State private var alertPresented = false
    @State private var alertMessage = ""
    @State var currentAlertType: AlertType!
    
    @State private var currentIndex: Int = 0
    
    let gridEdgePadding: CGFloat = 10
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    ProgressStackView(challenge: challenge)
                        .padding(gridEdgePadding)
                    
                    let side = cellSide(with: geo.size.width)
                    let spacing = gridSpacing(with: geo.size.width, cellSide: side)
                    
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(challenge.envelopes.indices, id: \.self) { index in
                            
                            let envelope = challenge.envelopes[index]
                            let rounded = envelope.sum.roundedUpTwoDecimals()
                            
                            let imageName = envelope.opened ? "envelope.open" : "envelope"
                            
                            VStack {
                                Image(systemName: imageName)
                                    .font(.system(size: 60))
                                    .foregroundColor(getColorForEnvelope(at: index))
                                Text("Day \(index + 1)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                            .onTapGesture {
                                guard !challenge.envelopes[index].opened else {
                                    simpleSuccess(.warning)
                                    presentAlert(type: .envelopeAlreadyOpened(rounded))
                                    return
                                }
                                guard index == 0 || challenge.envelopes[index - 1].opened else {
                                    simpleSuccess(.error)
                                    presentAlert(type: .envelopeUnavailable)
                                    return
                                }
                                currentIndex = index
                                simpleSuccess(.success)
                                presentAlert(type: .shouldOpenEnvelope(rounded))
                            }
                            
                        }
                        .padding(10)
                        .frame(width: side, height: side, alignment: .center)
                        
                    }
                    .padding(gridEdgePadding)
                }
                .blur(radius: alertPresented ? 10 : 0)
            }
            if alertPresented {
                EnvelopeAlertView(alertType: currentAlertType, cancelAction: cancelAlert, successAction: openEnvelope)
                    .onTapGesture(perform: cancelAlert)
            }
        }
        .navigationTitle(challenge.goal)
    }
    
    func cancelAlert() {
        withAnimation{
            alertPresented = false
        }
    }
    
    func openEnvelope() {
        addSumToTotal(sum: challenge.envelopes[currentIndex].sum)
        challenge.envelopes[currentIndex].opened = true
    }
    
    private func gridSpacing(with screenWidth: CGFloat, cellSide: CGFloat) -> CGFloat {
        let totalCellWidth: CGFloat = 4 * cellSide
        let spacing = (screenWidth - totalCellWidth) / 5
        return spacing
    }
    
    private func cellSide(with screenWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = 5 * gridEdgePadding
        let side = (screenWidth - spacing) / 4
        return side
    }
    
    func addSumToTotal(sum: Float) {
        challenge.savedSum += sum.roundedUpTwoDecimals()
    }
    
    func simpleSuccess(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(notificationType)
    }
    
    func getColorForEnvelope(at index: Int) -> Color {
        let envelopes = challenge.envelopes
        
        guard !envelopes[index].opened else { return .secondary }
        guard index != 0 else { return .blue }
        guard !envelopes[index - 1].opened else {
            if index == envelopes.count - 1 || !envelopes[index + 1].opened { return .blue }
            else { return .primary }
        }
        return .primary
    }
    
    func presentAlert(type: AlertType) {
        currentAlertType = type
        withAnimation {
            alertPresented = true
        }
    }
}


extension Float {
    func roundedUpTwoDecimals() -> Float {
        return (self*100).rounded()/100
    }
}


struct EnvelopeAlertView: View {
    @State var alertType: AlertType
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
            Color.blue.opacity(0.5)
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
                                .background(Color.blue)
                                .cornerRadius(30)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        Button {
                            successAction()
                            alertType = .envelopeResult(envSum)
                            
                        } label: {
                            Text("Let's do it!")
                                .foregroundColor(Color.white)
                                .frame(width: 100, height: 50, alignment: .center)
                                .background(Color.blue)
                                .cornerRadius(30)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                    }
                default: EmptyView()
                }
            }
        }
    }
}
