import SwiftUI

struct EnvelopeView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var envelope: Envelope
    var envelopeStatus: EnvelopeStatus
    var dayText: String
    
    var processEnvelope: (Envelope) -> Void
    
    var body: some View {
        VStack {
            let imageName = envelope.isOpened ? "envelope.open" : "envelope"
            Image(systemName: imageName)
                .font(.system(size: 50, weight: .ultraLight))
                .foregroundColor(colorThemeViewModel.color(for: envelopeStatus, colorScheme))
            Text(dayText)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .onTapGesture {
            processEnvelope(envelope)
        }
    }
}
