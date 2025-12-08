import SwiftUI
 
final class LoginScreenAssembly {
    func assemble() -> some View {
        let state = LoginScreenViewState()
        let authService = AuthService()
        let viewModel = LoginScreenViewModel(authService: authService)
        viewModel.state = state
        let view = LoginScreenView(state: state, viewModel: viewModel)
        return view
    }
}
