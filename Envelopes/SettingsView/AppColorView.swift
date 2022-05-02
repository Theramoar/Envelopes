import SwiftUI

struct AppColorView: View {
    @Environment(\.colorScheme) var colorScheme
    let themeSet: ThemeSet
    let currentColor: Bool
    var tapAction: (ThemeSet) -> Void
    
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    
    var body: some View {
        ZStack {
            themeSet.theme(for: colorScheme).accentColor
                .cornerRadius(30)
                .frame(width: 40, height: 40, alignment: .center)
            if currentColor {
                Image(systemName: "checkmark")
            }
        }
        .onTapGesture {
            tapAction(themeSet)
        }
    }
}

struct ColorPickerView: View {
    var tapAction: (ThemeSet) -> Void
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("App Theme")
                .fontWeight(.medium)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(colorThemeViewModel.defaultThemes) { themeSet in
                        AppColorView(themeSet: themeSet,
                                     currentColor: colorThemeViewModel.isCurrent(themeSet),
                                     tapAction: tapAction)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}


