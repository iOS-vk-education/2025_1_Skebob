//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

enum QuoteScreenAssembly {
    static func assemble(
        allSecurities: [PromotionItem],
        favoriteSecIDs: Binding<[String]>,
        selectedPromotionItem: Binding<PromotionItem?>
    ) -> QuoteScreenView {
        QuoteScreenView(
            allSecurities: allSecurities,
            favoriteSecIDs: favoriteSecIDs,
            selectedPromotionItem: selectedPromotionItem
        )
    }
}
