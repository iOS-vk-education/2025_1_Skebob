//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct ClientZoneScreenView: View {
    
    @State private var selectedTab: SKBAppTabKind = .quotes

    var body: some View {
        
        ScrollView{
            content(for: selectedTab)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "161514").ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            HStack(spacing: 0) {
                Button {
                    // TODO: Обработать нажание
                } label: {
                    Image("ProfileIcon")
                        .topBarButtonStyle()
                }
                .padding(.leading, 16)
                Spacer()
                Button {
                    // TODO: Обработать нажание
                } label: {
                    Image("SearchIcon")
                        .topBarButtonStyle()
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
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
        }
    }

    @ViewBuilder
    private func content(for tab: SKBAppTabKind) -> some View {
        
        switch tab {
        case .quotes:
            QuoteScreenAssembly.assemble()
        case .rating:
            Text("Экран rating")
        case .portfolio:
            Text("Экран portfolio")
        case .settings:
            SettingsScreenAssembly.assemble()
        }
    }
}

// MARK: - Preview

#Preview {
    ClientZoneScreenView()
}
