//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct SKBColor: Hashable {

    private let hex: String

    init(_ hex: String) {
        self.hex = hex
    }
}

// MARK: - Helpers

extension SKBColor {

    var suiColor: Color {
        Color(hex: hex)
    }
}
