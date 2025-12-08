import SwiftUI
 
struct LoginFormView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var rememberMe: Bool
    var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = authViewModel.errorMessage {
                ErrorMessageView(message: errorMessage)
            }
            
            EmailInputView(email: $email)
            
            PasswordInputView(
                password: $password,
                isPasswordVisible: $isPasswordVisible
            )
            
            LoginOptionsView(
                rememberMe: $rememberMe,
                onForgotPassword: {
                    // Действие для восстановления пароля
                }
            )
            
            LoginButtonView(
                isLoading: authViewModel.isLoading,
                onLogin: {
                    authViewModel.login(email: email, password: password)
                }
            )
            
            DividerView()
            
            SocialLoginView()
            
            RegistrationView()
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
    }
}
