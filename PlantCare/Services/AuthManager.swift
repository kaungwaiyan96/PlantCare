import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

@MainActor
final class AuthManager: NSObject, ObservableObject {
    @Published private(set) var isConfigured = false

    override init() {
        super.init()
        configureFirebase()
    }

    private func configureFirebase() {
        guard FirebaseApp.app() == nil else {
            isConfigured = true
            return
        }

        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            return
        }

        FirebaseApp.configure(options: options)
        isConfigured = true
    }

    func signUp(email: String, password: String, displayName: String) async throws -> User {
        try requireConfiguration()
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        return result.user
    }

    func signIn(email: String, password: String) async throws -> User {
        try requireConfiguration()
        return try await Auth.auth().signIn(withEmail: email, password: password).user
    }

    func signInWithGoogle() async throws -> User {
        try requireConfiguration()
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingGoogleClientID
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController())
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingGoogleIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        return try await Auth.auth().signIn(with: credential).user
    }

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }

    func userName(for user: User) -> String {
        if let displayName = user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines), !displayName.isEmpty {
            return displayName
        }
        return user.email?.components(separatedBy: "@").first?.capitalized ?? "Gardener"
    }

    private func requireConfiguration() throws {
        guard isConfigured else { throw AuthError.missingGoogleServiceInfo }
    }

    private func presentingViewController() -> UIViewController {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
        let root = scene?.keyWindow?.rootViewController ?? scene?.windows.first?.rootViewController
        return topViewController(from: root) ?? UIViewController()
    }

    private func topViewController(from controller: UIViewController?) -> UIViewController? {
        if let presented = controller?.presentedViewController { return topViewController(from: presented) }
        if let navigation = controller as? UINavigationController { return topViewController(from: navigation.visibleViewController) }
        if let tab = controller as? UITabBarController { return topViewController(from: tab.selectedViewController) }
        return controller
    }

    enum AuthError: LocalizedError {
        case missingGoogleServiceInfo, missingGoogleClientID, missingGoogleIDToken

        var errorDescription: String? {
            switch self {
            case .missingGoogleServiceInfo: return "Add GoogleService-Info.plist to the app target before signing in."
            case .missingGoogleClientID: return "The Firebase Google client ID is missing."
            case .missingGoogleIDToken: return "Google did not return an ID token."
            }
        }
    }
}
