import SwiftUI
import Combine
 
final class LoginScreenViewModel: LoginScreenViewOutput, ObservableObject {
    weak var state: LoginScreenViewState?
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func login() {
        guard let state = state else { return }
        
        // Валидация
        guard !state.email.isEmpty else {
            state.errorMessage = "Введите email"
            return
        }
        
        guard !state.password.isEmpty else {
            state.errorMessage = "Введите пароль"
            return
        }
        
        guard state.email.contains("@") && state.email.contains(".") else {
            state.errorMessage = "Введите корректный email"
            return
        }
        
        guard state.password.count >= 6 else {
            state.errorMessage = "Пароль должен содержать не менее 6 символов"
            return
        }
        
        state.isLoading = true
        state.errorMessage = nil
        
        authService.login(email: state.email, password: state.password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self, let state = self.state else { return }
                
                state.isLoading = false
                
                switch result {
                case .success(let userEmail):
                    if state.rememberMe {
                        self.authService.saveSession(email: userEmail)
                    }
                    state.shouldNavigateToDashboard = true
                case .failure(let error):
                    state.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func handleForgotPassword() {
        print("Восстановление пароля вызвано")
    }
    
    func handleAppleLogin() {
        print("Вход через Apple вызван")
    }
    
    func handleFacebookLogin() {
        print("Вход через Facebook вызван")
    }
    
    func handleGoogleLogin() {
        print("Вход через Google вызван")
    }
    
    func handleSignUp() {
        print("Регистрация вызвана")
    }
}
