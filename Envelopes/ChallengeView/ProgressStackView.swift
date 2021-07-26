//
//  ProgressStackView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 12/06/2021.
//

import SwiftUI


class ProgressStackViewModel: ObservableObject {
    private var challenge: Challenge
    
    @Published var savedSum: Float
    @Published var totalSum: Float
    @Published var appColor: String
    
    init(challenge: Challenge) {
        self.challenge = challenge
        self.savedSum = challenge.savedSum
        self.totalSum = challenge.totalSum
        self.appColor = challenge.accentColor.rawValue
    }
}

struct ProgressStackView: View {
    @ObservedObject var viewModel: ProgressStackViewModel
    
    var body: some View {
        VStack {
            let savedSum = "$" + String(viewModel.savedSum.roundedUpTwoDecimals())
            let totalSum = "$" + String(viewModel.totalSum.roundedUpTwoDecimals())
            HStack {
                let saved = "Saved " + String(Int(viewModel.savedSum.roundedUpTwoDecimals() / viewModel.totalSum.roundedUpTwoDecimals() * 100)) + "%"
                Text(saved)
                    .font(.system(size: 21, weight: .medium))
                Spacer()
                Text(savedSum + " / " + totalSum)
                    .font(.system(size: 16))
            }
            let color = Color(hex: viewModel.appColor)
            ProgressView(value: viewModel.savedSum, total: viewModel.totalSum)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding()
        .cornerRadius(10)
    }
}
