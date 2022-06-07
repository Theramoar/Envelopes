import SwiftUI

struct NoChallengesView: View {    
    var tapAction: () -> Void
    var body: some View {
        VStack {
            Image("sad_envelope")
                .resizable()
                .frame(width: 150, height: 150)
            Text("You don't have any active challenges")
                .font(.system(size: 20, weight: .medium))
                .padding()
            Button(action: tapAction, label: {
                Text("Create new challenge")
                    .themedForeground()
            })
            .font(.system(size: 20, weight: .medium))
        }
    }
}
