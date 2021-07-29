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
    case blue = "4191F4"
    case red = "FF3B30"
    case yellow = "FFCC00"
    case green = "34C759"
    case indigo = "453CCC"
//    case purple = "7248EF"
    case orange = "FF9500"
    case pink = "E17983"
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


struct ColorPickerView: View {
    var currentColor: AppColor
    var tapAction: (AppColor) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Accent Color:")
                .fontWeight(.medium)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(AppColorWrapper.appColors, id: \.self) { color in
                        AppColorView(accentColor: color,
                                     currentColor: currentColor == color,
                                     tapAction: tapAction)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}


