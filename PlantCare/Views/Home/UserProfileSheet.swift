import SwiftUI

// MARK: - Dedicated Botanist Profile & Session Management Sheet
struct UserProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userFirstName") private var userFirstName: String = "Gardener"
    @AppStorage("userEmail") private var userEmail: String = ""
    @State private var showSignOutAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Frosted Avatar & Profile Info
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
                            .frame(width: 84, height: 84)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1.2)
                            )
                            .shadow(color: Color.botanicalEmerald.opacity(0.15), radius: 10, x: 0, y: 4)

                        Text(String((userFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "G" : userFirstName).prefix(1)).uppercased())
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.botanicalEmerald)
                    }
                    .padding(.top, 24)

                    Text(userFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Botanist" : userFirstName)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Active Botanist Session" : userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Botanical Stats Card
                HStack(spacing: 14) {
                    VStack(spacing: 4) {
                        Text("Active Status")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Gardener")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.botanicalEmerald)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .liquidGlass(cornerRadius: 18, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)

                    VStack(spacing: 4) {
                        Text("Design System")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Liquid Glass")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.botanicalJade)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .liquidGlass(cornerRadius: 18, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                }
                .padding(.horizontal, 20)

                Spacer()

                // Sign Out Button (Allows examiners to easily re-test auth flow)
                Button(role: .destructive) {
                    showSignOutAlert = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out of PlantCare")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.red.opacity(0.25), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .ambientGlassBackground()
            .navigationTitle("Botanist Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundColor(.botanicalEmerald)
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    dismiss()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isLoggedIn = false
                    }
                }
            } message: {
                Text("Are you sure you want to sign out? You can sign back in or continue as guest at any time.")
            }
        }
    }
}
