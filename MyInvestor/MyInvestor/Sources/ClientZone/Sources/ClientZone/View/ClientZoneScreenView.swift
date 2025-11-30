//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct ClientZoneScreenView: View {

    @State
    private var selectedTab: SKBAppTabKind = .quotes

    var body: some View {
        TabView(selection: $selectedTab) {
            applyTabView(kind: .quotes) {
                QuoteScreenAssembly.assemble()
            }

            applyTabView(kind: .rating) {
                // TODO: Cверстать экран
                Text("Экран rating")
            }

            applyTabView(kind: .portfolio) {
                // TODO: Cверстать экран
                Text("Экран portfolio")
            }

            applyTabView(kind: .profile) {
                // TODO: Cверстать экран
                Text("Экран profile")
            }

            applyTabView(kind: .settings) {
                // TODO: Cверстать экран
                Text("Экран settings")
            }
        }
        .tint(SKBColor.mainAppColor.suiColor)
    }
}

// MARK: - Helpers

private extension ClientZoneScreenView {

    func applyTabView(
        kind: SKBAppTabKind,
        content: () -> some View
    ) -> some View {
        content()
            .tabItem {
                Label(kind.title, systemImage: kind.iconName)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .tag(kind)
    }
}

// MARK: - Preview

#Preview {
    ClientZoneScreenView()
}
