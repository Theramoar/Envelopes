import SwiftUI

struct CreateThemeView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @StateObject var viewModel: CreateThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            viewModel.themePreview
                .padding()
            
            VStack {
                ColorPicker("Accent Color", selection: $viewModel.previewAccentColor, supportsOpacity: false)
                .font(.system(size: 15, weight: .medium))
                .padding(5)
                .onChange(of: viewModel.previewAccentColor) { newValue in
                    viewModel.changePreview(accentColor: newValue)
                }
                
                Divider()
                
                ColorPicker("Background Color", selection: $viewModel.previewBackgroundColor, supportsOpacity: false)
                .font(.system(size: 15, weight: .medium))
                .padding(5)
                .onChange(of: viewModel.previewBackgroundColor) { newValue in
                    viewModel.changePreview(backgroundColor: newValue)
                }
                
                Divider()
                
                ColorPicker("Foreground Color", selection: $viewModel.previewForegroundColor, supportsOpacity: false)
                .font(.system(size: 15, weight: .medium))
                .padding(5)
                .onChange(of: viewModel.previewForegroundColor) { newValue in
                    viewModel.changePreview(foregroundColor: newValue)
                }
                
                Button {
                    viewModel.saveNewTheme()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text("Create theme")
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
            .padding(.horizontal)
        }
        .navigationTitle("Create theme")
        .themedBackground()
    }
}

class CreateThemeViewModel: ObservableObject {
    private var previewColorThemeViewModel: ColorThemeViewModel
    private var currentPreviewColorScheme: ColorScheme
    
    @Published var previewBackgroundColor: Color!
    @Published var previewForegroundColor: Color!
    @Published var previewAccentColor: Color!
    
    var themePreview: some View {
        ThemePreviewView(viewModel: ThemePreviewViewModel(colorScheme: self.currentPreviewColorScheme, previewThemeChangedHandler: self.previewThemeChangedHandler))
            .environmentObject(previewColorThemeViewModel)
    }
    
    init(colorScheme: ColorScheme) {
        previewColorThemeViewModel = ColorThemeViewModel(type: .newThemePreview)
        currentPreviewColorScheme = colorScheme
        
        switch currentPreviewColorScheme {
        case .light:
            previewBackgroundColor = previewColorThemeViewModel.previewLightBackgroundColor
            previewForegroundColor = previewColorThemeViewModel.previewLightForegroundColor
            previewAccentColor = previewColorThemeViewModel.previewLightAccentColor
        case .dark:
            previewBackgroundColor = previewColorThemeViewModel.previewDarkBackgroundColor
            previewForegroundColor = previewColorThemeViewModel.previewDarkForegroundColor
            previewAccentColor = previewColorThemeViewModel.previewDarkAccentColor
        @unknown default:
            print("Unknown ColorScheme while changing preview colours")
        }
    }
    
    func previewThemeChangedHandler(newColorScheme: ColorScheme) {
        currentPreviewColorScheme = newColorScheme
        
        switch currentPreviewColorScheme {
        case .light:
            previewBackgroundColor = previewColorThemeViewModel.previewLightBackgroundColor
            previewForegroundColor = previewColorThemeViewModel.previewLightForegroundColor
            previewAccentColor = previewColorThemeViewModel.previewLightAccentColor
        case .dark:
            previewBackgroundColor = previewColorThemeViewModel.previewDarkBackgroundColor
            previewForegroundColor = previewColorThemeViewModel.previewDarkForegroundColor
            previewAccentColor = previewColorThemeViewModel.previewDarkAccentColor
        @unknown default:
            print("Unknown ColorScheme while changing preview colours")
        }
    }
    
    func changePreview(accentColor: Color) {
        switch currentPreviewColorScheme {
        case .light:
            previewColorThemeViewModel.previewLightAccentColor = accentColor
        case .dark:
            previewColorThemeViewModel.previewDarkAccentColor = accentColor
        @unknown default:
            print("Unknown ColorScheme while changing preview colours")
        }
    }
    func changePreview(backgroundColor: Color) {
        switch currentPreviewColorScheme {
        case .light:
            previewColorThemeViewModel.previewLightBackgroundColor = backgroundColor
        case .dark:
            previewColorThemeViewModel.previewDarkBackgroundColor = backgroundColor
        @unknown default:
            print("Unknown ColorScheme while changing preview colours")
        }
    }
    func changePreview(foregroundColor: Color) {
        switch currentPreviewColorScheme {
        case .light:
            previewColorThemeViewModel.previewLightForegroundColor = foregroundColor
        case .dark:
            previewColorThemeViewModel.previewDarkForegroundColor = foregroundColor
        @unknown default:
            print("Unknown ColorScheme while changing preview colours")
        }
    }
    
    func saveNewTheme() {
        previewColorThemeViewModel.saveNewTheme()
    }
}
