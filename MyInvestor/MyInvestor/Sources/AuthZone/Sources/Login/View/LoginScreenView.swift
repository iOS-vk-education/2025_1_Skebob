import SwiftUI
import FirebaseAuth
import FirebaseFirestore
 
// ViewModel для авторизации
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isCheckingSession = true
    @Published var errorMessage: String?
    @Published var isLoading = false

    func login(email: String, password: String) {
        errorMessage = nil
        isLoading = true

        guard !email.isEmpty else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Введите e-mail"
            }
            return
        }
        guard !password.isEmpty else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Введите пароль"
            }
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if error != nil {
                    self?.errorMessage = "Неверная почта или пароль"
                    return
                }
                self?.isLoggedIn = true
                self?.initializeUserDataIfNeeded()
            }
        }
    }
    
    func register(email: String, password: String, confirmPassword: String, completion: @escaping (String?) -> Void) {
        // Валидация
        guard !email.isEmpty else {
            completion("Введите email")
            return
        }
        guard email.contains("@") && email.contains(".") else {
            completion("Введите корректный email")
            return
        }
        guard !password.isEmpty else {
            completion("Введите пароль")
            return
        }
        guard password.count >= 6 else {
            completion("Пароль должен быть не менее 6 символов")
            return
        }
        guard password == confirmPassword else {
            completion("Пароли не совпадают")
            return
        }

        // Firebase
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    let message: String
                    if let authError = error as? AuthErrorCode {
                        switch authError {
                        case .emailAlreadyInUse:
                            message = "Email уже используется"
                        case .invalidEmail:
                            message = "Недействительный email"
                        case .weakPassword:
                            message = "Пароль слишком слабый"
                        default:
                            message = "Ошибка регистрации"
                        }
                    } else {
                        message = "Не удалось создать аккаунт"
                    }
                    completion(message)
                } else {
                    self?.initializeUserDataIfNeeded()
                    if let uid = Auth.auth().currentUser?.uid {
                        self?.db.collection("users").document(uid).getDocument { snapshot, _ in
                            if let data = snapshot?.data(),
                               let balance = data["balance"] as? Double,
                               let portfolio = data["portfolio"] as? [String: Any] {
                                self?.updatePublicLeaderboard(uid: uid, balance: balance, portfolio: portfolio)
                            }
                        }
                    }
                    completion(nil)
                }
            }
        }
    }
    
    private let db = Firestore.firestore()

    func initializeUserDataIfNeeded() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Ошибка Firestore: \(error)")
                return
            }
            
            if !(snapshot?.exists ?? false) {
                self?.db.collection("users").document(uid).setData([
                    "balance": 1000.0,
                    "favoriteStocks": [] as [String],
                    "portfolio": [:] as [String: Any],
                    "createdAt": FieldValue.serverTimestamp()
                ])
            }
        }
    }
    
    private func updatePublicLeaderboard(uid: String, balance: Double, portfolio: [String: Any]) {
        let portfolioSummary = portfolio.mapValues { stock in
            if let stockDict = stock as? [String: Any],
               let shares = stockDict["shares"] as? Int {
                return ["shares": shares] as [String: Any]
            }
            return [:]
        } as? [String: [String: Any]] ?? [:]
        
        let publicData: [String: Any] = [
            "balance": balance,
            "portfolioSummary": portfolioSummary,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("publicLeaderboard")
            .document(uid)
            .setData(publicData, merge: true)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: "userEmail")
        } catch {
            print("Ошибка при выходе: $error)")
        }
    }

    func checkSession() {
        isCheckingSession = false
        if let user = Auth.auth().currentUser {
            isLoggedIn = true
            initializeUserDataIfNeeded()
        }
    }
    
    func buyStock(symbol: String, shares: Int, price: Double, completion: @escaping (Bool, String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Пользователь не авторизован")
            return
        }

        let totalCost = Double(shares) * price
        if totalCost <= 0 {
            completion(false, "Некорректное количество или цена")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let document = try transaction.getDocument(userRef)
                guard let userData = document.data() else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Данные пользователя не найдены"
                    ])
                    return nil
                }
                
                let currentBalance = (userData["balance"] as? Double) ?? 0.0
                
                guard currentBalance >= totalCost else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "Недостаточно средств"
                    ])
                    return nil
                }

                let newBalance = currentBalance - totalCost
                transaction.updateData(["balance": newBalance], forDocument: userRef)
                var portfolio = userData["portfolio"] as? [String: Any] ?? [:]
                if var existing = portfolio[symbol] as? [String: Any] {
                    let currentShares = (existing["shares"] as? Int) ?? 0
                    let currentAvgPrice = (existing["avgPrice"] as? Double) ?? 0.0

                    let newShares = currentShares + shares
                    let newAvgPrice = ((currentAvgPrice * Double(currentShares)) + totalCost) / Double(newShares)

                    existing["shares"] = newShares
                    existing["avgPrice"] = newAvgPrice
                    portfolio[symbol] = existing
                } else {
                    portfolio[symbol] = [
                        "shares": shares,
                        "avgPrice": price
                    ]
                }

                transaction.updateData(["portfolio": portfolio], forDocument: userRef)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        } completion: { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    self.db.collection("users").document(uid).getDocument { snapshot, _ in
                        if let data = snapshot?.data(),
                           let balance = data["balance"] as? Double,
                           let portfolio = data["portfolio"] as? [String: Any] {
                            self.updatePublicLeaderboard(uid: uid, balance: balance, portfolio: portfolio)
                        }
                    }
                    completion(true, nil)
                }
            }
        }
    }
    
    func sellStock(symbol: String, shares: Int, price: Double, completion: @escaping (Bool, String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Пользователь не авторизован")
            return
        }

        if shares <= 0 {
            completion(false, "Некорректное количество")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let document = try transaction.getDocument(userRef)
                guard let userData = document.data() else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Данные пользователя не найдены"
                    ])
                    return nil
                }

                let portfolio = userData["portfolio"] as? [String: Any] ?? [:]
                
                guard let stockData = portfolio[symbol] as? [String: Any],
                      let currentShares = stockData["shares"] as? Int,
                      currentShares >= shares else {
                    errorPointer?.pointee = NSError(domain: "MyInvestor", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "Недостаточно акций"
                    ])
                    return nil
                }

                let currentBalance = (userData["balance"] as? Double) ?? 0.0
                let saleAmount = Double(shares) * price
                let newBalance = currentBalance + saleAmount
                transaction.updateData(["balance": newBalance], forDocument: userRef)

                var newPortfolio = portfolio
                
                if currentShares == shares {
                    newPortfolio.removeValue(forKey: symbol)
                } else {
                    var updatedStock = stockData
                    updatedStock["shares"] = currentShares - shares
                    if let avgPrice = updatedStock["avgPrice"] as? Double {
                        updatedStock["avgPrice"] = avgPrice
                    }
                    
                    newPortfolio[symbol] = updatedStock
                }

                transaction.updateData(["portfolio": newPortfolio], forDocument: userRef)
                return nil
                
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        } completion: { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    let errorMessage = error.localizedDescription.contains("Недостаточно акций")
                        ? "Недостаточно акций"
                        : "Ошибка при продаже: \(error.localizedDescription)"
                    completion(false, errorMessage)
                } else {
                    self.db.collection("users").document(uid).getDocument { snapshot, _ in
                        if let data = snapshot?.data(),
                           let balance = data["balance"] as? Double,
                           let portfolio = data["portfolio"] as? [String: Any] {
                            self.updatePublicLeaderboard(uid: uid, balance: balance, portfolio: portfolio)
                        }
                    }
                    completion(true, nil)
                }
            }
        }
    }
}
 
// Главный View

struct LoginScreenView: View {
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
                                        Text("Введите почту")
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
                            Text("Нет аккаунта?")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            
                            NavigationLink("Зарегистрироваться", destination: RegisterScreenView())
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
 
struct SocialButton: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Авторизация через соцсеть
        }) {
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
}
 
struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.2, green: 0.1, blue: 0.1).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
    }
}
 
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}
 
// Preview
struct DarkLoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
            .environmentObject(AuthViewModel())
    }
}
