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
            HStack {
                Text("Saved 30%")
                Spacer()
                
                let savedSum = String(challenge.savedSum.roundedUpTwoDecimals())
                let totalSum = String(challenge.totalSum.roundedUpTwoDecimals())
                Text(savedSum + "$" + " / " + totalSum + "$")
            }
            ProgressView(value: 21, total: 100)
        }
        .padding()
        .cornerRadius(10)
    }
}
