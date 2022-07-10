import SwiftUI

struct PresentationSlideInfo {
    var imageName: String
    var title: String
    var descriptions: [String]
}

struct PresentationSlideView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let info: PresentationSlideInfo
    
    var body: some View {
        VStack {
            Image(info.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding(.top)
                .frame(minWidth: 150, maxWidth: 300, minHeight: 150, maxHeight: 300, alignment: .center)
            VStack(alignment: .leading) {
                Text(info.title)
                    .padding(5)
                    .font(.system(size: 25, weight: .bold))
                ForEach(info.descriptions, id: \.self) { description in
                    Text(description)
                        .padding(5)
                        .font(.system(size: 15, weight: .medium))
                        .minimumScaleFactor(0.5)
                }
            }
            Spacer()
        }
    }
}
