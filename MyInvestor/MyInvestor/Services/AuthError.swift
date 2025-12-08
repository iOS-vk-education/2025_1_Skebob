import Foundation
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError
    case validationError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Неверный email или пароль"
        case .networkError:
            return "Ошибка сети"
        case .validationError:
            return "Ошибка валидации"
        }
    }
}
