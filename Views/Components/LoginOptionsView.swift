import SwiftUI
 
struct LoginOptionsView: View {
    @Binding var rememberMe: Bool
    let onForgotPassword: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Button(action: { rememberMe.toggle() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(rememberMe ? Color(red: 1.0, green: 0.5, blue: 0.0) : Color.gray.opacity(0.2))
                            .frame(width: 20, height: 20)
                        
                        if rememberMe {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Text("Запомнить меня")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button("Забыли пароль?", action: onForgotPassword)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
        }
    }
}
