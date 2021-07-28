//
//  HideKeyboard Ext.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 13/06/2021.
//

import SwiftUI


#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


import Combine

//extension Publishers {
//    // 1.
//    static var keyboardAppeared: AnyPublisher<Bool, Never> {
//        // 2.
//        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
//        return willShow
////        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
//        
////        // 3.
////        return MergeMany(willShow, willHide)
////            .eraseToAnyPublisher()
//    }
//}
