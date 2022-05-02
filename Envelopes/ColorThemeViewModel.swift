import SwiftUI

class ColorThemeViewModel: ObservableObject {
    enum ViewModelType: String {
        case regular = "ThemeWasUpdated"
        case newChallenge = "NewChallengeThemeWasUpdated"
    }
    private let type: ViewModelType
    private let coreData: CoreDataManager = .shared
    private let notificationCenter: NotificationCenter = .default
    
    var defaultThemes: [ThemeSet] = []
    var userThemes: [ThemeSet] = []
    @Published var currentThemeSet: ThemeSet!
    
    init(type: ViewModelType = .regular, themeSetIndex: Int = 0) {
        self.type = type
        
        setDefaultThemes()
        
        currentThemeSet = coreData.activeChallenge?.appTheme ?? defaultThemes[themeSetIndex]//defaultThemes.first!
        //Need to pass current theme with notification
        notificationCenter.addObserver(self, selector: #selector(updateCurrentTheme), name: NSNotification.Name(type.rawValue), object: nil)
    }
    
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        currentThemeSet.theme(for: colorScheme).backgroundColor
    }
    
    func foregroundColor(for colorScheme: ColorScheme) -> Color {
        currentThemeSet.theme(for: colorScheme).foregroundColor
    }
    
    func accentColor(for colorScheme: ColorScheme) -> Color {
        currentThemeSet.theme(for: colorScheme).accentColor
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
    
    func setDefaultThemes() {
        let themes = coreData.loadDataFromContainer(ofType: ThemeSet.self)
        userThemes = themes.filter({ !$0.isDefault })
        
        let defaultThemes = themes.filter({ $0.isDefault })
        if !defaultThemes.isEmpty {
            self.defaultThemes = defaultThemes
        } else {
            DefaultThemeData.sets.forEach {
                coreData.saveTheme(darkTheme: $0.dark, lightTheme: $0.light, isDefault: true)
            }
            setDefaultThemes()
        }
    }
    
    func isCurrent(_ theme: ThemeSet) -> Bool {
        currentThemeSet == theme
    }
    
    @objc private func updateCurrentTheme(notification: NSNotification) {
        #warning("Fixed bug. App is not crashing if you delete active challenge. However find the way for better implementation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let themeSet = notification.userInfo?["themeSet"] as? ThemeSet ?? self.coreData.activeChallenge?.appTheme ?? self.defaultThemes.first!
            withAnimation {
                self.currentThemeSet = themeSet
            }
        }
        
    }
    
    
    private struct DefaultThemeData {
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
        
        //Done
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
}
