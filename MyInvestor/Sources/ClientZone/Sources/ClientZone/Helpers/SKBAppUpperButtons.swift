//
//  SKBAppUpperButtons.swift
//  MyInvestor
//
//  Created by Максим Скориков on 30.11.2025.
//

import SwiftUI

extension Image {
    
    func topBarButtonStyle(color: Color = .white) -> some View {
        self
            .renderingMode(.template)
            .foregroundColor(color)
            .frame(width: 28, height: 28)
            .padding(20)
            .background(
                ZStack{
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(.black).opacity(0.5))
                }
            )
    }
}
