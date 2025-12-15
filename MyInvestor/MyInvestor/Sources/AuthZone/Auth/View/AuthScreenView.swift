//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct AuthScreenView: View {

    @State
    var loginInput = String()
    @State
    var passwordInput = String()

    var body: some View {
        VStack(spacing: .zero) {
            inputContainer
            Spacer()
            buttonContent
        }
        .padding()
    }
}

// MARK: - UI Subviews

private extension AuthScreenView {

    var inputContainer: some View {
        VStack(spacing: 16) {
            TextField("Введите логин", text: $loginInput)
                .textFieldStyle(.roundedBorder)
            TextField("Введите пароль", text: $passwordInput)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }

    var buttonContent: some View {
        Button {
            // TODO: Добавить обработку нажатия
        } label: {
            Text("Войти")
                .frame(maxWidth: .infinity)
                .padding(8)
        }
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Preview

#Preview {
    AuthScreenView()
}
