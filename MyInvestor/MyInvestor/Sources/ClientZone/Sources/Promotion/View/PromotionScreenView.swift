//
//  PromotionScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 22.12.2025.
//

import SwiftUI

struct PromotionScreenView: View {
    
    let item: PromotionItem
    @State private var is_fav = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text(item.formattedPrice)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                Text(item.formattedChange)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(item.changeColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 16)
            ChartView(ticker: item.symbol)
            HStack{
                Button {
                    // TODO: Обработать нажание
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SKBColor.coolGreenColor.suiColor)
                        .frame(width: 163, height: 48)
                        .overlay(
                            Text("Купить")
                            .foregroundColor(.white)
                        )
                }
                Button {
                    // TODO: Обработать нажание
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SKBColor.coolRedColor.suiColor)
                        .frame(width: 163, height: 48)
                        .overlay(
                            Text("Продать")
                            .foregroundColor(.white)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "161514").ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image("BackIcon")
                        .topBarButtonStyle()
                }
                .padding(.leading, 16)
                Spacer()
                Text(item.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    is_fav.toggle()
                    // TODO: Обработать нажание
                } label: {
                    Image("StarIcon")
                        .topBarButtonStyle(color: is_fav ? SKBColor.coolYellowColor.suiColor : .white.opacity(0.4))
                }
                .padding(.trailing, 16)
            }
            .overlay(
                Circle()
                    .fill(SKBColor.ambientAppColor_1.suiColor.opacity(0.1))
                .frame(width: 278, height: 278)
                .blur(radius: 200)
                .offset(y: -120)
                .overlay(
                    Circle()
                    .fill(SKBColor.ambientAppColor_2.suiColor.opacity(0.2))
                    .frame(width: 167, height: 167)
                    .blur(radius: 100)
                    .offset(y: -100)
                )
            )
        }
    }
    
}

#Preview {
    
    let testItem = PromotionItem(
            symbol: "SBER",
            name: "Сбербанк",
            price: 300.50,
            changePercent: 1.25,
            icon: "BTCIcon"
        )
    PromotionScreenView(item: testItem)
}
