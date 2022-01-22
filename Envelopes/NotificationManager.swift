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
    
    static func setDailyNotificationTime(for time: Date, startDate: Date, frequency: Frequency, numberOfNotificcations: Int) {
        clearNotificationCenter()
        
        let content = UNMutableNotificationContent()
        content.title = "It's time to open the Envelope!"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        
        
        for noti in 0..<numberOfNotificcations {
            var triggerDate = DateComponents()
            
            let date: Date?
            switch frequency {
            case .daily:
                date = calendar.date(byAdding: .day, value: noti, to: startDate)
            case .weekly:
                date = calendar.date(byAdding: .day, value: 7 * noti, to: startDate)
            case .twoWeeks:
                date = calendar.date(byAdding: .day, value: 14 * noti, to: startDate)
            case .monthly:
                date = calendar.date(byAdding: .month, value: noti, to: startDate)
            }
            
            guard let date = date else { return }
            triggerDate.hour = calendar.component(.hour, from: time)
            triggerDate.minute = calendar.component(.minute, from: time)
            triggerDate.day = calendar.component(.day, from: date)
            triggerDate.month = calendar.component(.month, from: date)
            
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            notificationCenter.add(request)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let str = formatter.string(from: date)
            
            print("Request Added to Notification Center - \(str)")
        }
    }
    
    static func updateNotifications(for challenge: Challenge) {
        notificationCenter.getPendingNotificationRequests { notifications in
            guard let nextNoti = notifications.first?.trigger as? UNCalendarNotificationTrigger,
                  let nextDate = Calendar.current.date(from: nextNoti.dateComponents)
            else { return }
            setDailyNotificationTime(for: nextDate, startDate: nextDate, frequency: challenge.frequency, numberOfNotificcations: challenge.envelopesArray.filter({!$0.isOpened}).count)
        }
    }
    
    
    static func clearNotificationCenter() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        print("Notification Center cleared")
    }
}
