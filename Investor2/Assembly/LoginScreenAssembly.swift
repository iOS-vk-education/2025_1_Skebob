import SwiftUI
 
final class LoginScreenAssembly {
    func assemble() -> some View {
        let authViewModel = AuthViewModel()
        return ContentView(authViewModel: authViewModel)
    }
}
