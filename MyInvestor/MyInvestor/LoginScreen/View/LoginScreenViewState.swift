import SwiftUI
import Combine
 
final class LoginScreenViewState: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToDashboard: Bool = false
}
