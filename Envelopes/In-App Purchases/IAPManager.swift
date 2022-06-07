import Foundation
import StoreKit

enum IAPProducts: String {
    case smallTip = "smallTip"
    case mediumTip = "mediumTip"
    case largeTip = "largeTip"
    case designBundle = "designBundlePurchase"
    case allIn = "allInBundlePurchase"
}

class IAPManager: NSObject  {
    static let shared = IAPManager()
    private override init() {}
    private var products: [SKProduct] = []
    var productRequest: SKProductsRequest?

    
    //Убеждаемся в том, что данное устройство может совершать платежи
    public func setupPurchases(callback: @escaping (Bool) -> ()) {
        if SKPaymentQueue.canMakePayments() {
            //Если устройство может делать покупки, добавляем данный класс как наблюдателя за совершением покупок
            SKPaymentQueue.default().add(self)
            callback(true)
            return
        }
        callback(false)
    }
    
    public func getProducts() {
        let identifiers: Set = [IAPProducts.smallTip.rawValue,
                                IAPProducts.mediumTip.rawValue,
                                IAPProducts.largeTip.rawValue,
                                IAPProducts.designBundle.rawValue,
                                IAPProducts.allIn.rawValue]
        productRequest = SKProductsRequest(productIdentifiers: identifiers)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    public func isProductAvailable(product: IAPProducts) -> Bool {
        products.contains(where: { $0.productIdentifier == product.rawValue })
    }
    
    public func purchase(product: IAPProducts) {
        guard let product = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: product)
        //отправляет платёж в очередь. Далее работает метод func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
        SKPaymentQueue.default().add(payment)
    }

    public func priceStringFor(product: IAPProducts) -> String {
        guard let product = products.first(where: {$0.productIdentifier == product.rawValue }) else { return "--" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale

        return formatter.string(from: product.price) ?? "--"
    }
    
    public func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased: purchased(transaction)
            case .failed: failed(transaction)
            case .restored: restored(transaction)
            case .purchasing: purchasing(transaction)
            case .deferred: defered(transaction)
            @unknown default: break
            }
        }
    }
    
    private func failed(_ transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction Error: \(transactionError.localizedDescription)")
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("failed_\(transaction.payment.productIdentifier)"), object: nil)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    private func purchased(_ transaction: SKPaymentTransaction) {
        NotificationCenter.default.post(name: NSNotification.Name(transaction.payment.productIdentifier), object: nil)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    
    
    private func restored(_ transaction: SKPaymentTransaction) {
        NotificationCenter.default.post(name: NSNotification.Name("restored_\(transaction.payment.productIdentifier)"), object: nil)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func defered(_ transaction: SKPaymentTransaction) {}
    
    private func purchasing(_ transaction: SKPaymentTransaction) {}
}

extension IAPManager: SKProductsRequestDelegate {
    //Обработка ответа посланного func getProducts()
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        products.forEach { print($0.localizedTitle) }
    }
}
