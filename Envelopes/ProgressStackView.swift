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
            let savedSum = "$" + String(challenge.savedSum.roundedUpTwoDecimals())
            let totalSum = "$" + String(challenge.totalSum.roundedUpTwoDecimals())
            HStack {
                let saved = "Saved " + String(Int(challenge.savedSum.roundedUpTwoDecimals() / challenge.totalSum.roundedUpTwoDecimals() * 100)) + "%"
                Text(saved)
                    .font(.system(size: 21, weight: .medium))
                Spacer()
                Text(savedSum + " / " + totalSum)
                    .font(.system(size: 16))
            }
            let color = Color(hex: challenge.accentColor.rawValue)
            ProgressView(value: challenge.savedSum, total: challenge.totalSum)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding()
        .cornerRadius(10)
    }
}
