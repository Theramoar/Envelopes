import SwiftUI

struct ThemedScreenBackground: ViewModifier {
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

struct ThemedActionButtonBackground: ViewModifier {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(colorThemeViewModel.accentColor(for: colorScheme))
    }
}

struct ThemedAccent: ViewModifier {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .accentColor(colorThemeViewModel.accentColor(for: colorScheme))
    }
}

struct ThemedForeground: ViewModifier {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .foregroundColor(colorThemeViewModel.accentColor(for: colorScheme))
    }
}


extension View {
    func themedScreenBackground() -> some View {
        modifier(ThemedScreenBackground())
    }
    
    func themedActionButtonBackground() -> some View {
        modifier(ThemedActionButtonBackground())
    }
    
    func themedForeground() -> some View {
        modifier(ThemedForeground())
    }
    
    func themedAccent() -> some View {
        modifier(ThemedAccent())
    }
    
    func themedList() -> some View {
        modifier(ThemedList())
    }
}
