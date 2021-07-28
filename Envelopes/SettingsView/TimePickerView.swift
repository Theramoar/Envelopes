//
//  TimePickerView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 27/07/2021.
//

import SwiftUI

struct TimePickerView: View {
    @ObservedObject var viewModel: TimePickerViewModel
    
    var body: some View {
        #warning("TEST THIS!!!")
        Toggle(isOn: $viewModel.notificationsEnabled.animation()) {
            Text("Daily notifications")
                .fontWeight(.medium)
        }
        .toggleStyle(SwitchToggleStyle(tint: viewModel.appColor))
        .onChange(of: viewModel.notificationsEnabled, perform: { isEnabled in
            if isEnabled, !UserSettings.shared.remindersEnabled {
                NotificationManager.requestNotificationAuthorization { success in
                    //Wait for 0.5 seconds to finish the animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.setupNotificationEnabled(success)
                        //                        viewModel.notificationsEnabled = success
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
                Text("Notification time")
                    .fontWeight(.medium)
                DatePicker("Notification time", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .onChange(of: viewModel.notificationTime, perform: { newTime in
                        viewModel.setupNewNotificationTime(newTime)
                    })
            }
        }
    }
}

class TimePickerViewModel: ObservableObject {
    @Published var notificationTime: Date
    @Published var notificationsEnabled: Bool
    @Published var appColor: Color
    
    init(activeChallenge: Challenge?) {
        self.notificationsEnabled = activeChallenge?.isReminderSet ?? false
        self.notificationTime = activeChallenge?.reminderTime ?? SettingsViewModel.defaultTime
        self.appColor = Color(hex: activeChallenge?.accentColor.rawValue ?? AppColor.blue.rawValue)
    }
    
    func setupNewNotificationTime(_ newTime: Date) {
        CoreDataManager.shared.setNewTime(newTime)
        #warning("Check if we need that here")
//        NotificationManager.setDailyNotificationTime(for: newTime)
    }
    
    func setupNotificationEnabled(_ notificationsEnabled: Bool) {
        CoreDataManager.shared.setNotificationEnable(notificationsEnabled)
    }
}
