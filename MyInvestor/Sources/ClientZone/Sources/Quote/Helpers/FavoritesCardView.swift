//
//  FavoritesCardView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 01.12.2025.
//

import SwiftUI

struct FavoritesCardView: View {
    
    let item: PromotionItem
    let onDetailTap: () -> Void

    var body: some View {
        Button(action: onDetailTap) {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(spacing: 10) {
                    Image(item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 34, height: 34)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.symbol)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text(item.name)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    Spacer()
                }
                
                HStack(alignment: .center, spacing: 10) {
                    Text(item.formattedPrice)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 3) {
                        Image(systemName: item.changePercent >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text(item.formattedChange)
                            .font(.system(size: 13, weight: .medium))
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                    }
                    .foregroundColor(item.changeColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.changeColor.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(item.changeColor.opacity(0.3), lineWidth: 0.5)
                    )
                }
                
                HStack(spacing: 4) {
                    Text("Подробнее")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Color(hex: "161514"))
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(SKBColor.mainAppColor.suiColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1E1C1B"),
                                Color(hex: "161514")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct PromotionCardView: View {
    
    let item: PromotionItem

    var body: some View {
        HStack(spacing: 12) {
            Image(item.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36, alignment: .leading)
                .clipShape(Circle())
            Text(item.symbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(item.formattedPrice)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 70, alignment: .trailing)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(item.formattedChange)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(item.changeColor)
                .frame(width: 70, alignment: .trailing)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding(.horizontal, 8)
    }
}

#Preview {
    ClientZoneScreenView()
}
