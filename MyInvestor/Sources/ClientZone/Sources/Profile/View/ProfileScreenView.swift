//
//  ProfileScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 06.03.2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ProfileViewModel
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertSuccess = false
    
    init(authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "161514").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.5, blue: 0.0),
                                                Color(red: 0.9, green: 0.3, blue: 0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.5), radius: 15)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.orange)
                            } else {
                                Text(viewModel.userName.isEmpty ? "Пользователь" : viewModel.userName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 20)

                        HStack(spacing: 10) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 22, weight: .bold))

                            Text(viewModel.streakCount > 0 ? "\(viewModel.streakCount) дней подряд" : "Серия пока не начата")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.6), lineWidth: 1)
                        )

                        VStack(spacing: 16) {
                            ProfileTextField(
                                title: "Имя",
                                text: $viewModel.userName,
                                icon: "person.fill"
                            )
                            ProfileTextField(
                                title: "Почта",
                                text: .constant(viewModel.userEmail),
                                icon: "envelope.fill",
                                isEditable: false
                            )
                            DateInput(viewModel: viewModel)
                        }
                        
                        Button(action: saveProfile) {
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
                                
                                if viewModel.isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    HStack(spacing: 10) {
                                        Text("Сохранить")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .disabled(viewModel.isSaving)
                        .padding(.horizontal, 16)
                        
                        Button(action: logout) {
                            Text("Выйти")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 16)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        ErrorMessageView(message: errorMessage)
                            .padding(.horizontal, 16)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
            .alert("Профиль", isPresented: $showingAlert) {
                Button("OK") {
                    if alertSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveProfile() {
        viewModel.saveProfile { success, message in
            alertMessage = message ?? (success ? "Профиль сохранён" : "Ошибка сохранения")
            alertSuccess = success
            showingAlert = true
        }
    }
    
    private func logout() {
        viewModel.logout()
        dismiss()
    }
}

// MARK: - Components

struct ProfileTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isEditable: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                if isEditable {
                    TextField("", text: $text)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .placeholder(when: text.isEmpty) {
                            Text("Введите \(title.lowercased())")
                                .foregroundColor(Color.gray.opacity(0.7))
                        }
                } else {
                    Text(text)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
            )
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

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
