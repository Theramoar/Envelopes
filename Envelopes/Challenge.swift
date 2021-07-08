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
    
    
    var envelopes: [Float]
    
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
        self.correction = totalActualSum - sum
        
        
        self.envelopes = []
        var envelopeSum: Float = 1 + correction
        for _ in 1...days {
            envelopes.append(envelopeSum)
            envelopeSum += step
        }
        envelopes.shuffle()
    }
}
