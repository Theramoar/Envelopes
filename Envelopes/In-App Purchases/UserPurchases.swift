import SwiftUI

class UserPurchases {
    private var userDefaults: UserDefaults
    static var shared = UserPurchases()
    
    private var designBundle: Bool {
        didSet {
            userDefaults.set(designBundle, forKey: IAPProducts.designBundle.rawValue)
        }
    }
    private var allIn: Bool {
        didSet {
            UserDefaults.standard.set(allIn, forKey: IAPProducts.allIn.rawValue)
        }
    }
    
    var designBundleEnabled: Bool {
        designBundle || allIn
    }
    var allInEnabled: Bool {
        allIn
    }
    
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        designBundle = userDefaults.bool(forKey: IAPProducts.designBundle.rawValue)
        allIn = userDefaults.bool(forKey: IAPProducts.allIn.rawValue)
        
        let notifications = NotificationCenter.default
        notifications.addObserver(self, selector: #selector(restoreDesignBundle), name: NSNotification.Name("restored_\(IAPProducts.designBundle.rawValue)"), object: nil)
        notifications.addObserver(self, selector: #selector(restoreAllIn), name: NSNotification.Name("restored_\(IAPProducts.allIn.rawValue)"), object: nil)
        
        notifications.addObserver(self, selector: #selector(completeDesignBundle), name: NSNotification.Name(IAPProducts.designBundle.rawValue), object: nil)
        notifications.addObserver(self, selector: #selector(completeAllIn), name: NSNotification.Name(IAPProducts.allIn.rawValue), object: nil)
        
        
    }
    
    @objc private func restoreDesignBundle() {
        designBundle = true
        NotificationCenter.default.post(name: .restoreWasSuccesful, object: nil)
    }
    
    @objc private func restoreAllIn() {
        allIn = true
        NotificationCenter.default.post(name: .restoreWasSuccesful, object: nil)
    }
    
    @objc private func completeDesignBundle() {
        designBundle = true
        NotificationCenter.default.post(name: .purchaseWasSuccesful, object: nil)
    }
    
    @objc private func completeAllIn() {
        allIn = true
        NotificationCenter.default.post(name: .purchaseWasSuccesful, object: nil)
    }
}
                                  
