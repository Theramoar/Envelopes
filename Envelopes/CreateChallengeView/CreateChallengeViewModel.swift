//
//  CreateChallengeViewModel.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 19/07/2021.
//

import SwiftUI

class CreateChallengeViewModel: ObservableObject {
    private let coreData: CoreDataManager = .shared
    
    @Published var notificationTime: Date = CreateChallengeViewModel.defaultTime
    @Published var totalSumString: String = ""
    @Published var goalString: String = ""
    @Published var daysString: String = ""
    @Published var currentColor: AppColor = .blue
    @Published var date = Date()
    @Published var deadlineEnabled = false
    @Published var notificationsEnabled = UserSettings.shared.remindersEnabled
    
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
    
    #warning("Вынести в отдельный юнит")
    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    
    func saveNewChallenge() {
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
        
        coreData.saveChallenge(goal: goalString, days: days, totalSum: totalSum, step: step, correction: correction, currentColor: currentColor, notificationTime: notificationTime)
            NotificationManager.setDailyNotificationTime(for: notificationTime)
        print(totalSum)
        print(totalActualSum)
        print(correction)
        print(totalActualSum + correction)
        
        #warning("Should implement this one")
//        challenges.forEach {$0.isActive = false }
//        newChallenge.isActive = true
//
//        try? self.moc.save()
        
//        var testSum: Float = 0
//        envelopes.forEach { testSum += $0.sum }
//        print(testSum)
    }
    
    func saveCurrentColor(accentColor: AppColor) {
        withAnimation {
            currentColor = accentColor
        }
    }
    
//    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void ) {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//            UserSettings.shared.remindersEnabled = success
//            completion(success)
//            if let error = error {
//                print("MISHA - \(error.localizedDescription)")
//            }
//        }
//    }
//
//    func setDailyNotificationTime(for time: Date) {
//
//        let content = UNMutableNotificationContent()
//        content.title = "TEST NOTIFICATION"
//        content.subtitle = "Let's test repeating notification"
//        content.sound = UNNotificationSound.default
//
//        print(time)
//        let calendar = Calendar.current
//
//        // show this notification five seconds from now
//        var triggerDate = DateComponents()
//
//        triggerDate.hour = calendar.component(.hour, from: time)
//        triggerDate.minute = calendar.component(.minute, from: time)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
//
//        // choose a random identifier
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        // add our notification request
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//        UNUserNotificationCenter.current().add(request)
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            print("MISHA Notification - \(requests)")
//        }
//    }
}
