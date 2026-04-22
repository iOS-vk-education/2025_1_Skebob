//
//  AuthViewModel.swift
//  MyInvestor
//
//  Created by Максим Скориков on 06.03.2026.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isCheckingSession = true
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isDailyRewardPresented = false
    @Published var dailyRewardAmount: Double = 0
    @Published var dailyRewardDay: Int = 0

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
                self?.updateDailyStreakIfNeeded()
                
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
                    self?.updateDailyStreakIfNeeded()
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
    private let calendar = Calendar.current

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
                    "streakCount": 1,
                    "streakLastActiveDate": Timestamp(date: Date()),
                    "createdAt": FieldValue.serverTimestamp()
                ])
            }
        }
    }

    func updateDailyStreakIfNeeded() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(uid)
        var rewardToPresent: Double = 0
        var streakDayToPresent: Int = 0

        db.runTransaction { [weak self] transaction, errorPointer in
            guard let self = self else { return nil }

            do {
                let snapshot = try transaction.getDocument(userRef)
                let data = snapshot.data() ?? [:]

                let today = self.calendar.startOfDay(for: Date())
                let currentStreak = data["streakCount"] as? Int ?? 0
                let currentBalance = data["balance"] as? Double ?? 1000
                let lastActiveDate = (data["streakLastActiveDate"] as? Timestamp)?.dateValue()
                let currentName = data["name"] as? String ?? "Пользователь"
                let currentFavorites = data["favoriteStocks"] as? [String] ?? []
                let currentPortfolio = data["portfolio"] as? [String: Any] ?? [:]

                let newStreak: Int
                if let lastActiveDate {
                    let lastDay = self.calendar.startOfDay(for: lastActiveDate)
                    let dayDiff = self.calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

                    if dayDiff == 0 {
                        return nil
                    } else if dayDiff == 1 {
                        newStreak = max(currentStreak, 1) + 1
                    } else {
                        // If date jumped backwards/forwards by more than one day,
                        // restart streak so reward logic recovers instead of freezing.
                        newStreak = 1
                    }
                } else {
                    newStreak = max(currentStreak, 1)
                }

                let reward = self.dailyRewardAmount(for: newStreak)
                let newBalance = currentBalance + reward

                transaction.setData([
                    "name": currentName,
                    "favoriteStocks": currentFavorites,
                    "portfolio": currentPortfolio,
                    "streakCount": newStreak,
                    "streakLastActiveDate": Timestamp(date: today),
                    "balance": newBalance,
                    "createdAt": data["createdAt"] ?? FieldValue.serverTimestamp()
                ], forDocument: userRef, merge: true)

                rewardToPresent = reward
                streakDayToPresent = newStreak
            } catch {
                errorPointer?.pointee = error as NSError
            }

            return nil
        } completion: { [weak self] _, error in
            guard let self = self, error == nil, rewardToPresent > 0, streakDayToPresent > 0 else { return }
            DispatchQueue.main.async {
                self.dailyRewardDay = streakDayToPresent
                self.dailyRewardAmount = rewardToPresent
                self.isDailyRewardPresented = true
            }
        }
    }

    private func dailyRewardAmount(for day: Int) -> Double {
        let cycleDay = ((max(day, 1) - 1) % 7) + 1
        switch cycleDay {
        case 1: return 100
        case 2: return 150
        case 3: return 200
        case 4: return 300
        case 5: return 400
        case 6: return 550
        case 7: return 750
        default: return 100
        }
    }

    func closeDailyRewardPopup() {
        isDailyRewardPresented = false
    }

    func presentDailyRewardPopup() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
            let data = snapshot?.data() ?? [:]
            let streak = data["streakCount"] as? Int ?? 1
            let reward = self.dailyRewardAmount(for: streak)

            DispatchQueue.main.async {
                self.dailyRewardDay = max(streak, 1)
                self.dailyRewardAmount = reward
                self.isDailyRewardPresented = true
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
            updateDailyStreakIfNeeded()
            
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

    func refreshDailyStreakIfLoggedIn() {
        guard Auth.auth().currentUser != nil else { return }
        updateDailyStreakIfNeeded()
    }
}
