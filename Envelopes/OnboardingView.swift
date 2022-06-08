import SwiftUI


struct ParentOnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var screenNumber = 0
    private let localNotiManager = LocalNotificationManager()

    var body: some View {
        switch screenNumber {
        case 0:
            OnboardingViewOne(buttonAction: nextScreen)
        case 1:
            OnboardingViewTwo(buttonAction: nextScreen)
        case 2:
            OnboardingViewThree(buttonAction: dismissOnboarding)
        default:
            OnboardingViewThree(buttonAction: dismissOnboarding)
        }
    }
    
    func nextScreen() {
        screenNumber += 1
    }
    
    func dismissOnboarding() {
        localNotiManager.requestNotificationAuthorization { success in
            CoreDataManager.shared.setNotificationEnable(success)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct OnboardingViewTwo: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var buttonAction: () -> Void
    
    var body: some View {
        VStack {
            Image("onboarding_envelope_2")
                .resizable()
                .frame(width: 300, height: 300, alignment: .center)
                .padding(.top)
            VStack(alignment: .leading) {
                Text("Rules:")
                    .padding()
                    .font(.system(size: 30, weight: .bold))
                Text("1. You have 100 envelopes with random number from $1 to $100.")
                    .padding()
                    .font(.system(size: 17, weight: .medium))
                Text("2. Open 1 envelope per day and save the written amount of money.")
                    .padding()
                    .font(.system(size: 17, weight: .medium))
                Text("3. By the time you open the last envelope you’ll save $5050!")
                    .padding()
                    .font(.system(size: 17, weight: .medium))
                Spacer()
            }
            Button {
                buttonAction()
            } label: {
                HStack {
                    Spacer()
                    Text("What else?")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 45, alignment: .center)
                        .background(colorThemeViewModel.accentColor(for: colorScheme))
                        .cornerRadius(15)
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

struct OnboardingViewOne: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var buttonAction: () -> Void
    
    var body: some View {
        VStack {
            
            Image("onboarding_envelope_1")
                .resizable()
                .frame(width: 300, height: 300, alignment: .center)
                .padding(.top)
            VStack(alignment: .leading) {
                Text("Hey there!")
                    .padding()
                    .font(.system(size: 30, weight: .bold))
                Text("Would you like to save extra $5,050?")
                    .padding()
                    .font(.system(size: 17, weight: .medium))
                Text("We dare you to take the viral Envelopes Challenge!")
                    .padding()
                    .font(.system(size: 17, weight: .medium))
                Spacer()
            }
            Button {
                buttonAction()
            } label: {
                HStack {
                    Spacer()
                    Text("What are the rules?")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 45, alignment: .center)
                        .background(colorThemeViewModel.accentColor(for: colorScheme))
                        .cornerRadius(15)
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

struct OnboardingViewThree: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var buttonAction: () -> Void
    
    var body: some View {
        VStack {
            Image("onboarding_envelope_3")
                .resizable()
                .frame(width: 300, height: 300, alignment: .center)
                .padding(.top)
            VStack(alignment: .leading) {
                Text("Customize!")
                    .padding()
                    .font(.system(size: 30, weight: .bold))
                Text("Do you feel that this challenge is not for you? Make your own then!")
                    .padding()
                    .font(.system(size: 17, weight: .medium))
                Text("Set up the sum of money and amount of envelopes, that suites you!")
                    .padding()
                    .font(.system(size: 17, weight: .medium))
                Spacer()
            }
            Button {
                buttonAction()
            } label: {
                HStack {
                    Spacer()
                    Text("Let's go!")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 45, alignment: .center)
                        .background(colorThemeViewModel.accentColor(for: colorScheme))
                        .cornerRadius(15)
                        .padding()
                    Spacer()
                }
            }
        }
    }
}
