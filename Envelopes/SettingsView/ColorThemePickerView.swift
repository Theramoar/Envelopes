import SwiftUI

struct ColorThemePickerView: View {
    enum ColorThemePickerType {
        case userThemes
        case defaultThemes
    }
    
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    var type: ColorThemePickerType
    var tapAction: (ThemeSet) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            let title = type == .defaultThemes ? "Default Themes" : "Custom Themes"
            HStack {
                Text(title)
                    .fontWeight(.medium)
                
                if type == .userThemes {
                    Spacer()
                    NavigationLink(destination: UserThemeSetsView(tapAction: tapAction)) {
                        Text("More")
                            .fontWeight(.medium)
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    let themeSets: [ThemeSet] = type == .defaultThemes ? colorThemeViewModel.defaultThemes : colorThemeViewModel.userThemes
                    ForEach(themeSets) { themeSet in
                        AppColorView(themeSet: themeSet,
                                     currentColor: colorThemeViewModel.isCurrent(themeSet),
                                     tapAction: tapAction)
                    }
                }
            }
        }
        .padding(.bottom, 5)
    }
}


struct AppColorView: View {
    @Environment(\.colorScheme) var colorScheme
    let themeSet: ThemeSet
    let currentColor: Bool
    var tapAction: (ThemeSet) -> Void
    
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


