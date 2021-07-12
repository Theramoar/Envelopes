//
//  Challenge.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 13/06/2021.
//

import Foundation


class UserData: ObservableObject {
    @Published var challenges = [Challenge]()
}

class Challenge: Identifiable, ObservableObject {
    var goal: String
    var days: Int
    var totalSum: Float
    @Published var savedSum: Float
    var step: Float
    var correction: Float
    
    
    @Published var envelopes: [Envelope]
    
    init(goal: String, days: Int, sum: Float) {
        self.goal = goal
        self.days = days
        self.totalSum = sum
        self.savedSum = 0.0
        
        var totalIncrease: Int = 0
        
        for day in 0..<days {
            if day != 0 {
                totalIncrease += day
            }
        }
        
        let rawStep = (totalSum - Float(days)) / Float(totalIncrease)
        self.step = rawStep.roundedUpTwoDecimals()
        
        
        let totalActualSum = Float(days) + (Float(totalIncrease) * step)
        self.correction = sum - totalActualSum
        
        
        print(sum)
        print(totalActualSum)
        print(self.correction)
        print(totalActualSum + self.correction)
        
        
        self.envelopes = []
        
        var envelopeSum: Float = 1
        for _ in 1...days {
            let newEnv = Envelope(sum: envelopeSum)
            envelopes.append(newEnv)
            envelopeSum += step
        }
        envelopes.shuffle()
        envelopes[0].sum += correction
        
        var testSum: Float = 0
            
        envelopes.forEach { testSum += $0.sum }
        print(testSum)
    }
}

struct Envelope {
    var sum: Float
    var opened: Bool = false
}
