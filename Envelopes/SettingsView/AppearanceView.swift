import SwiftUI

struct AppearanceView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    let viewModel: AppearanceViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ThemePreviewView(viewModel: ThemePreviewViewModel(colorScheme: colorScheme))
                .padding()
            VStack {
                ColorThemePickerView(type: .defaultThemes, tapAction: viewModel.processNewTheme)
                Divider()
                
                if !colorThemeViewModel.userThemes.isEmpty {
                    ColorThemePickerView(type: .userThemes, tapAction: viewModel.processNewTheme)
                    Divider()
                }
                
                NavigationLink(destination: CreateThemeView(viewModel: viewModel.viewModelForCreateTheme(colorScheme: colorScheme))) {
                    HStack {
                        Text("Create Theme")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.primary)
                    .font(.system(size: 15, weight: .medium)).padding(5)
                }
                Divider()
            }
            .padding(.horizontal)
        }
        .navigationBarTitle("Appearance")
        .themedBackground()
    }
}


class AppearanceViewModel {
    var processNewTheme: (ThemeSet) -> ()
    
    init(newThemeHandler: @escaping (ThemeSet) -> ()) {
        processNewTheme = newThemeHandler
    }
    
    func viewModelForCreateTheme(colorScheme: ColorScheme) -> CreateThemeViewModel {
        CreateThemeViewModel(colorScheme: colorScheme)
    }
}
