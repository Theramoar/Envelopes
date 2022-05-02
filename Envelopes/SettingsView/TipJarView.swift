//
//  TipJarView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 22/07/2021.
//

import SwiftUI


struct TipJarView: View {
    @StateObject var viewModel = TipJarViewModel()

    var body: some View {
            Form {
                Section(footer: Text(viewModel.gratitudeString).padding()) {
                    Button(action: {IAPManager.shared.purchase(productWith: IAPProducts.smallTip.rawValue)}, label: {
                        HStack {
                            Text("🤑 Great Tip")
                                .fontWeight(.medium)
                            Spacer()
                            Text(viewModel.smallTipPrice)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                    })
                    Button(action: {IAPManager.shared.purchase(productWith: IAPProducts.mediumTip.rawValue)}, label: {
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
                        IAPManager.shared.purchase(productWith: IAPProducts.largeTip.rawValue)
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
            .themedBackground()
            .navigationTitle("Tip Jar")
    }
}

class TipJarViewModel: ObservableObject {
    
    let gratitudeString = "The app is completely free! But if you like, you can leave a tip. I greatly appreciate your support and try to make this app better!"
    @Published var smallTipPrice = IAPManager.shared.priceStringForProduct(withIdentifier: IAPProducts.smallTip.rawValue)
    @Published var mediumTipPrice = IAPManager.shared.priceStringForProduct(withIdentifier: IAPProducts.mediumTip.rawValue)
    @Published var largeTipPrice = IAPManager.shared.priceStringForProduct(withIdentifier: IAPProducts.largeTip.rawValue)
    
    @Published var gratitudePresented = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(completeTransaction), name: NSNotification.Name(IAPProducts.smallTip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeTransaction), name: NSNotification.Name(IAPProducts.mediumTip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeTransaction), name: NSNotification.Name(IAPProducts.largeTip.rawValue), object: nil)
    }
    
    @objc func completeTransaction() {
        print("Transaction completed")
        NotificationCenter.default.post(name: NSNotification.Name("AlertShouldBePresented"), object: nil)
    }
}
