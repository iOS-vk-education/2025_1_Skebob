import SwiftUI
 
struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainDashboardView()
                    .environmentObject(authViewModel)
            } else {
                DarkLoginView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkSession()
        }
    }
}
