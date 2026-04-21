//
//  RegisterScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 23.12.2025.
//

import SwiftUI

struct RegisterScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.05),
                    Color(red: 0.9, green: 0.3, blue: 0.1).opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Заголовок
                    VStack(spacing: 10) {
                        Text("Регистрация")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Создайте аккаунт в MyInvestor")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                    
                    // Ошибка
                    if let errorMessage = errorMessage {
                        ErrorMessageView(message: errorMessage)
                    }
                    
                    // Поле email
                    AuthTextField(
                        title: "Email",
                        placeholder: "your.email@example.com",
                        text: $email,
                        icon: "envelope.fill"
                    )
                    
                    // Поле пароль
                    AuthSecureField(
                        title: "Пароль",
                        placeholder: "Введите пароль",
                        text: $password,
                        isSecure: !isPasswordVisible,
                        toggleVisibility: { isPasswordVisible.toggle() }
                    )
                    
                    // Поле подтверждения пароля
                    AuthSecureField(
                        title: "Подтвердите пароль",
                        placeholder: "Повторите пароль",
                        text: $confirmPassword,
                        isSecure: !isConfirmPasswordVisible,
                        toggleVisibility: { isConfirmPasswordVisible.toggle() }
                    )
                    
                    // Кнопка регистрации
                    Button(action: signUp) {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.5, blue: 0.0),
                                    Color(red: 0.9, green: 0.3, blue: 0.1)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(height: 55)
                            .cornerRadius(12)
                            .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.4), radius: 10, y: 5)
                            
                            Text("Зарегистрироваться")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Ссылка на вход
                    HStack(spacing: 5) {
                        Text("Уже есть аккаунт?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        
                        Button("Войти") {
                            dismiss() // закрываем регистрацию, возвращаемся на логин
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 30)
            }
        }
    }
    
    private func signUp() {
        errorMessage = nil
        
        authViewModel.register(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            confirmPassword: confirmPassword
        ) { error in
            authViewModel.isLoading = false
            if let error = error {
                self.errorMessage = error
            } else {
                authViewModel.isLoggedIn = true
                dismiss()
            }
        }
    }
}

// MARK: - Вспомогательные View

struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField("", text: $text)
                    .keyboardType(title == "Email" ? .emailAddress : .default)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(Color.gray.opacity(0.7))
                    }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.1, green: 0.1, blue: 0.12)))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.5, blue: 0.0),
                                Color(red: 0.9, green: 0.3, blue: 0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let toggleVisibility: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                if isSecure {
                    SecureField("", text: $text)
                        .foregroundColor(.white)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(Color.gray.opacity(0.7))
                        }
                } else {
                    TextField("", text: $text)
                        .foregroundColor(.white)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(Color.gray.opacity(0.7))
                        }
                }
                
                Button(action: toggleVisibility) {
                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.1, green: 0.1, blue: 0.12)))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.5, blue: 0.0),
                                Color(red: 0.9, green: 0.3, blue: 0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
}
