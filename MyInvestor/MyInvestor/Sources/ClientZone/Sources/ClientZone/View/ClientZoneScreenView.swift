//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct ClientZoneScreenView: View {
    @State private var selectedTab: SKBAppTabKind = .quotes

    var body: some View {
        ZStack{
            ZStack(alignment: .bottom) {
                content(for: selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "161514").ignoresSafeArea())
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 18)
            }
            ZStack{
                HStack {
                    Button(action: { print("Экран profile") }) {
                        Image("ProfileIcon")
                            .topBarButtonStyle()
                    }
                    .padding(.leading, 16)
                    .padding(.top, 10)
                    Spacer()
                    Button(action: { print("Поиск") }) {
                        Image("SearchIcon")
                            .topBarButtonStyle()
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 10)
                }
                .overlay(
                    Circle()
                    .fill(Color(hex: "EABB13").opacity(0.1))
                    .frame(width: 278, height: 278)
                    .blur(radius: 200)
                    .offset(y: -120)
                    .overlay(
                        Circle()
                        .fill(Color(hex: "EE2B00").opacity(0.2))
                        .frame(width: 167, height: 167)
                        .blur(radius: 100)
                        .offset(y: -100)
                    )
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    @ViewBuilder
    private func content(for tab: SKBAppTabKind) -> some View {
        switch tab {
        case .quotes:
            ScrollView{
                QuoteScreenAssembly.assemble()
            }
        case .rating:
            ScrollView{
                Text("Экран rating")
            }
        case .portfolio:
            ScrollView{
                Text("Экран portfolio")
            }
        case .settings:
            ScrollView{
                Text("Экран settings")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ClientZoneScreenView()
}
