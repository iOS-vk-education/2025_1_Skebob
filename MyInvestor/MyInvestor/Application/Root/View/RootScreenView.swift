//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct RootScreenView: View {

    /// Флаг авторизации в приложении
    @State
    var isAuthed: Bool = false

    var body: some View {
        if isAuthed {
            SKBClientZoneAssembly.assemble()
        } else {
            SKBAuthZoneAssembly.assemble()
        }
    }
}

// MARK: - Preview

#Preview {
    RootScreenView()
}
