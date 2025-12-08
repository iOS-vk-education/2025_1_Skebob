//
//  SKBAppItemProperties.swift
//  MyInvestor
//
//  Created by Максим Скориков on 09.12.2025.
//

import SwiftUI

extension PromotionItem {
    
    var formattedPrice: String {
        "$\(String(format: "%.2f", price))"
    }

    var formattedChange: String {
        let sign = changePercent >= 0 ? "+" : "-"
        return "\(sign)\(String(format: "%.2f", abs(changePercent)))%"
    }

    var changeColor: Color {
        changePercent >= 0 ? .green : .red
    }
    
}
