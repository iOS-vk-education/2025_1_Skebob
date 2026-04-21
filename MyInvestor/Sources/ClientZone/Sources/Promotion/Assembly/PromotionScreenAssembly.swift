//
//  PromotionScreenAssembly.swift
//  MyInvestor
//
//  Created by Максим Скориков on 22.12.2025.
//

import SwiftUI

enum PromotionScreenAssembly {

    static func assemble(with item: PromotionItem) -> some View {
        let view = PromotionScreenView(item: item)
        return view
    }
}
