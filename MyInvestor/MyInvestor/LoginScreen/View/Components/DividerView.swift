import SwiftUI
struct DividerView: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            Text("или войти с помощью")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, 10)
    }
}
