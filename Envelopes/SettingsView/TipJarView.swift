//
//  TipJarView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 22/07/2021.
//

import SwiftUI

struct TipJarView: View {
    let gratitudeString = "The app is completely free! But if you like, you can leave a tip. I greatly appreciate your support and try to make this app better!"
    
    var body: some View {
        Form {
            Section(footer: Text(gratitudeString).padding()) {
                HStack {
                    Text("Small Tip")
                    Spacer()
                    Text("$1,09")
                }
                HStack {
                    Text("Medium Tip")
                    Spacer()
                    Text("$4,09")
                }
                HStack {
                    Text("Small Tip")
                    Spacer()
                    Text("$7,09")
                }
            }
        }
        .navigationTitle("Tip Jar")
    }
}
