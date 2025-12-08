import SwiftUI
 
struct LoginButtonView: View {
    let isLoading: Bool
    let onLogin: () -> Void
    
    var body: some View {
        Button(action: onLogin) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.0),
                    Color(red: 0.9, green: 0.3, blue: 0.1)
                ]), startPoint: .leading, endPoint: .trailing)
                    .frame(height: 55)
                    .cornerRadius(12)
                    .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.4), radius: 10, y: 5)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    HStack(spacing: 10) {
                        Text("Войти")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .disabled(isLoading)
    }
}
