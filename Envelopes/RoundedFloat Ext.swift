//
//  RoundedFloat Ext.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 19/07/2021.
//

import Foundation

extension Float {
    func roundedUpTwoDecimals() -> Float {
        return (self*100).rounded()/100
    }
}
