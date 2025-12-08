import SwiftUI
 
struct SocialLoginView: View {
    var body: some View {
        HStack(spacing: 20) {
            SocialButton(icon: "apple.logo", color: .white)
            SocialButton(icon: "f.circle.fill", color: .blue)
            SocialButton(icon: "g.circle.fill", color: .red)
        }
    }
}
