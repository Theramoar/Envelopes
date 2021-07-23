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
                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack {
                            Text(challenge.goal!)
                                .padding()
                                .font(.system(size: 35, weight: .bold))
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
                        
                        ProgressStackView(viewModel: ProgressStackViewModel(challenge: challenge))
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
                                            .foregroundColor(viewModel.getColorForEnvelope(at: index))
                                        Text("Day \(index + 1)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    .onTapGesture {
                                        guard !challenge.envelopesArray[index].isOpened else {
                                            viewModel.simpleSuccess(.warning)
                                            presentAlert(type: .envelopeAlreadyOpened(rounded))
                                            return
                                        }
                                        guard index == 0 || challenge.envelopesArray[index - 1].isOpened else {
                                            viewModel.simpleSuccess(.error)
                                            presentAlert(type: .envelopeUnavailable)
                                            return
                                        }
                                        viewModel.currentIndex = index
                                        viewModel.simpleSuccess(.success)
                                        presentAlert(type: .shouldOpenEnvelope(rounded))
                                    }
                                }
                                
                                else {
                                    
                                    VStack {
                                        Image(systemName: imageName)
                                            .font(.system(size: 50, weight: .ultraLight))
                                            .foregroundColor(viewModel.getColorForEnvelope(at: index))
                                        Text("Day \(index + 1)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    .onTapGesture {
                                        guard !challenge.envelopesArray[index].isOpened else {
                                            viewModel.simpleSuccess(.warning)
                                            presentAlert(type: .envelopeAlreadyOpened(rounded))
                                            return
                                        }
                                        guard index == 0 || challenge.envelopesArray[index - 1].isOpened else {
                                            viewModel.simpleSuccess(.error)
                                            presentAlert(type: .envelopeUnavailable)
                                            return
                                        }
                                        viewModel.currentIndex = index
                                        viewModel.simpleSuccess(.success)
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
                let color = Color(hex: viewModel.challenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
                EnvelopeAlertView(alertType: currentAlertType,appColor: color, cancelAction: cancelAlert, successAction: viewModel.openEnvelope)
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
}
