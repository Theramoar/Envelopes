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
                        ActionButton(title: "Create challenge") {
                            viewModel.saveNewChallenge()
                            presentationMode.wrappedValue.dismiss()
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
        .themedScreenBackground()
        .themedAccent()
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("New challenge")
    }
}
