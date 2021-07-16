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
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Challenge.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isActive == true")) var challenges: FetchedResults<Challenge>
    var challenge: Challenge? {
        challenges.first
    }
    
    @State private var alertPresented = false
    @State private var alertMessage = ""
    @State var currentAlertType: AlertType!
    
    @State private var currentIndex: Int = 0
    
    @State private var presentMenuView = false
    
    @State private var presentCreateChallengeView = false
    
    let gridEdgePadding: CGFloat = 10
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            if let challenge = challenge {
                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack {
                            Text(challenge.goal!)
                                .padding()
                                .font(.system(size: 35, weight: .heavy, design: .rounded))
                            Spacer()
                            Button(action: { presentMenuView = true}, label: {
                                Image(systemName: "gear")
                                    .frame(width: 40, height: 40)
                                    .background(Color(hex: challenge.accentColor.rawValue))
                                    .cornerRadius(30)
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 20))
                            })
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        ProgressStackView(challenge: challenge)
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding(gridEdgePadding)
                        LazyVGrid(columns: columns, spacing: nil) {
                            
                            
                            
                            ForEach(challenge.envelopesArray.indices, id: \.self) { index in
                                let envelope = challenge.envelopesArray[index]
                                let rounded = envelope.sum.roundedUpTwoDecimals()
                                let imageName = envelope.isOpened ? "envelope.open" : "envelope"
                                
                                if  index != 0, index % 16 == 0 {
                                    Section(header: Divider()) {}
                                    VStack {
                                        Image(systemName: imageName)
                                            .font(.system(size: 50, weight: .ultraLight))
                                            .foregroundColor(getColorForEnvelope(at: index))
                                        Text("Day \(index + 1)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    .onTapGesture {
                                        guard !challenge.envelopesArray[index].isOpened else {
                                            simpleSuccess(.warning)
                                            presentAlert(type: .envelopeAlreadyOpened(rounded))
                                            return
                                        }
                                        guard index == 0 || challenge.envelopesArray[index - 1].isOpened else {
                                            simpleSuccess(.error)
                                            presentAlert(type: .envelopeUnavailable)
                                            return
                                        }
                                        currentIndex = index
                                        simpleSuccess(.success)
                                        presentAlert(type: .shouldOpenEnvelope(rounded))
                                    }
                                }
                                
                                else {
                                    
                                    VStack {
                                        Image(systemName: imageName)
                                            .font(.system(size: 50, weight: .ultraLight))
                                            .foregroundColor(getColorForEnvelope(at: index))
                                        Text("Day \(index + 1)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    .onTapGesture {
                                        guard !challenge.envelopesArray[index].isOpened else {
                                            simpleSuccess(.warning)
                                            presentAlert(type: .envelopeAlreadyOpened(rounded))
                                            return
                                        }
                                        guard index == 0 || challenge.envelopesArray[index - 1].isOpened else {
                                            simpleSuccess(.error)
                                            presentAlert(type: .envelopeUnavailable)
                                            return
                                        }
                                        currentIndex = index
                                        simpleSuccess(.success)
                                        presentAlert(type: .shouldOpenEnvelope(rounded))
                                    }
                                    
                                }
                            }
                            .padding(10)
                        
                            
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(gridEdgePadding)
                    }
                    
                    .padding(gridEdgePadding)
                    .edgesIgnoringSafeArea(.bottom)
                    .blur(radius: alertPresented ? 10 : 0)
                }
            } else {
                Button("Create new challenge") {
                    presentCreateChallengeView = true
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { presentMenuView = true}, label: {
                            Image(systemName: "gear")
                                .frame(width: 40, height: 40)
                                .background(Color.blue)
                                .cornerRadius(30)
                                .padding()
                                .foregroundColor(Color.white)
                                .font(.system(size: 20))
                        })
                    }
                    Spacer()
                }
            }
            if alertPresented {
                let color = Color(hex: challenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
                EnvelopeAlertView(alertType: currentAlertType,appColor: color, cancelAction: cancelAlert, successAction: openEnvelope)
                    .onTapGesture(perform: cancelAlert)
            }
        }
        .sheet(isPresented: $presentMenuView) {
            SettingsView(viewModel: MenuViewModel())
                .environment(\.managedObjectContext, moc)
        }
        .sheet(isPresented: $presentCreateChallengeView) {
            CreateChallengeView(viewModel: CreateChallengeViewModel())
        }
    }
    
    func cancelAlert() {
        withAnimation{
            alertPresented = false
        }
    }
    
    func openEnvelope() {
        guard let challenge = challenge else { return }
        addSumToTotal(sum: challenge.envelopesArray[currentIndex].sum)
        challenge.envelopesArray[currentIndex].isOpened = true
        try? moc.save()
    }
    
    func addSumToTotal(sum: Float) {
        challenge?.savedSum += sum.roundedUpTwoDecimals()
    }
    
    func simpleSuccess(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(notificationType)
    }
    
    func getColorForEnvelope(at index: Int) -> Color {
        guard let envelopes = challenge?.envelopesArray else { return .primary }
        let appColor = Color(hex: challenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
        
        guard !envelopes[index].isOpened else { return .secondary }
        guard index != 0 else { return appColor }
        guard !envelopes[index - 1].isOpened else {
            if index == envelopes.count - 1 || !envelopes[index + 1].isOpened { return appColor }
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
