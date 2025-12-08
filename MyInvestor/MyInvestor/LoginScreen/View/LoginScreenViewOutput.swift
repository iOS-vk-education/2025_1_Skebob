protocol LoginScreenViewOutput: AnyObject {
    var state: LoginScreenViewState? { get set }
    func login()
    func handleForgotPassword()
    func handleAppleLogin()
    func handleFacebookLogin()
    func handleGoogleLogin()
    func handleSignUp()
}
