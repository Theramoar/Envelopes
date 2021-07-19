//
//  CreateChallengeView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 13/06/2021.
//

import SwiftUI


class CreateChallengeViewModel: ObservableObject {
    private let CoreDataManager: CoreDataManager = .shared
    func saveNewChallenge() {
        
    }
}

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    
//    @Environment(\.managedObjectContext) private var moc
//    @FetchRequest(entity: Challenge.entity(), sortDescriptors: []) var challenges: FetchedResults<Challenge>
    
    @ObservedObject var viewModel: CreateChallengeViewModel
    
    @State var notificationTime: Date = defaultTime
    
    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State var totalSumString: String = ""
    @State var goalString: String = ""
    @State var daysString: String = ""
    @State var currentColor: AppColor = .blue
    @State private var date = Date()
    
    @State var deadlineEnabled = false {
        didSet {
            if deadlineEnabled {
                daysString = "0"
            }
        }
    }
    
    @State var notificationsEnabled = true
    
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
    
    
    
    func saveCurrentColor(accentColor: AppColor) {
        withAnimation {
            currentColor = accentColor
        }
    }

    
    var body: some View {
            Form {
                Section {
                    TextField("Enter challenge name", text: $goalString)
                    TextField("Enter total sum", text: $totalSumString)
                        .keyboardType(.decimalPad)
                    
                    Group {
                        Toggle(isOn: $notificationsEnabled.animation()) {
                            Text("Allow daily notifications")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: currentColor.rawValue)))
                        if notificationsEnabled {
                            HStack {
                                Text("Notification time")
                                DatePicker("Notification time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Accent Color:")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(AppColorWrapper.appColors, id: \.self) { color in
                                    AppColorView(accentColor: color,
                                                 currentColor: currentColor == color,
                                                 tapAction: saveCurrentColor)
                                }
                            }
                        }
                    }
                }
                Section(footer:
                            Button {
                                createChallenge()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Create challenge")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color.white)
                                        .frame(width: 300, height: 45, alignment: .center)
                                        .background(Color(hex: currentColor.rawValue))
                                        .cornerRadius(15)
                                        .padding()
                                    Spacer()
                                }
                            }
                ) {
                    TextField("Days of challenge", text: $daysString)
                        .disabled(deadlineEnabled)
                        .keyboardType(.numberPad)
                    Toggle(isOn: $deadlineEnabled.animation()) {
                        Text("Set challenge deadline")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: currentColor.rawValue)))
                    
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
        newChallenge.colorString = currentColor.rawValue
        newChallenge.reminderTime = notificationTime
        newChallenge.isReminderSet = notificationsEnabled
        
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
        
        challenges.forEach {$0.isActive = false }
        newChallenge.isActive = true
        
        try? self.moc.save()
        
        var testSum: Float = 0
        envelopes.forEach { testSum += $0.sum }
        print(testSum)
    }
}
