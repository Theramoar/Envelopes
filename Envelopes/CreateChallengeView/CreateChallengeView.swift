//
//  CreateChallengeView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 13/06/2021.
//

import SwiftUI

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CreateChallengeViewModel
    
    var body: some View {
            Form {
                Section {
                    TextField("Enter challenge name", text: $viewModel.goalString)
                    TextField("Enter total sum", text: $viewModel.totalSumString)
                        .keyboardType(.decimalPad)
                    
                    Group {
                        Toggle(isOn: $viewModel.notificationsEnabled.animation()) {
                            Text("Allow daily notifications")
                                .fontWeight(.medium)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: viewModel.currentColor.rawValue)))
                        .onChange(of: viewModel.notificationsEnabled, perform: { enabled in
                            if enabled {
                                if !UserSettings.shared.remindersEnabled {
                                    NotificationManager.requestNotificationAuthorization { success in
                                        //Wait for 0.5 seconds to finish the animation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            viewModel.notificationsEnabled = success
                                        }
                                    }
                                }
                            }
                        })
                        if viewModel.notificationsEnabled {
                            HStack {
                                Text("Notification time")
                                    .fontWeight(.medium)
                                DatePicker("Notification time", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                            }
                        }
                    }
                    ColorPickerView(currentColor: viewModel.currentColor, tapAction: viewModel.saveCurrentColor)
                }
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
                                        .background(Color(hex: viewModel.currentColor.rawValue))
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
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: viewModel.currentColor.rawValue)))
                    
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
            }
            .onTapGesture {
                hideKeyboard()
            }
        .navigationTitle("New challenge")
    }
}
