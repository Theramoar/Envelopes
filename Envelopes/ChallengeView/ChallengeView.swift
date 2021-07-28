//
//  ContentView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 09/06/2021.
//

import SwiftUI
import CoreData

//https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications

struct ChallengeView: View {
    @StateObject var viewModel = ChallengeViewModel()
    
    @State private var alertPresented = false
    @State private var alertMessage = ""
    @State var currentAlertType: AlertType!
    
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
            if let challenge = viewModel.challenge {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    
                    HStack {
                        Text(challenge.goal!)
                            .padding()
                            .font(.system(size: 34, weight: .bold))
                        Spacer()
                        SettingsButton(tapAction: { presentMenuView = true }, backgroundColor: Color(hex: challenge.accentColor.rawValue))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    
                    ProgressStackView(viewModel: ProgressStackViewModel(challenge: challenge))
                        .background(Color("Foreground"))
                        .cornerRadius(15)
                        .padding(gridEdgePadding)
                    
                    
                    LazyVGrid(columns: columns, spacing: nil) {
                        ForEach(challenge.envelopesArray.indices, id: \.self) { index in
                            let envelope = challenge.envelopesArray[index]
                            
                            if  index != 0, index % 16 == 0 {
                                Section(header: Divider()) {}
                                EnvelopeView(envelope: envelope,
                                             envelopeColor: viewModel.getColorForEnvelope(at: index),
                                             dayText: "Day \(index + 1)",
                                             processEnvelope: processEnvelope)
                            } else {
                                EnvelopeView(envelope: envelope,
                                             envelopeColor: viewModel.getColorForEnvelope(at: index),
                                             dayText: "Day \(index + 1)",
                                             processEnvelope: processEnvelope)
                            }
                        }
                        .padding(10)
                    }
                    .background(Color("Foreground"))
                    .cornerRadius(15)
                    .padding(gridEdgePadding)
                    
                    
                }
                .padding(gridEdgePadding)
                .edgesIgnoringSafeArea(.bottom)
                .blur(radius: alertPresented ? 10 : 0)
                
            } else {
                NoChallengesView(tapAction: { presentCreateChallengeView = true } )
                
                VStack {
                    HStack {
                        Spacer()
                        SettingsButton(tapAction: { presentMenuView = true }, backgroundColor: Color.blue)
                    }
                    Spacer()
                }
            }
            if alertPresented {
                let color = Color(hex: viewModel.challenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
                AlertView(alertType: currentAlertType, appColor: color)
                    .onTapGesture(perform: cancelAlert)
            }
        }
        .sheet(isPresented: $presentMenuView) {
            SettingsView()
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
    
    func presentAlert(type: AlertType) {
        currentAlertType = type        
        withAnimation {
            alertPresented = true
        }
    }
    
    func processEnvelope(_ envelope: Envelope) {
        guard let challenge = viewModel.challenge else { return }
        guard let index = challenge.envelopesArray.firstIndex(of: envelope) else { return }

        let rounded = envelope.sum.roundedUpTwoDecimals()
        
        guard !envelope.isOpened else {
            viewModel.simpleSuccess(.warning)
            let message = "This one has been opened\n\nThere was $\(rounded)"
            presentAlert(type: .infoAlert(message))
            return
        }
        
        guard index == 0 || challenge.envelopesArray[index - 1].isOpened else {
            viewModel.simpleSuccess(.warning)
            let message = "Be patient!\n\nThe time will come for this one"
            presentAlert(type: .infoAlert(message))
            return
        }
        
        if let envOpenedDate = challenge.lastOpenedDate,
           Calendar.current.isDateInToday(envOpenedDate) {
            viewModel.simpleSuccess(.warning)
            let message = "Only one envelope per day!\n\nPlease, return tomorrow"
            presentAlert(type: .infoAlert(message))
            return
        }
        
        viewModel.currentIndex = index
        viewModel.simpleSuccess(.success)
        let message = "Let's save\n$\(rounded)" + "!\n\nAre you ready?"
        presentAlert(type: .actionAlert(message: message,
                                        cancelAction: cancelAlert,
                                        successAction: {
                                            viewModel.openEnvelope()
                                            cancelAlert()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                presentAlert(type: .infoAlert("Well done!\n\nYou are one step closer!"))
                                            }
        }))
    }
}

struct EnvelopeView: View {
    var envelope: Envelope
    var envelopeColor: Color
    var dayText: String
    
    var processEnvelope: (Envelope) -> Void
    
    var body: some View {
        VStack {
            let imageName = envelope.isOpened ? "envelope.open" : "envelope"
            Image(systemName: imageName)
                .font(.system(size: 50, weight: .ultraLight))
                .foregroundColor(envelopeColor)
            Text(dayText)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            processEnvelope(envelope)
        }
    }
}


struct NoChallengesView: View {
    var tapAction: () -> Void
    var body: some View {
        VStack {
            Image("sad_envelope")
                .resizable()
                .frame(width: 150, height: 150)
            Text("You don't have any active challenges")
                .font(.system(size: 20, weight: .medium))
                .padding()
            Button("Create new challenge") {
                tapAction()
            }
            .font(.system(size: 20, weight: .medium))
        }
    }
}

struct SettingsButton: View {
    @State private var presentMenuView = false
    var tapAction: () -> Void
    var backgroundColor: Color
    var body: some View {
        Button(action: tapAction, label: {
            Image(systemName: "gear")
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .cornerRadius(30)
                .padding()
                .foregroundColor(Color.white)
                .font(.system(size: 20))
        })
    }

}
