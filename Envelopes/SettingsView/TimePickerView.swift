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
    case twoWeeks = "Every Two Weeks"
    case monthly = "Every Month"
}

struct TimePickerNavigationView: View {
    let viewModel: TimePickerViewModel
    var body: some View {
        Form {
            Section {
                TimePickerView(viewModel: viewModel)
            }
            .themedList()
        }
        .themedBackground()
        .navigationTitle("Reminders")
    }
}

struct TimePickerView: View {
    @ObservedObject var viewModel: TimePickerViewModel
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        Toggle(isOn: $viewModel.notificationsEnabled.animation()) {
            Text("Allow reminders")
                .fontWeight(.medium)
        }
        .toggleStyle(SwitchToggleStyle(tint: colorThemeViewModel.accentColor(for: colorScheme)))
        if viewModel.notificationsEnabled {
            HStack {
                Text("Frequency")
                    .font(.system(size: 12, weight: .regular))
                Spacer()
                Picker("Frequency", selection: $viewModel.selectedFrequency) {
                    ForEach(0 ..< Frequency.allCases.count, id: \.self) {
                        Text("\(Frequency.allCases[$0].rawValue)")
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .font(.system(size: 12, weight: .regular))
                .accentColor(colorThemeViewModel.accentColor(for: colorScheme))
            }
            
            DatePicker("Start date", selection: $viewModel.notificationStartDate, displayedComponents: .date)
                .font(.system(size: 12, weight: .regular))
            
            DatePicker("Reminder time", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                .font(.system(size: 12, weight: .regular))
        }
    }
}

class TimePickerViewModel: ObservableObject {
    private var challengeExists: Bool
    private var userSettings: UserSettings = .shared
    #warning("delete NotificationManager from here")
    private let localNotiManager = LocalNotificationManager()
    @Published var notificationTime: Date {
        didSet {
            updateValues(notificationsEnabled,
                            notificationTime,
                            notificationStartDate,
                            selectedFrequency)
        }
    }
    @Published var notificationStartDate: Date {
        didSet {
            updateValues(notificationsEnabled,
                            notificationTime,
                            notificationStartDate,
                            selectedFrequency)
        }
    }
    @Published var notificationsEnabled: Bool {
        didSet {
            if notificationsEnabled, !userSettings.remindersEnabled {
                localNotiManager.requestNotificationAuthorization { success in
                    //Wait for 0.5 seconds to finish the animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        guard let self = self else { return }
                        self.updateValues(self.notificationsEnabled,
                                             self.notificationTime,
                                             self.notificationStartDate,
                                             self.selectedFrequency)
                    }
                }
            } else {
                if userSettings.remindersEnabled {
                    updateValues(notificationsEnabled, notificationTime, notificationStartDate, selectedFrequency)
                }
            }
        }
    }
    
    @Published var selectedFrequency: Int {
        didSet {
            updateValues(notificationsEnabled, notificationTime, notificationStartDate, selectedFrequency)
        }
    }
    
//    @Published var appColor: Color
    var frequency: Frequency {
            return Frequency.allCases[selectedFrequency]
        }
    
    var updateValues: ((Bool, Date, Date, Int) -> Void)
    
    init(activeChallenge: Challenge?, valuesHandler: @escaping ((Bool, Date, Date, Int) -> Void)) {
        self.challengeExists = activeChallenge != nil
        self.notificationsEnabled = activeChallenge?.isReminderSet ?? false
        self.notificationTime = activeChallenge?.reminderTime ?? SettingsViewModel.defaultTime
//        self.appColor = activeChallenge?.appTheme?.theme(for: colorScheme).accentColor ?? AppColor.blue.color
        self.selectedFrequency = Int(activeChallenge?.reminderFrequency ?? 0)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        self.notificationStartDate = activeChallenge?.reminderStartDate ?? tomorrow
        self.updateValues = valuesHandler
    }
    
    init(isReminderSet: Bool, reminderTime: Date, reminderFrequency: Int, reminderStartDate: Date?, valuesHandler: @escaping ((Bool, Date, Date, Int) -> Void)) {
        self.challengeExists = false
        self.notificationsEnabled = isReminderSet
        self.notificationTime = reminderTime
//        self.appColor = accentColor.color
        self.selectedFrequency = Int(reminderFrequency)
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        self.notificationStartDate = reminderStartDate ?? tomorrow
        self.updateValues = valuesHandler
    }
}
