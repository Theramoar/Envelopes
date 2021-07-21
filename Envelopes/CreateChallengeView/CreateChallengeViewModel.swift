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
    @Published var notificationsEnabled = true
    
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
}
