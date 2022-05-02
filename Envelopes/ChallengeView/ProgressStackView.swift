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
    
    init(challenge: Challenge) {
        self.challenge = challenge
        self.savedSum = challenge.savedSum
        self.totalSum = challenge.totalSum
    }
}

struct ProgressStackView: View {
    @ObservedObject var viewModel: ProgressStackViewModel
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
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
            ProgressView(value: viewModel.savedSum, total: viewModel.totalSum)
                .progressViewStyle(LinearProgressViewStyle(tint: colorThemeViewModel.accentColor(for: colorScheme)))
        }
        .padding()
        .cornerRadius(10)
    }
}
