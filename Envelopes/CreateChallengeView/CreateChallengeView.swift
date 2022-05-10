//
//  CreateChallengeView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 13/06/2021.
//

import SwiftUI

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: CreateChallengeViewModel
    
    var body: some View {
        Form {
            Section {
                TextField("Enter challenge name", text: $viewModel.goalString)
                TextField("Enter total sum", text: $viewModel.totalSumString)
                    .keyboardType(.decimalPad)
                TimePickerView(viewModel: viewModel.viewModelForTimePicker())
                ColorThemePickerView(type: .defaultThemes, tapAction: viewModel.setup(themeSet:))
            }
            .themedList()
            Section(footer:
                        Button {
                viewModel.saveNewChallenge()
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Create challenge")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 45, alignment: .center)
                        .background(colorThemeViewModel.accentColor(for: colorScheme))
                        .cornerRadius(15)
                        .padding()
                    Spacer()
                }
            }
            ) {
                TextField("Days of challenge", text: $viewModel.daysString)
                    .disabled(viewModel.deadlineEnabled)
                    .keyboardType(.numberPad)
                Toggle(isOn: $viewModel.deadlineEnabled.animation()) {
                    Text("Set challenge deadline")
                        .fontWeight(.medium)
                }
                .toggleStyle(SwitchToggleStyle(tint: colorThemeViewModel.accentColor(for: colorScheme)))
                
                if viewModel.deadlineEnabled {
                    DatePicker("Deadline", selection: $viewModel.date, in: viewModel.dateRange, displayedComponents: [.date])
                        .onChange(of: viewModel.date, perform: { value in
                            let calendar = Calendar.current
                            let endComponents = calendar.dateComponents([.day], from: Date(), to: value)
                            let formatter = DateComponentsFormatter()
                            let days = formatter.string(from: endComponents)
                            if let days = days {
                                viewModel.daysString = String(days.dropLast()) + " days"
                            }
                        })
                }
            }
            .themedList()
        }
        .themedBackground()
        .accentColor(colorThemeViewModel.accentColor(for: colorScheme))
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("New challenge")
    }
}
