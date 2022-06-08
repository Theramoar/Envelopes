import SwiftUI

struct ActionButton: View {    
    var title: String
    var tapAction: () -> Void
    
    var body: some View {
        Button(action: tapAction) {
            ActionButtonLabel(title: title)
        }
    }
}

struct ActionButtonLabel: View {
    var title: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.white)
                .frame(width: 300, height: 45, alignment: .center)
                .themedActionButtonBackground()
                .cornerRadius(15)
                .padding()
            Spacer()
        }
    }
}
