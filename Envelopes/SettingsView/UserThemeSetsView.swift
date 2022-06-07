import SwiftUI

struct UserThemeSetsView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    var tapAction: (ThemeSet) -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(colorThemeViewModel.userThemes.indices, id: \.self) { index in
                    let themeSet = colorThemeViewModel.userThemes[index]
                    HStack {
                        AppColorView(themeSet: themeSet,
                                     currentColor: colorThemeViewModel.isCurrent(themeSet),
                                     tapAction: tapAction)
                        Text("Theme \(index + 1)")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tapAction(themeSet)
                    }
                }
                .onDelete(perform: colorThemeViewModel.deleteThemes)
                NavigationLink("Create Theme", destination: CreateThemeView(viewModel: CreateThemeViewModel(colorScheme: colorScheme)))
                    .font(.system(size: 15, weight: .medium))
            }.themedList()
        }.themedScreenBackground()
            .navigationTitle("Custom Themes")
    }
}
