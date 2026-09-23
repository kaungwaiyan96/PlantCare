import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userFirstName") private var userFirstName: String = ""
    @AppStorage("userEmail") private var userEmail: String = ""

    @State private var isSignUpMode: Bool = true
    @State private var firstNameInput: String = ""
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var confirmPasswordInput: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @StateObject private var authManager = AuthManager()

    @FocusState private var focusedField: AuthField?

    enum AuthField: Hashable {
        case firstName, email, password, confirmPassword
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {
                    // Header Botanical Brand Emblem
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.botanicalEmerald.opacity(0.2),
                                            Color.botanicalJade.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1.2)
                                )
                                .shadow(color: Color.botanicalEmerald.opacity(0.25), radius: 14, x: 0, y: 6)

                            Image(systemName: "leaf.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(.botanicalEmerald)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 4) {
                            Text("PlantCare")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Text("Scan, Identify, and Grow")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Liquid Glass Auth Card
                    VStack(spacing: 18) {
                        // Segmented Toggle: Sign In vs Sign Up
                        HStack(spacing: 0) {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    isSignUpMode = false
                                    errorMessage = nil
                                }
                            } label: {
                                Text("Sign In")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(!isSignUpMode ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(!isSignUpMode ? Color.white.opacity(0.3) : Color.clear)
                                    )
                            }

                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    isSignUpMode = true
                                    errorMessage = nil
                                }
                            } label: {
                                Text("Create Account")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(isSignUpMode ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(isSignUpMode ? Color.white.opacity(0.3) : Color.clear)
                                    )
                            }
                        }
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.primary.opacity(0.06))
                        )

                        // Error Banner (if any)
                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.12))
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Form Fields
                        VStack(spacing: 12) {
                            if isSignUpMode {
                                // First Name Field (Directly populates homepage greeting)
                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.botanicalEmerald)
                                        .frame(width: 20)
                                    TextField("Name", text: $firstNameInput)
                                        .textContentType(.name)
                                        .autocapitalization(.words)
                                        .focused($focusedField, equals: .firstName)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .email }
                                }
                                .padding(14)
                                .liquidGlass(cornerRadius: 16, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Email Field
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.botanicalEmerald)
                                    .frame(width: 20)
                                TextField("Email Address", text: $emailInput)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                            }
                            .padding(14)
                            .liquidGlass(cornerRadius: 16, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)

                            // Password Field
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.botanicalEmerald)
                                    .frame(width: 20)
                                if isPasswordVisible {
                                    TextField("Password", text: $passwordInput)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("Password", text: $passwordInput)
                                        .focused($focusedField, equals: .password)
                                }
                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(14)
                            .liquidGlass(cornerRadius: 16, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)

                            if isSignUpMode {
                                // Confirm Password Field
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundColor(.botanicalEmerald)
                                        .frame(width: 20)
                                    SecureField("Confirm Password", text: $confirmPasswordInput)
                                        .focused($focusedField, equals: .confirmPassword)
                                        .submitLabel(.done)
                                        .onSubmit { handleAuthAction() }
                                }
                                .padding(14)
                                .liquidGlass(cornerRadius: 16, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        // Primary Action Button
                        Button {
                            handleAuthAction()
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(isSignUpMode ? "Create Account" : "Sign In")
                                }
                            }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [Color.botanicalEmerald, Color.botanicalJade],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(18)
                                .shadow(color: Color.botanicalEmerald.opacity(0.35), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 4)

                        Button {
                            signInWithGoogle()
                        } label: {
                            HStack(spacing: 10) {
                                GoogleLogoView()
                                    .frame(width: 22, height: 22)
                                Text("Continue with Google")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.primary.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.primary.opacity(0.05)))
                        }

                        // Divider with text
                        HStack {
                            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 1)
                            Text("OR")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 1)
                        }
                        .padding(.vertical, 4)

                        // Guest / Quick Evaluator Bypass Button
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            if userFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                userFirstName = "Gardener"
                            }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isLoggedIn = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                Text("Continue as Guest")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.primary.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                        }
                    }
                    .padding(22)
                    .liquidGlass(cornerRadius: 28, material: .ultraThinMaterial, opacity: 0.92, hasSpecularBorder: true)
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 30)
                }
            }
            .ambientGlassBackground()
            .navigationBarHidden(true)
        }
    }

    // MARK: - Validation & Persistence Logic
    private func handleAuthAction() {
        guard !isLoading else { return }
        let generator = UINotificationFeedbackGenerator()
        errorMessage = nil

        if isSignUpMode {
            let cleanFirst = firstNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanFirst.isEmpty else {
                errorMessage = "Please enter your name."
                generator.notificationOccurred(.warning)
                return
            }
            guard isValidEmail(emailInput) else {
                errorMessage = "Please enter a valid email address."
                generator.notificationOccurred(.warning)
                return
            }
            guard passwordInput.count >= 6 else {
                errorMessage = "Password must be at least 6 characters."
                generator.notificationOccurred(.warning)
                return
            }
            guard passwordInput == confirmPasswordInput else {
                errorMessage = "Passwords do not match."
                generator.notificationOccurred(.warning)
                return
            }

            performAuth {
                try await authManager.signUp(
                    email: emailInput.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: passwordInput,
                    displayName: cleanFirst
                )
            }
        } else {
            // Sign In mode
            guard isValidEmail(emailInput) else {
                errorMessage = "Please enter your email."
                generator.notificationOccurred(.warning)
                return
            }
            guard !passwordInput.isEmpty else {
                errorMessage = "Please enter your password."
                generator.notificationOccurred(.warning)
                return
            }

            performAuth {
                try await authManager.signIn(
                    email: emailInput.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: passwordInput
                )
            }
        }

        _ = generator
    }

    private func isValidEmail(_ email: String) -> Bool {
        let value = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.contains("@") && value.contains(".") && !value.contains(" ")
    }

    private func performAuth(_ operation: @escaping () async throws -> FirebaseAuth.User) {
        isLoading = true
        Task {
            do {
                let user = try await operation()
                await MainActor.run {
                    userFirstName = authManager.userName(for: user)
                    userEmail = user.email ?? emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    isLoading = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) { isLoggedIn = true }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = readableError(error)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

    private func signInWithGoogle() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let user = try await authManager.signInWithGoogle()
                await MainActor.run { completeSignIn(with: user) }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = readableError(error)
                }
            }
        }
    }

    private func completeSignIn(with user: FirebaseAuth.User) {
        userFirstName = authManager.userName(for: user)
        userEmail = user.email ?? ""
        isLoading = false
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) { isLoggedIn = true }
    }

    private func readableError(_ error: Error) -> String {
        let nsError = error as NSError
        if let authError = AuthErrorCode(rawValue: nsError.code) {
            switch authError.code {
            case .emailAlreadyInUse: return "That email is already registered. Try signing in."
            case .invalidEmail: return "Please enter a valid email address."
            case .wrongPassword, .invalidCredential: return "The email or password is incorrect. Check that Email/Password is enabled in Firebase."
            case .userNotFound: return "No account exists for that email."
            case .networkError: return "Network error. Check your connection and try again."
            case .tooManyRequests: return "Too many attempts. Please wait and try again."
            default: break
            }
        }
        return error.localizedDescription
    }
}

private struct GoogleLogoView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) * 0.36
            let lineWidth = min(size.width, size.height) * 0.18
            let segments: [(Color, Double, Double)] = [
                (.blue, -45, 45),
                (.red, 45, 135),
                (.yellow, 135, 225),
                (.green, 225, 315)
            ]

            for (color, start, end) in segments {
                var arc = Path()
                arc.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(start),
                    endAngle: .degrees(end),
                    clockwise: false
                )
                context.stroke(arc, with: .color(color), lineWidth: lineWidth)
            }

            var bar = Path()
            bar.move(to: CGPoint(x: center.x, y: center.y))
            bar.addLine(to: CGPoint(x: size.width - 2, y: center.y))
            context.stroke(bar, with: .color(.blue), lineWidth: lineWidth)
        }
        .accessibilityHidden(true)
    }
}
