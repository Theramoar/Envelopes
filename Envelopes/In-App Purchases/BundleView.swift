import SwiftUI

struct BundleView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: BundleViewModel
    
    init(ofType type: BundleViewModel.ViewType) {
        viewModel = BundleViewModel(type: type)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                viewModel.image
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                    .padding(.vertical)
                VStack(alignment: .leading) {
                    Text(viewModel.bundleDescription)
                        .font(.system(size: 17, weight: .bold))
                    
                    
                    ForEach(viewModel.features, id: \.self) { feature in
                        HStack {
                            Text("-")
                                .font(.system(size: 15, weight: .medium))
                            Text(feature)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .padding(.vertical, 5)
                        
                    }
                }
                .padding(.horizontal, 10)
                
                ActionButton(title: viewModel.buyButtonTitle,
                             tapAction: viewModel.initiatePurchase)
                .disabled(!viewModel.isProductAvailable)
                .opacity(viewModel.isProductAvailable ? 1 : 0.5)
                
                if viewModel.showAllInNavigation {
                    NavigationLink(destination: BundleView(ofType: .allInBundle)) {
                        Text("This bundle is included in \"Savelope All-in\"")
                            .foregroundColor(colorThemeViewModel.accentColor(for: colorScheme))
                            .fontWeight(.medium)
                    }
                }
            }
            if viewModel.showActivityIndicator {
                ActivityIndicatorView()
            }
        }
        .themedScreenBackground()
        .navigationTitle(viewModel.title)
    }
}

class BundleViewModel: ObservableObject {
    @Published var showActivityIndicator: Bool = false
    
    let bundleDescription: String
    let features: [String]
    let image: Image
    let designBundlePrice: String
    let title: String
    let showAllInNavigation: Bool
    let isProductAvailable: Bool
    let buyButtonTitle: String
    private let product: IAPProducts
    
    init(type: ViewType) {
        bundleDescription = type.description
        features = type.features
        image = Image(type.imageName)
        designBundlePrice = IAPManager.shared.priceStringFor(product: type.product)
        title = type.title
        showAllInNavigation = type != .allInBundle
        product = type.product
        isProductAvailable = IAPManager.shared.isProductAvailable(product: type.product)
        buyButtonTitle = isProductAvailable ? "Buy for \(designBundlePrice)" : "Product is unavailable right now"
        NotificationCenter.default.addObserver(self, selector: #selector(hideActivityIndicator), name: NSNotification.Name("failed_\(type.product.rawValue)"), object: nil)
    }
    
    func initiatePurchase() {
        withAnimation {
            showActivityIndicator = true
        }
        
        purchaseProduct()
    }
    
    @objc private func hideActivityIndicator() {
        withAnimation {
            showActivityIndicator = false
        }
        
    }
    
    private func purchaseProduct() {
        IAPManager.shared.purchase(product: product)
    }
    
    enum ViewType {
        case designBundle
        case allInBundle
        
        var imageName: String {
            switch self {
            case .designBundle:
                return "pencils"
            case .allInBundle:
                return "success"
            }
        }
        
        var title: String {
            switch self {
            case .designBundle:
                return "Design Bundle"
            case .allInBundle:
                return "Savelope All-in"
            }
        }
        
        var features: [String] {
            switch self {
            case .designBundle:
                return ["Color your challenges as you wish with custom themes!", "All future design-related features will be included!"]
            case .allInBundle:
                return ["Get all features forever with one purchase!", "All future features will be included!", "This is a lifetime pass! No future payments!"]
            }
        }
        
        var description: String {
            switch self {
            case .designBundle:
                return "All design-related features are in this bundle:"
            case .allInBundle:
                return "Purchase all bundles at once with Savelope All-in!"
            }
        }
        
        var product: IAPProducts {
            switch self {
            case .designBundle:
                return .designBundle
            case .allInBundle:
                return .allIn
            }
        }
    }
}

struct ActivityIndicatorView: View {
    @EnvironmentObject var colorThemeViewModel: ColorThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            colorThemeViewModel.backgroundColor(for: colorScheme)
                .opacity(0.8)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: colorThemeViewModel.accentColor(for: colorScheme)))
                .scaleEffect(2)
        }
    }
}
