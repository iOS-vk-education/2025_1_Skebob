//
//  PortfolioViewModel.swift
//  MyInvestor
//
//  Created by Максим Скориков on 06.03.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class PortfolioViewModel: ObservableObject {
    @Published var portfolio: [String: Any] = [:]
    @Published var balance: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private weak var authViewModel: AuthViewModel?
    
    init(authViewModel: AuthViewModel? = nil) {
        self.authViewModel = authViewModel
    }
    
    func buyStock(symbol: String, shares: Int, price: Double, completion: @escaping (Bool, String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Пользователь не авторизован")
            return
        }
        
        let totalCost = Double(shares) * price
        if totalCost <= 0 {
            completion(false, "Некорректное количество или цена")
            return
        }
        
        let userRef = db.collection("users").document(uid)
        
        db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let document = try transaction.getDocument(userRef)
                guard let userData = document.data() else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Данные пользователя не найдены"
                    ])
                    return nil
                }
                
                let currentBalance = (userData["balance"] as? Double) ?? 0.0
                
                guard currentBalance >= totalCost else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "Недостаточно средств"
                    ])
                    return nil
                }
                
                let newBalance = currentBalance - totalCost
                transaction.updateData(["balance": newBalance], forDocument: userRef)
                
                var portfolio = userData["portfolio"] as? [String: Any] ?? [:]
                if var existing = portfolio[symbol] as? [String: Any] {
                    let currentShares = (existing["shares"] as? Int) ?? 0
                    let currentAvgPrice = (existing["avgPrice"] as? Double) ?? 0.0
                    
                    let newShares = currentShares + shares
                    let newAvgPrice = ((currentAvgPrice * Double(currentShares)) + totalCost) / Double(newShares)
                    
                    existing["shares"] = newShares
                    existing["avgPrice"] = newAvgPrice
                    portfolio[symbol] = existing
                } else {
                    portfolio[symbol] = ["shares": shares, "avgPrice": price]
                }
                
                transaction.updateData(["portfolio": portfolio], forDocument: userRef)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        } completion: { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    self.updateLeaderboardAfterTransaction(uid: uid)
                    completion(true, nil)
                }
            }
        }
    }
    
    func sellStock(symbol: String, shares: Int, price: Double, completion: @escaping (Bool, String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Пользователь не авторизован")
            return
        }
        
        if shares <= 0 {
            completion(false, "Некорректное количество")
            return
        }
        
        let userRef = db.collection("users").document(uid)
        
        db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let document = try transaction.getDocument(userRef)
                guard let userData = document.data() else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Данные пользователя не найдены"
                    ])
                    return nil
                }
                
                let portfolio = userData["portfolio"] as? [String: Any] ?? [:]
                
                guard let stockData = portfolio[symbol] as? [String: Any],
                      let currentShares = stockData["shares"] as? Int,
                      currentShares >= shares else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "Недостаточно акций"
                    ])
                    return nil
                }
                
                let currentBalance = (userData["balance"] as? Double) ?? 0.0
                let saleAmount = Double(shares) * price
                let newBalance = currentBalance + saleAmount
                transaction.updateData(["balance": newBalance], forDocument: userRef)
                
                var newPortfolio = portfolio
                
                if currentShares == shares {
                    newPortfolio.removeValue(forKey: symbol)
                } else {
                    var updatedStock = stockData
                    updatedStock["shares"] = currentShares - shares
                    newPortfolio[symbol] = updatedStock
                }
                
                transaction.updateData(["portfolio": newPortfolio], forDocument: userRef)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        } completion: { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    self.updateLeaderboardAfterTransaction(uid: uid)
                    completion(true, nil)
                }
            }
        }
    }
    
    private func updateLeaderboardAfterTransaction(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self = self,
                  let data = snapshot?.data(),
                  let balance = data["balance"] as? Double,
                  let portfolio = data["portfolio"] as? [String: Any] else {
                return
            }
            
            let displayName = data["name"] as? String ?? "Пользователь"
            
            self.authViewModel?.updatePublicLeaderboard(
                uid: uid,
                balance: balance,
                portfolio: portfolio,
                displayName: displayName
            )
        }
    }
}
