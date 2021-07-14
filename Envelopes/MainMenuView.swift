//
//  MainMenuView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 08/07/2021.
//

import SwiftUI

enum ChallengeColors {
    case blue
    case yellow
    case red
}


class MenuViewModel: ObservableObject {
    
}


struct MainMenuView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Challenge.entity(), sortDescriptors: []) var challenges: FetchedResults<Challenge>
    
    
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        NavigationView {
            Form {
                if let challenge = challenges.first { $0.isActive } {
                Section(header: Text("Active challenge")) {
                     Text(challenge.goal!)
                    VStack(alignment: .leading) {
                    Text("Accent Color:")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            Color.blue
                                .cornerRadius(30)
                                .frame(width: 40, height: 40, alignment: .center)
                            Color.red
                                .cornerRadius(30)
                                .frame(width: 40, height: 40, alignment: .center)
                            Color.yellow
                                .cornerRadius(30)
                                .frame(width: 40, height: 40, alignment: .center)
                            Color.green
                                .cornerRadius(30)
                                .frame(width: 40, height: 40, alignment: .center)
                            Color.purple
                                .cornerRadius(30)
                                .frame(width: 40, height: 40, alignment: .center)
                            Color.orange
                                .cornerRadius(30)
                                .frame(width: 40, height: 40, alignment: .center)
                            Color.pink
                                .cornerRadius(30)
                                .frame(width: 40, height: 40, alignment: .center)
                        }
                    }
                    }
                }
                }
                Section(header: Text("Your challenges")) {
                    ForEach(challenges.indices, id: \.self) { index in
                        HStack {
                            Text(challenges[index].goal!)
                            Spacer()
                            if challenges[index].isActive {
                                Text("ACTIVE")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 9, weight: .medium))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            challenges.forEach { $0.isActive = false }
                            challenges[index].isActive = true
                            print(challenges[index].isActive)
                            try? self.moc.save()
                        }
                    }
                    
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            moc.delete(challenges[index])
                        }
                        try? self.moc.save()
                    })
                    ZStack {
                        Text("Create new challenge")
                            .foregroundColor(.blue)
                        NavigationLink(
                            destination: CreateChallengeView(viewModel: CreateChallengeViewModel())) { EmptyView() }
                    }
                }
            }
            .navigationTitle("Settings")
        }
        
    }
}
