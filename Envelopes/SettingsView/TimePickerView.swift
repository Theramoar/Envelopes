//
//  TimePickerView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 27/07/2021.
//

import SwiftUI

enum Frequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Every Week"
    case twoWeeks = "Every two weeks"
    case monthly = "Every Month"
}

struct TimePickerView: View {
    @ObservedObject var viewModel: TimePickerViewModel

    
    var body: some View {
        Toggle(isOn: $viewModel.notificationsEnabled.animation()) {
            Text("Allow notifications")
                .fontWeight(.medium)
        }
        .toggleStyle(SwitchToggleStyle(tint: viewModel.appColor))
        .onChange(of: viewModel.notificationsEnabled, perform: { isEnabled in
            if isEnabled, !UserSettings.shared.remindersEnabled {
                NotificationManager.requestNotificationAuthorization { success in
                    //Wait for 0.5 seconds to finish the animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.setupNotificationEnabled(success)
                    }
                }
            } else {
                if UserSettings.shared.remindersEnabled {
                    viewModel.setupNotificationEnabled(isEnabled)
                }
            }
        })
        if viewModel.notificationsEnabled {
            HStack {
            Text("Frequency")
            .font(.system(size: 12, weight: .regular))
                Spacer()
            Picker("Frequency", selection: $viewModel.selectedFrequency) {
                ForEach(0 ..< Frequency.allCases.count) {
                    Text("\(Frequency.allCases[$0].rawValue)")
                }
            }
            .pickerStyle(MenuPickerStyle())
            .font(.system(size: 12, weight: .regular))
            .onChange(of: viewModel.selectedFrequency) { newValue in
                viewModel.setupNotificationFrequency(newValue)
            }
        }
            
            DatePicker("Start date", selection: $viewModel.notificationStartDate, displayedComponents: .date)
                .font(.system(size: 12, weight: .regular))
                .onChange(of: viewModel.notificationStartDate, perform: { newDate in
                    viewModel.setupNotificationStartDate(newDate)
                })
            
            DatePicker("Notification time", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                .onChange(of: viewModel.notificationTime, perform: { newTime in
                    viewModel.setupNewNotificationTime(newTime)
                })
                .font(.system(size: 12, weight: .regular))
        }
    }
}

class TimePickerViewModel: ObservableObject {
    private var challengeExists: Bool
    @Published var notificationTime: Date
    @Published var notificationStartDate: Date
    
    var notificationFullDate: Date!
    
    @Published var notificationsEnabled: Bool
    @Published var appColor: Color
    @Published var selectedFrequency: Int
    var frequency: Frequency {
            return Frequency.allCases[selectedFrequency]
        }
    
    var returnNewValues: ((Bool, Date, Date, Int) -> Void)?
    
    init(activeChallenge: Challenge?, valuesHandler: ((Bool, Date, Date, Int) -> Void)? = nil) {
        self.challengeExists = activeChallenge != nil
        self.notificationsEnabled = activeChallenge?.isReminderSet ?? false
        self.notificationTime = activeChallenge?.reminderTime ?? SettingsViewModel.defaultTime
        self.appColor = Color(hex: activeChallenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
        self.selectedFrequency = Int(activeChallenge?.reminderFrequency ?? 0)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        self.notificationStartDate = activeChallenge?.reminderStartDate ?? tomorrow
    }
    
    init(isReminderSet: Bool, reminderTime: Date, accentColor: AppColor, reminderFrequency: Int, reminderStartDate: Date?, valuesHandler: ((Bool, Date, Date, Int) -> Void)? = nil) {
        self.challengeExists = false
        self.notificationsEnabled = isReminderSet
        self.notificationTime = reminderTime
        self.appColor = Color(hex: accentColor.rawValue)
        self.selectedFrequency = Int(reminderFrequency)
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        self.notificationStartDate = reminderStartDate ?? tomorrow
        self.returnNewValues = valuesHandler
    }
    
    func setupNewNotificationTime(_ newTime: Date) {
        
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.day, .month, .year], from: notificationFullDate)
//        components = calendar.dateComponents([.minute, .hour], from: newTime)
//        notificationFullDate = calendar.date(from: components)
//
//        let result = calendar.compare(notificationFullDate, to: Date(), toGranularity: .minute)
//        guard result != .orderedAscending else {
//            return
//        }
        
        guard challengeExists else {
            returnNewValues?(notificationsEnabled, notificationTime, notificationStartDate, selectedFrequency)
            return
        }
        CoreDataManager.shared.setNewTime(newTime)
    }
    
    func setupNotificationStartDate(_ startDate: Date) {
        
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.minute, .hour], from: notificationFullDate)
//        components = calendar.dateComponents([.day, .month, .year], from: startDate)
//        notificationFullDate = calendar.date(from: components)
        
        
        guard challengeExists else {
            returnNewValues?(notificationsEnabled, notificationTime, notificationStartDate, selectedFrequency)
            return
        }
        CoreDataManager.shared.setNewStartDate(startDate)
    }
    
    func setupNotificationFrequency(_ frequency: Int) {
        guard challengeExists else {
            returnNewValues?(notificationsEnabled, notificationTime, notificationStartDate, selectedFrequency)
            return
        }
        CoreDataManager.shared.setFrequency(frequency)
    }
    
    func setupNotificationEnabled(_ notiEnabled: Bool) {
        guard challengeExists else {
            returnNewValues?(notificationsEnabled, notificationTime, notificationStartDate, selectedFrequency)
            return
        }
        CoreDataManager.shared.setNotificationEnable(notiEnabled)
    }
}
