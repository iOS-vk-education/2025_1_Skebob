//
//  LeaderboardScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 23.12.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct LeaderboardUser: Identifiable, Equatable {
    let id = UUID()
    let uid: String
    let displayName: String
    let balance: Double
    let portfolioValue: Double
    let totalValue: Double
    
    var rank: Int = 0
    
    var profitColor: Color {
        portfolioValue >= 0 ? .green : .red
    }
}


struct LeaderboardScreenView: View {
    @State private var leaderboard: [LeaderboardUser] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            if isLoading {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.5, blue: 0.0)))
//                    .scaleEffect(1.5)
                emptyState
            } else if leaderboard.isEmpty {
                emptyState
            } else {
                emptyState
            }

            if let errorMessage = errorMessage {
                VStack {
                    Spacer()
                    ErrorMessageView(message: errorMessage)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.gray.opacity(0.5))
            
            Text("Рейтинг пока пуст")
                .font(.title2)
                .foregroundColor(.white)
                .fontWeight(.medium)
            
            Text("Совершите первую сделку, чтобы попасть в топ")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
// MARK: - Preview

struct LeaderboardScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardScreenView()
    }
}
