//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct QuoteScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var newsVM: NewsViewModel
    
    var allSecurities: [PromotionItem]
    @Binding var favoriteSecIDs: [String]
    @Binding var selectedPromotionItem: PromotionItem?
    
    @State private var userBalance = UserBalance(balance: 100_000.0)
    private let db = Firestore.firestore()
    
    private var favoriteItems: [PromotionItem] {
        allSecurities.filter { favoriteSecIDs.contains($0.symbol) }
    }
    
    private var favoriteTickers: [String] {
        favoriteItems.map { $0.symbol }
    }

    var body: some View {
        ZStack {
            Color(hex: "161514").ignoresSafeArea()
            ScrollView (showsIndicators: false) {
                VStack(spacing: 16) {
                    balanceContainer
                    favoritesContainer
                    newsSection
                }
                .padding(.top, 80)
            }
        }
        .onAppear {
            loadUserDataFromFirestore()
            if newsVM.items.isEmpty {
                Task { await newsVM.load(tickers: favoriteTickers) }
            }
        }
    }
}

// MARK: - UI Subviews

private extension QuoteScreenView {

    private var balanceContainer: some View {
        VStack(spacing: 4) {
            Text("Текущий баланс")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
                
            Text(userBalance.formattedBalance)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 16)
        .padding(.top, 10)
    }

    var favoritesContainer: some View {
        VStack(spacing: 5) {
            Text("Избранное")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            if favoriteItems.isEmpty {
                Text("Нет избранных акций")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(favoriteItems) { item in
                            FavoritesCardView(item: item) {
                                selectedPromotionItem = item
                            }
                        }
                    }
                }
                .frame(height: 170)
            }
        }
    }
    
    private var newsSection: some View {
        VStack(spacing: 5) {
            Text("Новости")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            if newsVM.loading && newsVM.items.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
            } else if newsVM.items.isEmpty {
                Text("Нет новостей")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    ForEach(newsVM.items) { item in
                        NewsRow(item: item)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
            }
        }
    }
    
    private struct NewsRow: View {
        let item: NewsItem
        
        var body: some View {
            Button {
                UIApplication.shared.open(item.url)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let imageUrl = item.imageUrl {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 140)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(.white.opacity(0.5))
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 140)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 140)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(12)
                    }
                    
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(item.summary)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 8) {
                        Text(item.source)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 0.5)
                                    )
                            )
                        
                        Spacer()
                        
                        Text(item.formattedDate)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "FFBC11").opacity(0.9))
                            .fontWeight(.medium)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FFFFFF").opacity(0.05),
                                    Color(hex: "FFBC11").opacity(0.08)
                                ]),
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "FFBC11").opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: Color(hex: "FFBC11").opacity(0.1), radius: 8, y: 3)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Data Loading

    private func loadUserDataFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    return
                }
                guard let data = snapshot?.data() else { return }

                DispatchQueue.main.async {
                    if let balance = data["balance"] as? Double {
                        self.userBalance = UserBalance(balance: balance)
                    }
                    self.favoriteSecIDs = (data["favoriteStocks"] as? [String]) ?? []
                }
            }
    }
}

// MARK: - Preview

#Preview {
    ClientZoneScreenView()
}
