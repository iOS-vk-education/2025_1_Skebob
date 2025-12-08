import SwiftUI
 
struct LoginHeaderView: View {
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.5, blue: 0.0),
                                Color(red: 0.9, green: 0.3, blue: 0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.5), radius: 15)
                
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text("MyInvestor")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.3), radius: 10)
        }
        .padding(.top, 50)
    }
}
