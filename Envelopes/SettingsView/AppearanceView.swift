//
//  AppearanceView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 06/02/2022.
//

import SwiftUI

struct AppearanceView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    let viewModel: AppearanceViewModel
    @State private var presentDummyAlert = false
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                ThemePreviewView(viewModel: ThemePreviewViewModel(colorScheme: colorScheme))
                    .padding()
                VStack {
                    ColorPickerView(tapAction: viewModel.processNewTheme)
                    Divider()
                    Button {
                        withAnimation{
                            presentDummyAlert = true
                        }
                    } label: {
                        HStack {
                            Text("Create Theme")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.primary)
                        .font(.system(size: 15, weight: .medium)).padding(5)
                    }
                    
                    //                NavigationLink(destination: CreateThemeView(accentColor: .blue, backgroundColor: .red, foregroundColor: .yellow)) {
                    //                    HStack {
                    //                        Text("Create Theme")
                    //                        Spacer()
                    //                        Image(systemName: "chevron.right")
                    //                    }
                    //                    .foregroundColor(.primary)
                    //                    .font(.system(size: 15, weight: .medium)).padding(5)
                    //                }
                    Divider()
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Appearance")
            .themedBackground()
            .blur(radius: presentDummyAlert ? 10 : 0)
            if presentDummyAlert {
                AlertView(alertType: .infoAlert("This feature will be available in the next update!"), appColor: colorThemeViewModel.backgroundColor(for: colorScheme))
                    .onTapGesture(perform: cancelAlert)
                    .ignoresSafeArea()
            }
        }
    }
    
    func cancelAlert() {
        withAnimation{
            presentDummyAlert = false
        }
    }
}


class AppearanceViewModel {
    var processNewTheme: (ThemeSet) -> ()
    
    init(newThemeHandler: @escaping (ThemeSet) -> ()) {
        processNewTheme = newThemeHandler
    }
}

struct ThemePreviewView: View {
    @StateObject var viewModel: ThemePreviewViewModel
    
    var body: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTheme.animation(), content: {
                ForEach(0 ..< viewModel.themes.count) {
                    Text("\(viewModel.themes[$0])")
                }
                
            })
                .pickerStyle(.segmented)
            ChallengeView(viewModel: ChallengeViewModel(), currentAlertType: .infoAlert("Yeah"))
                .frame(height: 350)
                .cornerRadius(10)
                .shadow(radius: 10)
                .disabled(true)
                .environment(\.colorScheme, viewModel.selectedTheme == 0 ? .light : .dark)
        }
    }
}


class ThemePreviewViewModel: ObservableObject {
    @Published var themes: [String] = ["Light", "Dark"]
    @Published var selectedTheme: Int
    
    init(colorScheme: ColorScheme) {
        selectedTheme = colorScheme == .light ? 0 : 1
        
    }
}
