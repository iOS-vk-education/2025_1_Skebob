//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

enum SKBAuthZoneAssembly {

    static func assemble() -> AnyView {
        let view = AuthScreenViewAssembly.assemble()
        return AnyView(view)
    }
}
