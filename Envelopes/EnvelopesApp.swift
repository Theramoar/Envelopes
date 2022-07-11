import SwiftUI

@main
struct EnvelopesApp: App {
    @StateObject var themeViewModel: ColorThemeViewModel = ColorThemeViewModel()
    @StateObject var viewModel: EnvelopesAppViewModel = EnvelopesAppViewModel()

    var body: some Scene {
        WindowGroup {
            ChallengeView(viewModel: viewModel.viewModelForChallengeView())
                .environmentObject(themeViewModel)
        }
    }
}
