//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct RootScreenView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if authViewModel.isCheckingSession {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
            } else if authViewModel.isLoggedIn {
                SKBClientZoneAssembly.assemble()
            } else {
                SKBAuthZoneAssembly.assemble()
            }
        }
        .onAppear {
            authViewModel.checkSession()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                authViewModel.refreshDailyStreakIfLoggedIn()
            }
        }
        .fullScreenCover(isPresented: $authViewModel.isDailyRewardPresented) {
            DailyLoginRewardAssembly.assemble(
                day: authViewModel.dailyRewardDay,
                amount: authViewModel.dailyRewardAmount,
                onClose: authViewModel.closeDailyRewardPopup
            )
        }
    }
}

// MARK: - Preview

#Preview {
    RootScreenView()
}
