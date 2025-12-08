import SwiftUI
 
struct DarkLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var rememberMe = false
    
    var body: some View {
        ZStack {
            LoginBackgroundView()
            
            ScrollView {
                VStack(spacing: 30) {
                    LoginHeaderView()
                    
                    LoginFormView(
                        email: $email,
                        password: $password,
                        isPasswordVisible: $isPasswordVisible,
                        rememberMe: $rememberMe,
                        authViewModel: authViewModel
                    )
                }
            }
            
            VStack {
                Spacer()
            }
        }
    }
}
