//
//  AuthScreenAssembly.swift
//  MyInvestor
//
//  Created by Максим Скориков on 22.12.2025.
//

import SwiftUI

enum SKBAuthZoneAssembly {

    static func assemble() -> AnyView {
        let view = AuthZoneScreenAssembly.assemble()
        return AnyView(view)
    }
}
