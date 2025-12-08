import SwiftUI
 
struct DarkLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var rememberMe = false
    
    var body: some View {
        ZStack {
            // Фон
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            // Оранжевые градиентные акценты
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.05),
                    Color(red: 0.9, green: 0.3, blue: 0.1).opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Тонкие сеточные линии
            GeometryReader { geometry in
                Path { path in
                    for i in 0...Int(geometry.size.height / 50) {
                        let y = CGFloat(i) * 50
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    for i in 0...Int(geometry.size.width / 50) {
                        let x = CGFloat(i) * 50
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                }
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
            }
            
            // Динамические точки оранжевого цвета
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
            
            // Основной контент
            ScrollView {
                VStack(spacing: 30) {
                    // Логотип и заголовок
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
                    
                    // Форма входа
                    VStack(spacing: 20) {
                        if let errorMessage = authViewModel.errorMessage {
                            ErrorMessageView(message: errorMessage)
                        }
                        
                        // Поле email
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
                        
                        // Поле пароля
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                
                                if isPasswordVisible {
                                    TextField("", text: $password)
                                        .foregroundColor(.white)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Введите пароль")
                                                .foregroundColor(Color.gray.opacity(0.7))
                                        }
                                } else {
                                    SecureField("", text: $password)
                                        .foregroundColor(.white)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Введите пароль")
                                                .foregroundColor(Color.gray.opacity(0.7))
                                        }
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
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
                        
                        // Запомнить меня и забыли пароль
                        HStack {
                            HStack(spacing: 8) {
                                Button(action: {
                                    rememberMe.toggle()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(rememberMe ? Color(red: 1.0, green: 0.5, blue: 0.0) : Color.gray.opacity(0.2))
                                            .frame(width: 20, height: 20)
                                        
                                        if rememberMe {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                
                                Text("Запомнить меня")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button("Забыли пароль?") {
                                // Действие для восстановления пароля
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                        }
                        
                        // Кнопка входа
                        Button(action: {
                            authViewModel.login(email: email, password: password)
                        }) {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.5, blue: 0.0),
                                        Color(red: 0.9, green: 0.3, blue: 0.1)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: 55)
                                .cornerRadius(12)
                                .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.4), radius: 10, y: 5)
                                
                                if authViewModel.isLoading {
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
                        .disabled(authViewModel.isLoading)
                        
                        // Разделитель
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)
                            
                            Text("Продолжить")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 10)
                        
                        // Социальные сети
                        HStack(spacing: 20) {
                            SocialButton(icon: "apple.logo", color: .white)
                            SocialButton(icon: "f.circle.fill", color: .blue)
                            SocialButton(icon: "g.circle.fill", color: .red)
                        }
                        
                        // Регистрация
                        HStack(spacing: 5) {
                            Text("нет аккаунта?")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            
                            Button("Зарегестрироваться") {
                                // Переход к регистрации
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
            
            VStack {
                Spacer()
            }
        }
    }
}
