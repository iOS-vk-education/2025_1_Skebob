//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct QuoteScreenView: View {
    
    @State private var userBalance = UserBalance(balance: 1000.0)

    var body: some View {
        VStack(spacing: 16) {
            balanceContainer
            favoritesContainer
            promotionContainer
        }
    }
}

// MARK: - UI Subviews

private extension QuoteScreenView {

    private var balanceContainer: some View {
        VStack(spacing: 16) {
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
    }

    var favoritesContainer: some View {
        VStack(spacing: 0) {
            Text("Избранное")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(favoriteItems) { item in
                        FavoritesCardView(item: item)
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
                    PromotionCardView(item: item)
                }
            }
        }
        .padding(.horizontal, 16)
    }
        // Временные данные (потом будут из API и в другом месте)
        private var favoriteItems: [PromotionItem] {
            [
                PromotionItem(symbol: "BTC", name: "Bitcoin", price: 15240, changePercent: 0.25, icon: "BTCIcon"),
                PromotionItem(symbol: "ETH", name: "Ethereum", price: 1150, changePercent: 0.89, icon: "BTCIcon"),
                PromotionItem(symbol: "DOT", name: "Polkadot", price: 5.288, changePercent: 0.89, icon: "BTCIcon"),
                PromotionItem(symbol: "USDT", name: "Tether", price: 0.999, changePercent: 0.09, icon: "BTCIcon"),
                PromotionItem(symbol: "DOGE", name: "Dogecoin", price: 0.100, changePercent: -1.2, icon: "BTCIcon")
            ]
        }
}

// MARK: - Preview

#Preview {
    ClientZoneScreenView()
}
