import SwiftUI

struct ThemedBackground: ViewModifier {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        ZStack {
            colorThemeViewModel.backgroundColor(for: colorScheme)
                .ignoresSafeArea()
            content
        }
    }
}

struct ThemedList: ViewModifier {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .listRowBackground(colorThemeViewModel.foregroundColor(for: colorScheme))
    }
}

extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackground())
    }
    
    func themedList() -> some View {
        modifier(ThemedList())
    }
}
