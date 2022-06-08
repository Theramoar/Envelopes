import SwiftUI

enum AlertType {
    case actionAlert(message: String, cancelTitle: String, cancelAction: () -> Void, successTitle: String, successAction: () -> Void)
    case infoAlert(String)
}

struct AlertView: View {
    @State var alertType: AlertType
    let appColor: Color
    
    var alertMessage: String {
        switch alertType {
        case .actionAlert(let message, _ , _ , _ , _):
            return message
        case .infoAlert(let message):
            return message
        }
    }
    
    var body: some View {
        ZStack {
            appColor.opacity(0.5)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Text(alertMessage)
                    .font(.system(size: 45, weight: .heavy, design: .default))
                    .multilineTextAlignment(.center)
                    .padding()
                switch alertType {
                case .actionAlert(_, let cancelTitle, let cancelAction, let successTitle, let successAction):
                    EmptyView()
                    HStack {
                        Button {
                            cancelAction()
                        } label: {
                            Text(cancelTitle)
                                .foregroundColor(Color.white)
                                .frame(width: 100, height: 50, alignment: .center)
                                .background(appColor)
                                .cornerRadius(30)
                                .font(.system(size: 15, weight: .bold, design: .default))
                                .shadow(radius: 5, x: 2, y: 2)
                                .padding()
                        }
                        Button {
                            successAction()
                        } label: {
                            Text(successTitle)
                                .foregroundColor(Color.white)
                                .frame(width: 100, height: 50, alignment: .center)
                                .background(appColor)
                                .cornerRadius(30)
                                .font(.system(size: 15, weight: .bold, design: .default))
                                .shadow(radius: 5, x: 2, y: 2)
                                .padding()
                        }
                    }
                case .infoAlert(_):
                    EmptyView()
                }
            }
        }
    }
}
