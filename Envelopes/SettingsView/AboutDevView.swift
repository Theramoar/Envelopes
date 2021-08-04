//
//  AboutDevView.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 15/07/2021.
//

import SwiftUI

struct AboutDevView: View {
    var body: some View {
        VStack {
            Form {
                Section {
                HStack {
                    Image("Developer")
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                    Text("Hello! My name is Misha.\nI am the iOS developer from Riga.")
                }
                }
                Section {
                HStack {
                    Image("twitter")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                    Link("Find me on Twitter", destination: URL(string:"https://twitter.com/theramoar")!)
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }
                HStack {
                    Image("instagram")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .font(.system(size: 20, weight: .thin))
                    Link("Find me on Instagram", destination: URL(string:"https://www.instagram.com/misha.kuzz")!)
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }
                }
            }
            .navigationTitle("About the Developer")
        }
    }
}
