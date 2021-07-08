//
//  CreateChallengeView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 13/06/2021.
//

import SwiftUI

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var userData: UserData
    
    @State var totalSumString: String = ""
    @State var goalString: String = ""
    @State var daysString: String = ""
    @State var deadlineEnabled = false {
        didSet {
            if deadlineEnabled {
                daysString = "0"
            }
        }
    }
    @State private var date = Date()
    
    
    
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current

        let startComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        
        var termComponents = DateComponents()
        termComponents.setValue(100, for: .year)
        let expirationDate = Calendar.current.date(byAdding: termComponents, to: Date())
        
        let endComponents = calendar.dateComponents([.day, .month, .year], from: expirationDate!)
        
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()

    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section {
                        TextField("Enter final goal", text: $goalString)
                        TextField("Enter total sum", text: $totalSumString)
                            .keyboardType(.decimalPad)
                    }
                    Section {
                        TextField("Days of challenge", text: $daysString)
                            .disabled(deadlineEnabled)
                            .keyboardType(.numberPad)
                        Toggle(isOn: $deadlineEnabled.animation()) {
                            Text("Set challenge deadline")
                        }
                        
                        if deadlineEnabled {
                            DatePicker("Deadline", selection: $date, in: dateRange, displayedComponents: [.date])
                                .onChange(of: date, perform: { value in
                                    let calendar = Calendar.current
                                    let endComponents = calendar.dateComponents([.day], from: Date(), to: value)
                                    let formatter = DateComponentsFormatter()
                                    let days = formatter.string(from: endComponents)
                                    if let days = days {
                                        daysString = String(days.dropLast()) + " days"
                                    }
                                })
                        }
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
                VStack {
                    Spacer()
                    Button {
                        createChallenge()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Create challenge")
                            .foregroundColor(Color.white)
                            .frame(width: 300, height: 60, alignment: .center)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
            }
            .navigationTitle("New challenge")
        }
    }
    
    
    private func createChallenge() {
        guard let totalSum = Float(totalSumString), totalSum > 0 else { return }
        let pureDaysString = daysString.replacingOccurrences(of: " days", with: "")
        guard let days = Int(pureDaysString), days > 0 else { return }
        guard !goalString.isEmpty else { return }
        
        let newChallenge = Challenge(goal: goalString, days: days, sum: totalSum)
        userData.challenges.append(newChallenge)
    }
}
