//
//  SKBAppBalanceProperties.swift
//  MyInvestor
//
//  Created by Максим Скориков on 09.12.2025.
//

import SwiftUI

extension UserBalance {
    
    var formattedBalance: String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: balance)) ?? "$\(balance)"
        
    }
    
}
