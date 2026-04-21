//
//  AuthViewModel.swift
//  MyInvestor
//
//  Created by Максим Скориков on 06.03.2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isCheckingSession = true
    @Published var errorMessage: String?
    @Published var isLoading = false

    func login(email: String, password: String) {
        errorMessage = nil
        isLoading = true

        guard !email.isEmpty else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Введите e-mail"
            }
            return
        }
        guard !password.isEmpty else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Введите пароль"
            }
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if error != nil {
                    self?.errorMessage = "Неверная почта или пароль"
                    return
                }
                self?.isLoggedIn = true
                self?.initializeUserDataIfNeeded()
                
                if let uid = Auth.auth().currentUser?.uid {
                    self?.db.collection("users").document(uid).getDocument { snapshot, _ in
                        if let data = snapshot?.data(),
                           let balance = data["balance"] as? Double,
                           let portfolio = data["portfolio"] as? [String: Any] {
                            let displayName = data["name"] as? String ?? "Пользователь"
                            self?.updatePublicLeaderboard(
                                uid: uid,
                                balance: balance,
                                portfolio: portfolio,
                                displayName: displayName
                            )
                        }
                    }
                }
            }
        }
    }
    
    func register(email: String, password: String, confirmPassword: String, completion: @escaping (String?) -> Void) {
        guard !email.isEmpty else {
            completion("Введите email")
            return
        }
        guard email.contains("@") && email.contains(".") else {
            completion("Введите корректный email")
            return
        }
        guard !password.isEmpty else {
            completion("Введите пароль")
            return
        }
        guard password.count >= 6 else {
            completion("Пароль должен быть не менее 6 символов")
            return
        }
        guard password == confirmPassword else {
            completion("Пароли не совпадают")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    let message: String
                    if let authError = error as? AuthErrorCode {
                        switch authError {
                        case .emailAlreadyInUse:
                            message = "Email уже используется"
                        case .invalidEmail:
                            message = "Недействительный email"
                        case .weakPassword:
                            message = "Пароль слишком слабый"
                        default:
                            message = "Ошибка регистрации"
                        }
                    } else {
                        message = "Не удалось создать аккаунт"
                    }
                    completion(message)
                } else {
                    self?.initializeUserDataIfNeeded()
                    if let uid = Auth.auth().currentUser?.uid {
                        self?.db.collection("users").document(uid).getDocument { snapshot, _ in
                            if let data = snapshot?.data(),
                               let balance = data["balance"] as? Double,
                               let portfolio = data["portfolio"] as? [String: Any] {
                                let displayName = data["name"] as? String ?? "Пользователь"
                                self?.updatePublicLeaderboard(
                                    uid: uid,
                                    balance: balance,
                                    portfolio: portfolio,
                                    displayName: displayName
                                )
                            }
                        }
                    }
                    completion(nil)
                }
            }
        }
    }
    
    private let db = Firestore.firestore()

    func initializeUserDataIfNeeded(userName: String = "") {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Ошибка Firestore: \(error)")
                return
            }
            
            if !(snapshot?.exists ?? false) {
                let nameToSave = userName.isEmpty ? "Пользователь" : userName
                self?.db.collection("users").document(uid).setData([
                    "balance": 1000.0,
                    "favoriteStocks": [] as [String],
                    "portfolio": [:] as [String: Any],
                    "name": nameToSave,
                    "createdAt": FieldValue.serverTimestamp()
                ])
            }
        }
    }
    
    func updatePublicLeaderboard(uid: String, balance: Double, portfolio: [String: Any], displayName: String) {
        let portfolioSummary = portfolio.mapValues { stock in
            if let stockDict = stock as? [String: Any],
               let shares = stockDict["shares"] as? Int {
                return ["shares": shares] as [String: Any]
            }
            return [:]
        } as? [String: [String: Any]] ?? [:]
        
        let portfolioValue = portfolioSummary.values.reduce(0.0) {
            $0 + Double($1["shares"] as? Int ?? 0) * 100
        }
        
        let totalValue = balance + portfolioValue
        
        let publicData: [String: Any] = [
            "balance": balance,
            "portfolioValue": portfolioValue,
            "totalValue": totalValue,
            "displayName": displayName,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("publicLeaderboard")
            .document(uid)
            .setData(publicData, merge: true)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: "userEmail")
        } catch {
            print("Ошибка при выходе: $error)")
        }
    }

    func checkSession() {
        isCheckingSession = false
        if let user = Auth.auth().currentUser {
            isLoggedIn = true
            initializeUserDataIfNeeded()
            
            let uid = user.uid
            self.db.collection("users").document(uid).getDocument { snapshot, _ in
                if let data = snapshot?.data(),
                   let balance = data["balance"] as? Double,
                   let portfolio = data["portfolio"] as? [String: Any] {
                    let displayName = data["name"] as? String ?? "Пользователь"
                    self.updatePublicLeaderboard(
                        uid: uid,
                        balance: balance,
                        portfolio: portfolio,
                        displayName: displayName
                    )
                }
            }
        }
    }
}
