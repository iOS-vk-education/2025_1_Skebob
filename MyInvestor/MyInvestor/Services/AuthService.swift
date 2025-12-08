import Foundation
import Combine
 
class AuthService: AuthServiceProtocol, ObservableObject {
    private let demoUsers = [
        User(email: "admin@example.com", password: "password123"),
        User(email: "trader@example.com", password: "crypto2024"),
        User(email: "user@example.com", password: "securepass")
    ]
    
    func login(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            let isValidUser = self.demoUsers.contains { user in
                user.email.lowercased() == email.lowercased() && user.password == password
            }
            
            DispatchQueue.main.async {
                if isValidUser {
                    completion(.success(email))
                } else {
                    completion(.failure(.invalidCredentials))
                }
            }
        }
    }
    
    func saveSession(email: String) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(email, forKey: "userEmail")
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    
    func hasActiveSession() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func getSavedEmail() -> String? {
        return UserDefaults.standard.string(forKey: "userEmail")
    }
}
