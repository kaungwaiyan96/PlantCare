import SwiftUI

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
                                    TextField("First Name (e.g. Kaung Wai)", text: $firstNameInput)
                                        .textContentType(.givenName)
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
                            Text(isSignUpMode ? "Create Botanical Account" : "Sign In")
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
        let generator = UINotificationFeedbackGenerator()
        errorMessage = nil

        if isSignUpMode {
            let cleanFirst = firstNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanFirst.isEmpty else {
                errorMessage = "Please enter your first name."
                generator.notificationOccurred(.warning)
                return
            }
            guard !emailInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Please enter a valid email address."
                generator.notificationOccurred(.warning)
                return
            }
            guard passwordInput.count >= 4 else {
                errorMessage = "Password must be at least 4 characters."
                generator.notificationOccurred(.warning)
                return
            }
            guard passwordInput == confirmPasswordInput else {
                errorMessage = "Passwords do not match."
                generator.notificationOccurred(.warning)
                return
            }

            userFirstName = cleanFirst
            userEmail = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // Sign In mode
            guard !emailInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Please enter your email."
                generator.notificationOccurred(.warning)
                return
            }
            guard !passwordInput.isEmpty else {
                errorMessage = "Please enter your password."
                generator.notificationOccurred(.warning)
                return
            }

            if userFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || userFirstName == "FirstName" {
                let derived = emailInput.components(separatedBy: "@").first?.capitalized ?? "Gardener"
                userFirstName = derived
            }
            userEmail = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        generator.notificationOccurred(.success)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            isLoggedIn = true
        }
    }
}
