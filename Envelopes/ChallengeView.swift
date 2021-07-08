//
//  ContentView.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 09/06/2021.
//

import SwiftUI
import CoreData

struct ChallengeView: View {
    let challenge: Challenge
    
    let gridEdgePadding: CGFloat = 10
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ProgressStackView(challenge: challenge)
                    .padding(gridEdgePadding)
                Text("Days:")
                ScrollView(.vertical) {
                    
                    let side = cellSide(with: geo.size.width)
                    let spacing = gridSpacing(with: geo.size.width, cellSide: side)
                    
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(challenge.envelopes, id: \.self) { item in
                            let rounded = String(item.roundedUpTwoDecimals())
                            
                            Text(rounded)
                                .onTapGesture {
                                    addSumToTotal(sum: item)
                                }
                        }
                        .padding(10)
                        .frame(width: side, height: side, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(gridEdgePadding)
                }
            }
            .background(Color.white)
        }
        .navigationTitle(challenge.goal)
    }
    
    private func gridSpacing(with screenWidth: CGFloat, cellSide: CGFloat) -> CGFloat {
        let totalCellWidth: CGFloat = 4 * cellSide
        let spacing = (screenWidth - totalCellWidth) / 5
        return spacing
    }
    
    private func cellSide(with screenWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = 5 * gridEdgePadding
        let side = (screenWidth - spacing) / 4
        return side
    }
    
    func addSumToTotal(sum: Float) {
        challenge.savedSum += sum
    }
}


extension Float {
    func roundedUpTwoDecimals() -> Float {
        return (self*100).rounded()/100
    }
}
