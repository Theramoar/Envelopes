import SwiftUI

class ColorThemeViewModel: ObservableObject {
    enum ViewModelType {
        case regular
        case newChallenge
        case newThemePreview
        
        var notificationName: NSNotification.Name? {
            switch self {
            case .regular:
                return .themeSetModelWasUpdated
            case .newChallenge:
                return NSNotification.Name("NewChallengeThemeWasUpdated")
            case .newThemePreview:
                return nil
            }
        }
    }
    private let type: ViewModelType
    private let coreData: CoreDataManager = .shared
    private let notificationCenter: NotificationCenter = .default
    
    var defaultThemes: [ThemeSet] = []
    @Published var userThemes: [ThemeSet] = []
    
    @Published var currentThemeSet: ThemeSet!
    
    @Published var previewLightBackgroundColor: Color!
    @Published var previewLightForegroundColor: Color!
    @Published var previewLightAccentColor: Color!
    
    @Published var previewDarkBackgroundColor: Color!
    @Published var previewDarkForegroundColor: Color!
    @Published var previewDarkAccentColor: Color!
    
    init(type: ViewModelType = .regular) {
        self.type = type
        
        if let notificationName = type.notificationName {
            notificationCenter.addObserver(self, selector: #selector(setThemes), name: notificationName, object: nil)
        }
        
        setDefaultThemes()
        currentThemeSet = coreData.activeChallenge?.appTheme ?? defaultThemes.first!
        
        if type == .newThemePreview {
            previewLightAccentColor = currentThemeSet.theme(for: .light).accentColor
            previewLightBackgroundColor = currentThemeSet.theme(for: .light).backgroundColor
            previewLightForegroundColor = currentThemeSet.theme(for: .light).foregroundColor
            
            previewDarkAccentColor = currentThemeSet.theme(for: .dark).accentColor
            previewDarkBackgroundColor = currentThemeSet.theme(for: .dark).backgroundColor
            previewDarkForegroundColor = currentThemeSet.theme(for: .dark).foregroundColor
        }
    }
    
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        if type == .newThemePreview {
            return colorScheme == .light ? previewLightBackgroundColor : previewDarkBackgroundColor
        } else {
            return currentThemeSet.theme(for: colorScheme).backgroundColor
        }
    }
    
    func foregroundColor(for colorScheme: ColorScheme) -> Color {
        if type == .newThemePreview {
            return colorScheme == .light ? previewLightForegroundColor : previewDarkForegroundColor
        } else {
            return currentThemeSet.theme(for: colorScheme).foregroundColor
        }
    }
    
    func accentColor(for colorScheme: ColorScheme) -> Color {
        if type == .newThemePreview {
            return colorScheme == .light ? previewLightAccentColor : previewDarkAccentColor
        } else {
            return currentThemeSet.theme(for: colorScheme).accentColor
        }
    }
    
    func color(for envelopeStatus: EnvelopeStatus, _ colorScheme: ColorScheme) -> Color {
        switch envelopeStatus {
        case .opened:
            return .secondary
        case .active:
            return accentColor(for: colorScheme)
        case .closed:
            return .primary
        }
    }
    
    func isCurrent(_ theme: ThemeSet) -> Bool {
        currentThemeSet == theme
    }
    
    func setDefaultThemes() {
        let themes = coreData.themeSets
        userThemes = themes.filter({ !$0.isDefault })
        
        let defaultThemes = themes.filter({ $0.isDefault })
        if !defaultThemes.isEmpty {
            self.defaultThemes = defaultThemes
        } else {
            DefaultThemeData.sets.forEach {
                coreData.saveTheme(darkTheme: $0.dark, lightTheme: $0.light, isDefault: true)
            }
        }
    }
    
    @objc private func setThemes(notification: NSNotification) {
        let themes = coreData.themeSets
        userThemes = themes.filter({ !$0.isDefault })
        defaultThemes = themes.filter({ $0.isDefault })
        
        let themeSet = notification.userInfo?["themeSet"] as? ThemeSet ?? self.coreData.activeChallenge?.appTheme ?? self.defaultThemes.first!
        update(currentThemeSet: themeSet)
    }
    
    private func update(currentThemeSet: ThemeSet) {
        #warning("Fixed bug. App is not crashing if you delete active challenge. However find the way for better implementation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation {
                self.currentThemeSet = currentThemeSet
            }
        }
        
    }
    
    func saveNewTheme() {
        let lightTheme = Theme(accentColor: previewLightAccentColor, foregroundColor: previewLightForegroundColor, backgroundColor: previewLightBackgroundColor)
        let darkTheme = Theme(accentColor: previewDarkAccentColor, foregroundColor: previewDarkForegroundColor, backgroundColor: previewDarkBackgroundColor)
        coreData.saveTheme(darkTheme: darkTheme, lightTheme: lightTheme)
    }
    
    func deleteThemes(at indexSet: IndexSet) {
        indexSet.forEach {
            let themeSet = userThemes[$0]
            coreData.replace(deleted: themeSet, with: defaultThemes.first!)
            coreData.delete(colorThemeSet: themeSet)
        }
    }
}


fileprivate struct DefaultThemeData {
    let light: Theme
    let dark: Theme
    
    static let sets: [DefaultThemeData] = [blueThemeData,
                                           redThemeData,
                                           greenThemeData,
                                           yellowThemeData,
                                           violetThemeData]
    
    static private let blueThemeData = DefaultThemeData(
        light: Theme(accentColor: "4191F4".color, foregroundColor: "EAF6FF".color, backgroundColor: "CDE5FF".color),
        dark: Theme(accentColor: "4191F4".color, foregroundColor: "1E3751".color, backgroundColor: "021F37".color))
    
    static private let redThemeData = DefaultThemeData(
        light: Theme(accentColor: "c92a2a".color, foregroundColor: "FFF5F5".color, backgroundColor: "ffe3e3".color),
        dark: Theme(accentColor: "c92a2a".color, foregroundColor: "371E1F".color, backgroundColor: "27080A ".color))
    
    static private let greenThemeData = DefaultThemeData(
        light: Theme(accentColor: "2f9e44".color, foregroundColor: "ebfbee".color, backgroundColor: "d3f9d8".color),
        dark: Theme(accentColor: "2f9e44".color, foregroundColor: "192D1E".color, backgroundColor: "0A1E0F".color)) //"2b8a3e" - background "37b24d" - foreground
    
    static private let yellowThemeData = DefaultThemeData(
        light: Theme(accentColor: "f59f00".color, foregroundColor: "fff9db".color, backgroundColor: "fff3bf".color),
        dark: Theme(accentColor: "f59f00".color, foregroundColor: "2C240B".color, backgroundColor: "231200".color))
    
    static private let violetThemeData = DefaultThemeData(
        light: Theme(accentColor: "5f3dc4".color, foregroundColor: "f3f0ff".color, backgroundColor: "e5dbff".color),
        dark: Theme(accentColor: "7048e8".color, foregroundColor: "291F46".color, backgroundColor: "160E2F".color))
}
