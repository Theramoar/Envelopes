import SwiftUI

struct TipJarView: View {
    @StateObject var viewModel = TipJarViewModel()

    var body: some View {
            Form {
                Section(footer: Text(viewModel.gratitudeString).padding()) {
                    Button(action: {IAPManager.shared.purchase(product: .smallTip)}, label: {
                        HStack {
                            Text("🤑 Great Tip")
                                .fontWeight(.medium)
                            Spacer()
                            Text(viewModel.smallTipPrice)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                    })
                    Button(action: {IAPManager.shared.purchase(product: .mediumTip)}, label: {
                        HStack {
                            Text("😱 Amazing Tip")
                                .fontWeight(.medium)
                            Spacer()
                            Text(viewModel.mediumTipPrice)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                    })
                    Button(action: {
                        IAPManager.shared.purchase(product: .largeTip)
                    }, label: {
                        HStack {
                            Text("🤯 Generous Tip")
                                .fontWeight(.medium)
                            Spacer()
                            Text(viewModel.largeTipPrice)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                    })
                }
                .themedList()
            }
            .themedScreenBackground()
            .navigationTitle("Tip Jar")
    }
}

class TipJarViewModel: ObservableObject {
    
    let gratitudeString = "If you like, you can leave a tip. I greatly appreciate your support and try to make this app better!"
    @Published var smallTipPrice = IAPManager.shared.priceStringFor(product: .smallTip)
    @Published var mediumTipPrice = IAPManager.shared.priceStringFor(product: .mediumTip)
    @Published var largeTipPrice = IAPManager.shared.priceStringFor(product: .largeTip)
    
    @Published var gratitudePresented = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(completeTransaction), name: NSNotification.Name(IAPProducts.smallTip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeTransaction), name: NSNotification.Name(IAPProducts.mediumTip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeTransaction), name: NSNotification.Name(IAPProducts.largeTip.rawValue), object: nil)
    }
    
    @objc func completeTransaction() {
        print("Transaction completed")
        NotificationCenter.default.post(name: .purchaseWasSuccesful, object: nil)
    }
}
