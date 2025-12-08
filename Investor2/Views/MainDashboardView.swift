import SwiftUI
 
struct MainDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutAlert = false
    @State private var userEmail: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Добро пожаловать в Myinvestor")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
 
                        if !userEmail.isEmpty {
                            Text("Вы авторизовались как: \(userEmail)")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
 
                    Spacer()
                    
                    // Кнопка выхода
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20))
                            
                            Text("Выйти")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.5, blue: 0.0),
                                    Color(red: 0.9, green: 0.3, blue: 0.1)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitle(Text("Dashboard"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showingLogoutAlert = true
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
            })
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Выйти"),
                    message: Text("Вы уверены, что хотите выйти?"),
                    primaryButton: .destructive(Text("Выйти")) {
                        authViewModel.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        }
    }
}
