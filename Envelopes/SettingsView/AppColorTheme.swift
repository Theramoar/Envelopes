import SwiftUI

protocol Theme {
    var accentColorHex: String { get }
    var foregroundColorHex: String { get }
    var backgroundColorHex: String { get }
}

extension String {
    var color: Color {
        Color(hex: self)
    }
}

struct AppTheme {
    var isDefault: Bool
    var light: Theme
    var dark: Theme
    
    struct ColorTheme: Theme {
        var accentColorHex: String
        var foregroundColorHex: String
        var backgroundColorHex: String
    }
    
    func theme(for colorScheme: ColorScheme) -> Theme {
        colorScheme == .light ? light : dark
    }
}

let defaultTheme = AppTheme(isDefault: true,
                            light: AppTheme.ColorTheme(accentColorHex: "4191F4", foregroundColorHex: "EAF6FF", backgroundColorHex: "CDE5FF"),
                            dark: AppTheme.ColorTheme(accentColorHex: "4191F4", foregroundColorHex: "1E3751", backgroundColorHex: "021F37"))
