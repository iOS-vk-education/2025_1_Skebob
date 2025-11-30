import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoggedIn = false

    var body: some View {
        ZStack {
            Color(red: 245/255, green: 158/255, blue: 11/255)
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Text("ВХОД")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(height: 150)
                .background(Color(red: 30/255, green: 30/255, blue: 29/255))
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 194)
                        .padding(.top, 13)

                    VStack(spacing: 16) {
                        TextField("Почта", text: $email)
                            .keyboardType(.emailAddress)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 32)
                            .foregroundColor(Color(red: 30/255, green: 30/255, blue: 29/255))
                            .accentColor(Color(red: 30/255, green: 30/255, blue: 29/255))

                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField("Пароль", text: $password)
                                } else {
                                    SecureField("Пароль", text: $password)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .foregroundColor(Color(red: 30/255, green: 30/255, blue: 29/255))

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                            }
                        }
                        .frame(height: 44)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                    VStack {
                        Button(action: {
                            isLoggedIn = true
                        }) {
                            Text("Войти")
                                .font(.headline)
                                .foregroundColor(Color(red: 30/255, green: 30/255, blue: 29/255))
                                .frame(maxWidth: 298, maxHeight: 50)
                                .background(Color.white)
                                .cornerRadius(45)
                        }
                    }
                    .padding(.top, 56)
                    .padding(.horizontal)
                    Button(action: {
                        print("Нажата кнопка Забыли пароль?")
                    }) {
                        Text("Забыли пароль?")
                            .font(.body)
                            .underline()
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 74)
                    Button(action: {
                        print("Нажата кнопка Нет аккаунта? Зарегистрироваться?")
                    }) {
                        Text("Нет аккаунта?\nЗарегистрироваться")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .underline()
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .top)
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView()
        }
    }
}

#Preview {
    LoginView()
}
