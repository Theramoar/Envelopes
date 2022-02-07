//
//  AppearanceView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 06/02/2022.
//

import SwiftUI

struct AppearanceView: View {
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        VStack {
            ThemePreviewView(viewModel: ThemePreviewViewModel(colorScheme: colorScheme))
            VStack {
                ColorPickerView(currentColor: .blue, tapAction: {_ in })
                Divider()
                NavigationLink(destination: CreateThemeView(accentColor: .blue, backgroundColor: .red, foregroundColor: .yellow)) {
                    HStack {
                        Text("Create Theme")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.foregroundColor(.primary)
                }
                Divider()
            }
        }
        .padding()
        .navigationBarTitle("Appearance")
    }
}

struct ThemePreviewView: View {
    @StateObject var viewModel: ThemePreviewViewModel
    
    var body: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTheme, content: {
                ForEach(0 ..< viewModel.themes.count) {
                    Text("\(viewModel.themes[$0])")
                }
                
            })
                .pickerStyle(.segmented)
            ChallengeView(viewModel: ChallengeViewModel(colorScheme: viewModel.colorScheme), currentAlertType: .infoAlert("Yeah"))
                .frame(height: 350)
                .cornerRadius(10)
                .disabled(true)
                .environment(\.colorScheme, viewModel.selectedTheme == 0 ? .light : .dark)
        }
    }
}


class ThemePreviewViewModel: ObservableObject {
    var colorScheme: ColorScheme
    @Published var themes: [String] = ["Light", "Dark"]
    @Published var selectedTheme: Int
    
    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        selectedTheme = colorScheme == .light ? 0 : 1
        
    }
}

struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}
