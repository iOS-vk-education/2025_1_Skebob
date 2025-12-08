import SwiftUI
struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                DashboardView(onLogout: {
                    authService.logout()
                    isLoggedIn = false
                })
            } else {
                LoginScreenAssembly().assemble()
                    .onChange(of: authService.hasActiveSession()) { newValue in
                        isLoggedIn = newValue
                    }
            }
        }
        .onAppear {
            isLoggedIn = authService.hasActiveSession()
        }
    }
}
