//
//  ProfileViewModel.swift
//  MyInvestor
//
//  Created by Максим Скориков on 06.03.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var birthday: Date = Date()
    @Published var birthdayText: String = ""
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false
    
    private let db = Firestore.firestore()
    private weak var authViewModel: AuthViewModel?
    
    init(authViewModel: AuthViewModel? = nil) {
        self.authViewModel = authViewModel
        loadUserData()
    }
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        self.userEmail = Auth.auth().currentUser?.email ?? ""
        db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                guard let data = snapshot?.data() else {
                    self.isLoading = false
                    return
                }
                DispatchQueue.main.async {
                    self.userName = data["name"] as? String ?? ""
                    
                    if let birthdayTimestamp = data["birthday"] as? Timestamp {
                        self.birthday = birthdayTimestamp.dateValue()
                        self.birthdayText = self.formatDateForInput(self.birthday)
                    } else {
                        self.birthday = Date()
                        self.birthdayText = self.formatDateForInput(Date())
                    }
                    
                    self.isLoading = false
                }
            }
    }
    
    private func formatDateForInput(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let day = String(format: "%02d", components.day ?? 1)
        let month = String(format: "%02d", components.month ?? 1)
        let year = components.year ?? 2000
        return "\(day).\(month).\(year)"
    }
    
    func saveProfile(completion: @escaping (Bool, String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Пользователь не авторизован")
            return
        }
        
        if userName.isEmpty {
            completion(false, "Введите имя")
            return
        }
        
        if userName.count < 2 {
            completion(false, "Имя должно быть не менее 2 символов")
            return
        }
        
        isSaving = true
        
        let updateData: [String: Any] = [
            "name": userName,
            "birthday": Timestamp(date: birthday)
        ]
        
        db.collection("users").document(uid)
            .updateData(updateData) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isSaving = false
                    
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        self?.authViewModel?.updatePublicLeaderboard(
                            uid: uid,
                            balance: 0,
                            portfolio: [:],
                            displayName: self?.userName ?? "Пользователь"
                        )
                        completion(true, nil)
                    }
                }
            }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            authViewModel?.isLoggedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
