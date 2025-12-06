//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct QuoteScreenView: View {

    var body: some View {
        VStack(spacing: 16) {
            balanceContainer
            favoritesContainer
            promotionContainer
            Spacer()
        }
        .padding(.top, 100)
        //.background(Color.black)
    }
}

// MARK: - UI Subviews

private extension QuoteScreenView {

    var balanceContainer: some View {
        VStack(spacing: 16) {
            HStack{
                Text("Текущий баланс")
                Spacer()
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color(hex: "FFFFFF").opacity(0.6))
            HStack{
                Text("$1,000.000")
                Spacer()
            }
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(Color(hex: "FFFFFF"))
        }
        .padding(.leading, 16)
    }

    var favoritesContainer: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Избранное")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            ZStack(alignment: .top){
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(favoriteItems) { item in
                            FavoritesCardView(item: item)
                                .frame(width: 200, height: 180)
                        }
                    }
                }
                .frame(height: 196)
                .clipped()
            }
        }
        .padding(.horizontal, 16)
    }
    var promotionContainer: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Акции")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            HStack{
                LazyVStack(spacing: 12){
                    ForEach(favoriteItems) { item in
                        PromotionCardView(item: item)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

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
    QuoteScreenView()
}
