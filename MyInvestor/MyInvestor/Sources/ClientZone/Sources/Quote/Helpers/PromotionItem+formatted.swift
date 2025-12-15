//
//  SKBAppPromotionItem.swift
//  MyInvestor
//
//  Created by Максим Скориков on 09.12.2025.
//

import Foundation
import SwiftUI

struct PromotionItem: Identifiable, Equatable {
    
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let changePercent: Double
    let icon: String
}

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
