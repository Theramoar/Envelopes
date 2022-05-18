//
//  ActionButton.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 16/05/2022.
//

import SwiftUI

struct ActionButton: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var tapAction: () -> Void
    
    var body: some View {
        Button(action: tapAction) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 45, alignment: .center)
                    .background(colorThemeViewModel.accentColor(for: colorScheme))
                    .cornerRadius(15)
                    .padding()
                Spacer()
            }
        }
    }
}
