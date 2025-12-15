//
//  FavoritesCardView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 01.12.2025.
//

import SwiftUI

struct FavoritesCardView: View {
    
    let item: PromotionItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(item.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.symbol)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    Text(item.name)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Text(item.formattedPrice)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            HStack(spacing: 12) {
                Text(item.formattedChange)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(item.changeColor)
                Button("Подробнее"){
                    print("Открытие графика")
                }
                .foregroundColor(Color(hex: "000000"))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SKBColor.mainAppColor.suiColor)
                        .frame(width: 100, height: 30)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FFFFFF").opacity(0.05),
                        Color(hex: "FFBC11").opacity(0.08)
                        ]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                )
            )
        )
    }
}

struct PromotionCardView: View {
    let item: PromotionItem

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(item.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.symbol)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    Text(item.name)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            Image("MiniGraphExample")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 40)
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.formattedPrice)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(item.formattedChange)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(item.changeColor)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: 60)
        .padding(.horizontal, 8)
    }
}

#Preview {
    ClientZoneScreenView()
}
