import SwiftUI

struct AboutDevView: View {    
    var body: some View {
            Form {
                Section {
                HStack {
                    Image("Developer")
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                    Text("Hello! My name is Misha.\nI am iOS developer from Riga. I'm always open to new ideas!\nYou can reach me on social media:")
                }
                .padding(.vertical)
                }
                .themedList()
                Section {
                HStack {
                    Image("twitter")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                    Link("Find me on Twitter", destination: URL(string:"https://twitter.com/theramoar")!)
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }
                HStack {
                    Image("instagram")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .font(.system(size: 20, weight: .thin))
                    Link("Find me on Instagram", destination: URL(string:"https://www.instagram.com/misha.kuzz")!)
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }
                }
                .themedList()
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("About the Developer")
            .themedScreenBackground()
    }
}



