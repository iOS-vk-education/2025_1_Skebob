//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct QuoteScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var allSecurities: [PromotionItem]
    @Binding var favoriteSecIDs: [String]
    @Binding var selectedPromotionItem: PromotionItem?
    
    @State private var userBalance = UserBalance(balance: 100_000.0)
    
    private let db = Firestore.firestore()
    
    private var favoriteItems: [PromotionItem] {
        allSecurities.filter { favoriteSecIDs.contains($0.symbol) }
    }

    var body: some View {
        VStack(spacing: 16) {
            balanceContainer
            favoritesContainer
            Text("Новости")
                .foregroundColor(.white)
            
        }
        .onAppear {
            loadUserDataFromFirestore()
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
        .padding(.top, 16)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                .frame(height: 150)
            }
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
