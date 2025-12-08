import SwiftUI
 
struct LoginBackgroundView: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.05),
                    Color(red: 0.9, green: 0.3, blue: 0.1).opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            GridView()
            DecorativeCirclesView()
        }
    }
}
