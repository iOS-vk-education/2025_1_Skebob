//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct RootScreenView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

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
    }
}

// MARK: - Preview

#Preview {
    RootScreenView()
}
