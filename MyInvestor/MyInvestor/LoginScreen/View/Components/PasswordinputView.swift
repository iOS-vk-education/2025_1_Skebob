import SwiftUI
 
struct PasswordInputView: View {
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Пароль")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                if isPasswordVisible {
                    TextField("", text: $password)
                        .foregroundColor(.white)
                        .placeholder(when: password.isEmpty) {
                            Text("Введите пароль")
                                .foregroundColor(Color.gray.opacity(0.7))
                        }
                } else {
                    SecureField("", text: $password)
                        .foregroundColor(.white)
                        .placeholder(when: password.isEmpty) {
                            Text("Введите пароль")
                                .foregroundColor(Color.gray.opacity(0.7))
                        }
                }
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.1, green: 0.1, blue: 0.12)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(LinearGradient(gradient: Gradient(colors: [
                Color(red: 1.0, green: 0.5, blue: 0.0),
                Color(red: 0.9, green: 0.3, blue: 0.1)
            ]), startPoint: .leading, endPoint: .trailing), lineWidth: 1))
        }
    }
}
