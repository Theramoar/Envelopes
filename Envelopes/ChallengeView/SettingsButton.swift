import SwiftUI

struct SettingsButton: View {
    @State private var presentMenuView = false
    var tapAction: () -> Void
    var backgroundColor: Color
    var body: some View {
        Button(action: tapAction, label: {
            Image(systemName: "gear")
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .cornerRadius(30)
                .padding()
                .foregroundColor(Color.white)
                .font(.system(size: 20))
        })
    }
}
