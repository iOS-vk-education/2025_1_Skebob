import SwiftUI
 
struct GridView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Горизонтальные линии
                for i in 0...Int(geometry.size.height / 50) {
                    let y = CGFloat(i) * 50
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                // Вертикальные линии
                for i in 0...Int(geometry.size.width / 50) {
                    let x = CGFloat(i) * 50
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
            }
            .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
        }
    }
}
