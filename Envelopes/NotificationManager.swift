//
//  NotificationManager.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 23/07/2021.
//

import SwiftUI

class NotificationManager {
    private static let notificationCenter: UNUserNotificationCenter = .current()
    
    static func requestNotificationAuthorization(completion: ((Bool) -> Void)? = nil) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            UserSettings.shared.remindersEnabled = success
            completion?(success)
            if let error = error {
                print("MISHA - \(error.localizedDescription)")
            }
        }
    }
    
    static func setDailyNotificationTime(for time: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = "It's time to open the Envelope!"
        content.subtitle = "Let's open the Envelope and save some money."
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        
        // show this notification five seconds from now
        var triggerDate = DateComponents()
        
        triggerDate.hour = calendar.component(.hour, from: time)
        triggerDate.minute = calendar.component(.minute, from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        clearNotificationCenter()
        
        notificationCenter.add(request)
        notificationCenter.getPendingNotificationRequests { requests in
            print("MISHA Notification - \(requests)")
        }
    }
    
    
    private static func clearNotificationCenter() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}