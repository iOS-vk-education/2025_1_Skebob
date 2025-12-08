import SwiftUI
 
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let demoUsers = [
        User(email: "admin@example.com", password: "password123")
    ]
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            guard !email.isEmpty else {
                self.errorMessage = "Введите e-mail"
                return
            }
            
            guard !password.isEmpty else {
                self.errorMessage = "Введите пароль"
                return
            }
            
            guard email.contains("@") && email.contains(".") else {
                self.errorMessage = "Введите действительный e-mail"
                return
            }
            
            guard password.count >= 6 else {
                self.errorMessage = "Пароль не может быть меньше 6 символов"
                return
            }
            
            let isValidUser = self.demoUsers.contains { user in
                user.email.lowercased() == email.lowercased() && user.password == password
            }
            
            if isValidUser {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isLoggedIn = true
                }
                
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(email, forKey: "userEmail")
            } else {
                self.errorMessage = "Недействительный e-mail или пароль"
            }
        }
    }
    
    func logout() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isLoggedIn = false
        }
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    
    func checkSession() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isLoggedIn = true
                }
            }
        }
    }
}
