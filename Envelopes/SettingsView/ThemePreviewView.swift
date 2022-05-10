import SwiftUI

struct ThemePreviewView: View {
    @StateObject var viewModel: ThemePreviewViewModel
    
    var body: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTheme.animation(), content: {
                ForEach(0 ..< viewModel.themes.count, id: \.self) {
                    Text("\(viewModel.themes[$0])")
                }
            })
            .onChange(of: viewModel.selectedTheme, perform: { newValue in
                let newScheme: ColorScheme = newValue == 0 ? .light : .dark
                viewModel.previewThemeChangedHandler?(newScheme)
            })
                .pickerStyle(.segmented)
            ChallengeView(viewModel: ChallengeViewModel(), currentAlertType: .infoAlert("Yeah"))
                .frame(height: 350)
                .cornerRadius(10)
                .shadow(radius: 10)
                .disabled(true)
                .environment(\.colorScheme, viewModel.selectedTheme == 0 ? .light : .dark)
        }
    }
}


class ThemePreviewViewModel: ObservableObject {
    @Published var themes: [String] = ["Light", "Dark"]
    @Published var selectedTheme: Int
    
    var previewThemeChangedHandler: ((ColorScheme) -> Void)?
    
    init(colorScheme: ColorScheme, previewThemeChangedHandler: ((ColorScheme) -> Void)? = nil) {
        selectedTheme = colorScheme == .light ? 0 : 1
        self.previewThemeChangedHandler = previewThemeChangedHandler
        
    }
}
