//
//  SKBAppUserBalance.swift
//  MyInvestor
//
//  Created by Максим Скориков on 09.12.2025.
//

import Foundation

struct UserBalance: Identifiable, Equatable {
    
    let id = UUID()
    let balance: Double
}

extension UserBalance {
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: balance)) ?? "$\(balance)"
    }
}
