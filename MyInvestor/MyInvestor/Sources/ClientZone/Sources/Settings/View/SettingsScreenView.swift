//
//  SettingsScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 23.12.2025.
//

import SwiftUI

struct SettingsScreenView: View {
    
    @EnvironmentObject var AuthViewModel: AuthViewModel
    
    var body: some View {
        Button {
            AuthViewModel.logout()
        } label: {
            Text("Выйти")
        }
    }
}
