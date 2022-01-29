import Foundation

extension Float {
    func roundedUpTwoDecimals() -> Float {
        return (self*100).rounded()/100
    }
}
