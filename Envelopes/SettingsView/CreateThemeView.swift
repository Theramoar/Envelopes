import SwiftUI

struct CreateThemeView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var accentColor: Color
    @State var backgroundColor: Color
    @State var foregroundColor: Color
    
    @State var themes = ["Light", "Dark"]
    @State var selectedTheme = 0
    
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ThemePreviewView(viewModel: ThemePreviewViewModel(colorScheme: colorScheme))
                .padding()
            
            VStack {
                ColorPicker("Accent Color", selection: $accentColor, supportsOpacity: false)
                .font(.system(size: 15, weight: .medium)).padding(5)
                
                Divider()
                
                ColorPicker("Background Color", selection: $backgroundColor, supportsOpacity: false)
                .font(.system(size: 15, weight: .medium)).padding(5)
                
                Divider()
                
                ColorPicker("Foreground Color", selection: $foregroundColor, supportsOpacity: false)
                .font(.system(size: 15, weight: .medium)).padding(5)
                
                Button {
                    print("SAVED")
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

struct CreateThemeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateThemeView(accentColor: .blue, backgroundColor: .blue, foregroundColor: .blue)
    }
}
