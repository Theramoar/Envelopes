import SwiftUI

struct PresentationView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let slideInfos: [PresentationSlideInfo]
    let buttonTitles: [String]
    @State var screenNumber = 0
    var finishAction: () -> Void
    
    var body: some View {
        VStack {
            TabView(selection: $screenNumber) {
                ForEach(slideInfos.indices, id: \.self) { index in
                    PresentationSlideView(info: slideInfos[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .padding(.horizontal)
            .background(colorThemeViewModel.backgroundColor(for: colorScheme))
            
            ActionButton(title: buttonTitles[screenNumber], tapAction: nextScreen)
                .padding(.bottom)
        }
        .themedScreenBackground()
    }
    
    func nextScreen() {
        if screenNumber < slideInfos.count - 1 {
            withAnimation {
                screenNumber += 1
            }
        } else {
            finishAction()
        }
    }
}
