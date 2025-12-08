//
//  SKBAppCustomTabBar.swift
//  MyInvestor
//
//  Created by Максим Скориков on 30.11.2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: SKBAppTabKind

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SKBAppTabKind.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 0) {
                        Image(tab.iconName).renderingMode(.template).foregroundColor(Color.white).opacity(selectedTab == tab ? 1 : 0.5)
                            .frame(width: 24, height: 24)
                            .padding(.top, 15)
                        if selectedTab == tab {
                            Rectangle()
                                .fill(SKBColor.mainAppColor.suiColor)
                                .frame(width: 24, height: 3)
                                .cornerRadius(1.5)
                                .padding(.top, 15)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 24, height: 3)
                                .padding(.top, 15)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .contentShape(.rect)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            ZStack{
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.black).opacity(0.5))
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: -6)
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ClientZoneScreenView()
}
