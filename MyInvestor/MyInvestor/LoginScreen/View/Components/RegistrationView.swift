import SwiftUI
struct RegistrationView: View {
    let onSignUp: () -> Void
    var body: some View {
        HStack(spacing: 5) {
            Text("Нет аккаунта?")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Button("Зарегистрироваться", action: onSignUp)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
        }
        .padding(.top, 10)
    }
}
