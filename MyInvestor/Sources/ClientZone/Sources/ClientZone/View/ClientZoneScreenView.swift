//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct ClientZoneScreenView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var portfolioViewModel = PortfolioViewModel()
    @StateObject private var newsViewModel = NewsViewModel()
    
    @State private var selectedTab: SKBAppTabKind = .quotes
    @State private var isSearchPresented = false
    @State private var isProfilePresented = false
    
    @State private var allSecurities: [PromotionItem] = []
    @State private var favoriteSecIDs: [String] = []
    @State private var selectedPromotionItem: PromotionItem?

    var body: some View {
        
        ScrollView {
            content(for: selectedTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "161514").ignoresSafeArea())
        .environmentObject(authViewModel)
        .environmentObject(portfolioViewModel)
        .environmentObject(newsViewModel)
        .safeAreaInset(edge: .top) {
            HStack(spacing: 0) {
                Button {
                    isProfilePresented = true
                } label: {
                    Image("ProfileIcon")
                        .topBarButtonStyle()
                }
                .padding(.leading, 16)
                Spacer()
                Button {
                    authViewModel.presentDailyRewardPopup()
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
                Button {
                    isSearchPresented = true
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
                .allowsHitTesting(false)
            )
        }
        .sheet(isPresented: $isProfilePresented) {
            ProfileView(authViewModel: authViewModel)
                .environmentObject(authViewModel)
                .environmentObject(portfolioViewModel)
        }
        .sheet(isPresented: $isSearchPresented) {
            SearchScreenView(
                allSecurities: allSecurities,
                favoriteSecIDs: $favoriteSecIDs,
                onSelect: { item in
                    selectedPromotionItem = item
                }
            )
            .environmentObject(authViewModel)
            .environmentObject(portfolioViewModel)
        }
        .fullScreenCover(item: $selectedPromotionItem) { item in
            PromotionScreenView(item: item)
                .environmentObject(authViewModel)
                .environmentObject(portfolioViewModel)
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
        }
        .onAppear {
            loadSecuritiesIfNeeded()
            authViewModel.refreshDailyStreakIfLoggedIn()
        }
    }
    
    private func loadSecuritiesIfNeeded() {
        if allSecurities.isEmpty {
            Security.fetchSecurity { result in
                DispatchQueue.main.async {
                    if case .success(let securities) = result {
                        self.allSecurities = securities.map { sec in
                            PromotionItem(
                                symbol: sec.secid,
                                name: sec.name,
                                price: sec.price,
                                changePercent: sec.changePercent,
                                icon: "BTCIcon"
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func content(for tab: SKBAppTabKind) -> some View {
        
        switch tab {
        case .quotes:
            QuoteScreenAssembly.assemble(
                allSecurities: allSecurities,
                favoriteSecIDs: $favoriteSecIDs,
                selectedPromotionItem: $selectedPromotionItem
            )
            .environmentObject(newsViewModel)
        case .rating:
            LeaderboardScreenAssembly.assemble()
        case .portfolio:
            PortfolioScreenAssembly.assemble()
        case .settings:
            SettingsScreenAssembly.assemble()
        }
    }
}

// MARK: - Preview

#Preview {
    ClientZoneScreenView()
}
