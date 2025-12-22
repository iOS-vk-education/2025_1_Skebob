//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct QuoteScreenView: View {
    
    @State private var userBalance = UserBalance(balance: 1000.0)
    @State private var favoriteItems: [PromotionItem] = []
    @State private var selectedPromotionItem: PromotionItem?

    var body: some View {
        VStack(spacing: 16) {
            balanceContainer
            favoritesContainer
            promotionContainer
        }
        .onAppear {
            if favoriteItems.isEmpty {
                loadSecurity()
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
        .padding(.top, 16)
    }

    var favoritesContainer: some View {
        
        VStack(spacing: 5) {
            Text("Избранное")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
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
    var promotionContainer: some View {
        VStack(spacing: 0) {
            Text("Акции")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVStack(spacing: 12){
                ForEach(favoriteItems) { item in
                    Button {
                        selectedPromotionItem = item
                    } label: {
                        PromotionCardView(item: item)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .fullScreenCover(item: $selectedPromotionItem) { item in
            PromotionScreenView(item: item)
        }
    }
    
    private func loadSecurity() {
        print("Загрузка акций...")
        Security.fetchSecurity { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let security):
                    self.favoriteItems = security.map { sec in
                        PromotionItem(
                            symbol: sec.secid,
                            name: sec.name,
                            price: sec.price,
                            changePercent: sec.changePercent,
                            icon: "BTCIcon"
                        )
                    }
                case .failure(let error):
                    print("Не удалось загрузить акции: \(error)")
                    self.favoriteItems = []
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ClientZoneScreenView()
}
