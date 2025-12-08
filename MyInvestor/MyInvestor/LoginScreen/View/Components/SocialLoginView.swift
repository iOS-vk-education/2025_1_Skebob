import SwiftUI
struct SocialLoginView: View {
    let onAppleLogin: () -> Void
    let onFacebookLogin: () -> Void
    let onGoogleLogin: () -> Void
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onAppleLogin) {
                SocialButton(icon: "apple.logo", color: .white)
            }
            Button(action: onFacebookLogin) {
                SocialButton(icon: "f.circle.fill", color: .blue)
            }
            Button(action: onGoogleLogin) {
                SocialButton(icon: "g.circle.fill", color: .red)
            }
        }
    }
}
struct SocialButton: View {
    let icon: String
    let color: Color
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
                .frame(width: 50, height: 50)
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
        }
    }
}
