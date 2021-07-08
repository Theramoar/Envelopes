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
