import Foundation
 
protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void)
    func saveSession(email: String)
    func logout()
    func hasActiveSession() -> Bool
    func getSavedEmail() -> String?
}
