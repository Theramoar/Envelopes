//
//  CreateChallengeView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 13/06/2021.
//

import SwiftUI


class CreateChallengeViewModel: ObservableObject {
}

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Challenge.entity(), sortDescriptors: []) var challenges: FetchedResults<Challenge>
    
    @ObservedObject var viewModel: CreateChallengeViewModel
    
    
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
    
    
    private func createChallenge() {
        guard let totalSum = Float(totalSumString), totalSum > 0 else { return }
        let pureDaysString = daysString.replacingOccurrences(of: " days", with: "")
        guard let days = Int(pureDaysString), days > 0 else { return }
        guard !goalString.isEmpty else { return }
        
        
        
        var totalIncrease: Int = 0
        for day in 0..<days {
            if day != 0 {
                totalIncrease += day
            }
        }
        
        let rawStep = (totalSum - Float(days)) / Float(totalIncrease)
        let step = rawStep.roundedUpTwoDecimals()
        
        let totalActualSum = Float(days) + (Float(totalIncrease) * step)
        let correction = totalSum - totalActualSum
        
        
        print(totalSum)
        print(totalActualSum)
        print(correction)
        print(totalActualSum + correction)
        
        
        let newChallenge = Challenge(context: self.moc)
        newChallenge.goal = goalString
        newChallenge.days = Int32(days)
        newChallenge.totalSum = totalSum
        newChallenge.savedSum = 0.0
        newChallenge.step = step
        newChallenge.correction = correction
        
        var envelopes = [Envelope]()
        var envelopeSum: Float = 1
        for _ in 1...days {
            let newEnv = Envelope(context: self.moc)
            newEnv.sum = envelopeSum
            envelopes.append(newEnv)
            envelopeSum += step
        }
        envelopes.shuffle()
        envelopes[0].sum += correction

        newChallenge.envelopes = NSOrderedSet(array: envelopes)
        
        if challenges.isEmpty {
            newChallenge.isActive = true
        }
        
        try? self.moc.save()
        
        var testSum: Float = 0
        envelopes.forEach { testSum += $0.sum }
        print(testSum)
    }
}
