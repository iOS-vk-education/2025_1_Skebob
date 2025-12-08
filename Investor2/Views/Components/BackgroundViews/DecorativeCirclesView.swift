import SwiftUI
 
struct DecorativeCirclesView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -150, y: -300)
            
            Circle()
                .fill(Color(red: 0.9, green: 0.3, blue: 0.1).opacity(0.3))
                .frame(width: 150, height: 150)
                .blur(radius: 50)
                .offset(x: 150, y: 300)
            
            Circle()
                .fill(Color(red: 1.0, green: 0.7, blue: 0.0).opacity(0.2))
                .frame(width: 100, height: 100)
                .blur(radius: 40)
                .offset(x: 100, y: -200)
        }
    }
}
