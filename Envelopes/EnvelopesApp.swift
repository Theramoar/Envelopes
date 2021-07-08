//
//  EnvelopesApp.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 09/06/2021.
//

import SwiftUI

@main
struct EnvelopesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainMenuView(userData: createUserData())
        }
    }
    
    private func createUserData() -> UserData {
        let data = UserData()
        let challenge = Challenge(goal: "New Car", days: 50, sum: 5000)
        data.challenges.append(challenge)
        return data
    }
}
