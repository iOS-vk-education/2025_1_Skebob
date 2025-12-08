import SwiftUI
 
struct EmailInputView: View {
    @Binding var email: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField("", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
                    .placeholder(when: email.isEmpty) {
                        Text("your.email@example.com")
                            .foregroundColor(Color.gray.opacity(0.7))
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.5, blue: 0.0),
                                Color(red: 0.9, green: 0.3, blue: 0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
}
