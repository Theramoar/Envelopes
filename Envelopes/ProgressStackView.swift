//
//  ProgressStackView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 12/06/2021.
//

import SwiftUI


struct ProgressStackView: View {
    @ObservedObject var challenge: Challenge
    
    var body: some View {
        VStack {
            let savedSum = String(challenge.savedSum.roundedUpTwoDecimals()) + "$"
            let totalSum = String(challenge.totalSum.roundedUpTwoDecimals()) + "$"
            HStack {
                let saved = String(Int(challenge.savedSum.roundedUpTwoDecimals() / challenge.totalSum.roundedUpTwoDecimals() * 100)) + "%"
                Text(saved)
                Spacer()
                Text(savedSum + " / " + totalSum)
            }
            ProgressView(value: challenge.savedSum, total: challenge.totalSum)
        }
        .padding()
        .cornerRadius(10)
    }
}
