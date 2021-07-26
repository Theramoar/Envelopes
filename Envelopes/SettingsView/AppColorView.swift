//
//  AppColorView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 19/07/2021.
//

import SwiftUI

struct AppColorWrapper: Identifiable {
    var id = UUID()
    static let appColors: [AppColor] = AppColor.allCases
}

enum AppColor: String, CaseIterable {
    case blue = "007AFF"
    case red = "FF3B30"
    case yellow = "FFCC00"
    case green = "34C759"
    case purple = "AF52DE"
    case orange = "FF9500"
    case pink = "FF2D55"
}

struct AppColorView: View {
    let accentColor: AppColor
    let currentColor: Bool
    
    var tapAction: (AppColor) -> Void
    
    var body: some View {
        ZStack {
            Color(hex: accentColor.rawValue)
                .cornerRadius(30)
                .frame(width: 40, height: 40, alignment: .center)
            if currentColor {
                Image(systemName: "checkmark")
            }
        }
        .onTapGesture {
            tapAction(accentColor)
        }
    }
}
