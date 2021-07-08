//
//  MainMenuView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 08/07/2021.
//

import SwiftUI

struct MainMenuView: View {
    @State private var presentCreateChallengeView = false
    @ObservedObject var userData: UserData
    
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.challenges) { challenge in
                    NavigationLink(
                        destination: ChallengeView(challenge: challenge),
                        label: {
                            Text(challenge.goal)
                        })
                }
                
            }
            .navigationTitle("Envelopes")
            .navigationBarItems(trailing: Button(action: { presentCreateChallengeView = true },
                                                 label: {
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 22))
                                                 }))
            .sheet(isPresented: $presentCreateChallengeView) {
                CreateChallengeView(userData: userData)
            }
        }
        
    }
}
