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
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        let uid = document.documentID
        let balance = data["balance"] as? Double ?? 0.0
        let portfolioValue = data["portfolioValue"] as? Double ?? 0.0
        
        self.uid = uid
        self.displayName = data["displayName"] as? String ?? "Пользователь"
        self.balance = balance
        self.portfolioValue = portfolioValue
        self.totalValue = data["totalValue"] as? Double ?? (balance + portfolioValue)
    }
}

struct LeaderboardScreenView: View {
    @State private var leaderboard: [LeaderboardUser] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var currentUserUID: String?
    
    private let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            Color(hex: "161514").ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if leaderboard.isEmpty {
                emptyState
            } else {
                leaderboardList
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
        .onAppear {
            loadLeaderboard()
            syncCurrentUserWithLeaderboard()
        }
        .refreshable {
            loadLeaderboard()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.5, blue: 0.0)))
                .scaleEffect(1.5)
            
            Text("Загрузка рейтинга...")
                .foregroundColor(.gray)
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
    
    private var leaderboardList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Заголовки таблицы
                headerRow
                
                // Список пользователей
                ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, user in
                    LeaderboardRow(user: user, rank: index + 1, isCurrentUser: user.uid == currentUserUID)
                    
                    if index < leaderboard.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                            .padding(.leading, 40) // ✅ Фикс: отступ после колонки с рангом
                    }
                }
            }
            .padding(.top, 80)
            .padding(.vertical, 8)
        }
    }
    
    private var headerRow: some View {
        HStack(spacing: 10) {
            Text("#")
                .frame(width: 40, alignment: .leading)
                .foregroundColor(.gray)
                .font(.caption)
            
            Text("Пользователь")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.gray)
                .font(.caption)
            
            Text("Баланс")
                .frame(width: 100, alignment: .trailing)
                .foregroundColor(.gray)
                .font(.caption)
            
            Text("Портфель")
                .frame(width: 100, alignment: .trailing)
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
    }
    
    // MARK: - Data Loading
    
    private func loadLeaderboard() {
        isLoading = true
        currentUserUID = Auth.auth().currentUser?.uid
        
        db.collection("publicLeaderboard")
            .order(by: "totalValue", descending: true)
            .getDocuments { [self] snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.errorMessage = "Нет данных"
                        return
                    }
                    
                    var users = documents.compactMap { LeaderboardUser(document: $0) }
                    users.sort { $0.totalValue > $1.totalValue }
                    
                    for (index, _) in users.enumerated() {
                        users[index].rank = index + 1
                    }
                    
                    self.leaderboard = users
                }
            }
    }
    
    private func syncCurrentUserWithLeaderboard() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, _ in
            if let data = snapshot?.data(),
               let balance = data["balance"] as? Double,
               let portfolio = data["portfolio"] as? [String: Any] {
            }
        }
    }
}

// MARK: - LeaderboardRow

struct LeaderboardRow: View {
    let user: LeaderboardUser
    let rank: Int
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            rankBadge
                .frame(width: 40, alignment: .leading)
            
            HStack(spacing: 8) {
                Image(systemName: isCurrentUser ? "person.circle.fill" : "person.circle")
                    .foregroundColor(isCurrentUser ? Color(red: 1.0, green: 0.5, blue: 0.0) : .gray)
                
                Text(user.displayName)
                    .font(.system(size: 14, weight: isCurrentUser ? .semibold : .regular))
                    .foregroundColor(.white)
                + Text(isCurrentUser ? " (Вы)" : "")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            
            Text(user.formattedBalance)
                .foregroundColor(.white)
                .font(.system(size: 13))
                .frame(width: 85, alignment: .trailing)
                .lineLimit(1)
            
            Text(user.formattedPortfolio)
                .foregroundColor(user.profitColor)
                .font(.system(size: 13))
                .frame(width: 85, alignment: .trailing)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            isCurrentUser
                ? Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.1)
                : Color.clear
        )
        .cornerRadius(8)
    }
    
    private var rankBadge: some View {
        Group {
            if rank <= 3 {
                ZStack {
                    Circle()
                        .fill(rank == 1 ? Color.yellow : rank == 2 ? Color.gray : Color.orange)
                        .frame(width: 28, height: 28)
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(rank == 1 ? .black : .white)
                        .frame(width: 28, height: 28)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text("\(rank)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(rank <= 10 ? .white : .gray)
                    .frame(width: 28, height: 28)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Helpers

private extension LeaderboardUser {
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: balance)) ?? "\(Int(balance)) ₽"
    }
    
    var formattedPortfolio: String {
        let value = portfolioValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: abs(value))) ?? "\(Int(abs(value))) ₽"
    }
}

#Preview {
    LeaderboardScreenView()
}
