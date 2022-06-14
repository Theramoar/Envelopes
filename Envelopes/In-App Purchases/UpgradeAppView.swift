import SwiftUI

struct UpgradeAppView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = UpgradeViewModel()
    
    var body: some View {
        Form {
            if !viewModel.allInEnabled {
                    Section(header: Text("Bundles"), footer:
                                FooterButton(title: "Restore purchases",
                                             tapAction: viewModel.restoreCompletedTransactions,
                                             foregroundColor: colorThemeViewModel.accentColor(for: colorScheme),
                                             isPresented: !viewModel.allInEnabled)
                    ) {
                        if !viewModel.designBundleEnabled {
                            NavigationLink(destination: BundleView(ofType: .designBundle),
                                           isActive: $viewModel.navigateToDesignBundleView,
                                           label: { Text("🎨 Design Bundle").fontWeight(.medium) })
                        }
                        NavigationLink(destination: BundleView(ofType: .allInBundle),
                                       isActive: $viewModel.navigateToAllInBundleView,
                                       label: { Text("🚀 Savelope All-in").fontWeight(.bold) })
                    }
                    .themedList()
            } else {
                VStack {
                    Image("happy_envelope")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("Thank you for your purchase! Enjoy the app!")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .listRowInsets(EdgeInsets())
                .padding(.vertical)
                .background(colorThemeViewModel.backgroundColor(for: colorScheme))
                
            }
        }
        .themedScreenBackground()
        .navigationTitle("Upgrade App")
    }
}

class UpgradeViewModel: ObservableObject {
    private var iapManager: IAPManager
    private var userPurchases: UserPurchases = .shared
    
    @Published var navigateToDesignBundleView = false
    @Published var navigateToAllInBundleView = false
    @Published var showActivityIndicator = true
    
    @Published var designBundleEnabled: Bool
    @Published var allInEnabled: Bool
    
    init(iap: IAPManager = .shared) {
        iapManager = iap
        
        designBundleEnabled = userPurchases.designBundleEnabled
        allInEnabled = userPurchases.allInEnabled
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissBundleViews), name: .purchaseWasSuccesful, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePublishers), name: .restoreWasSuccesful, object: nil)
    }
    
    func restoreCompletedTransactions() {
        iapManager.restoreCompletedTransactions()
    }
    
    @objc private func dismissBundleViews() {
        navigateToDesignBundleView = false
        navigateToAllInBundleView = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updatePublishers()
        }
        
    }
    
    @objc private func updatePublishers() {
        withAnimation {
            designBundleEnabled = userPurchases.designBundleEnabled
            allInEnabled = userPurchases.allInEnabled
        }
    }
}

struct FooterButton: View {
    var title: String
    var tapAction: () -> Void
    var foregroundColor: Color
    var isPresented: Bool = true
    
    
    var body: some View {
        if isPresented {
            HStack {
                Spacer()
                Button(title, action: tapAction)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(foregroundColor)
                    .padding(5)
                Spacer()
            }
        }
    }
}
