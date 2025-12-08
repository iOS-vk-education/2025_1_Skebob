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
