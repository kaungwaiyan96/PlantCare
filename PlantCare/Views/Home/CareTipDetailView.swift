import SwiftUI

struct CareTipDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let tip: PlantCareTip

    @State private var hasMarkedAsRead: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    // Hero Icon & Category Header
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            // Large 64x64 Flaticon Icon Squircle
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                tip.themeColor.opacity(0.28),
                                                tip.themeColor.opacity(0.10)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(tip.themeColor.opacity(0.4), lineWidth: 1.5)
                                    )

                                if let image = loadIconImage(named: tip.iconName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 36, height: 36)
                                } else {
                                    Image(systemName: tip.fallbackSymbol)
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(tip.themeColor)
                                }
                            }
                            .frame(width: 64, height: 64)
                            .shadow(color: tip.themeColor.opacity(0.25), radius: 10, x: 0, y: 4)

                            Spacer()

                            // Close Button
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    )
                            }
                        }

                        // Category Pill & Read Time
                        HStack(spacing: 8) {
                            Text(tip.category.uppercased())
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .tracking(1.2)
                                .foregroundColor(tip.themeColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(tip.themeColor.opacity(0.16))
                                )

                            Text("•")
                                .foregroundColor(.secondary.opacity(0.5))

                            Text(tip.readTime)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary.opacity(0.5))

                            Text(tip.difficulty)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.botanicalEmerald)
                        }

                        // Title & Subtitle
                        VStack(alignment: .leading, spacing: 6) {
                            Text(tip.title)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Text(tip.subtitle)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // The Botanical Science Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(tip.themeColor)
                            Text("The Science & Why It Matters")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }

                        Text(tip.theScience)
                            .font(.system(size: 14, weight: .regular))
                            .lineSpacing(4)
                            .foregroundColor(.primary.opacity(0.82))
                    }
                    .padding(18)
                    .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                    .padding(.horizontal, 20)

                    // Step-by-Step Instructions
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Step-by-Step Execution")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            ForEach(tip.steps) { step in
                                HStack(alignment: .top, spacing: 14) {
                                    // Step Number Bubble
                                    ZStack {
                                        Circle()
                                            .fill(tip.themeColor.opacity(0.18))
                                            .frame(width: 32, height: 32)
                                        Text("\(step.stepNumber)")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(tip.themeColor)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(step.title)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)

                                        Text(step.instruction)
                                            .font(.system(size: 13, weight: .regular))
                                            .lineSpacing(3)
                                            .foregroundColor(.primary.opacity(0.78))
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .liquidGlass(cornerRadius: 18, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // Best Suited Species
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.botanicalEmerald)
                            Text("Best Suited Botanical Species")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(tip.suitablePlants, id: \.self) { plant in
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.botanicalEmerald)
                                        Text(plant)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .liquidGlass(cornerRadius: 14, material: .thinMaterial, opacity: 0.75, hasSpecularBorder: true)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Expert Pro Tip Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.botanicalAmber)
                            Text("Horticulturist Pro Tip")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }

                        Text(tip.proTip)
                            .font(.system(size: 13, weight: .regular))
                            .lineSpacing(3.5)
                            .foregroundColor(.primary.opacity(0.82))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.botanicalAmber.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.botanicalAmber.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Action Button: Done / Mark As Learned
                    Button {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            hasMarkedAsRead = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: hasMarkedAsRead ? "checkmark.circle.fill" : "book.closed.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text(hasMarkedAsRead ? "Mastered!" : "Mark as Completed")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.botanicalEmerald, Color.botanicalJade],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.botanicalEmerald.opacity(0.35), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 36)
                }
            }
            .ambientGlassBackground()
            .navigationBarHidden(true)
        }
    }

    private func loadIconImage(named name: String) -> UIImage? {
        if let asset = UIImage(named: name) {
            return asset
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Icons") {
            return UIImage(contentsOfFile: path)
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Resources/Icons") {
            return UIImage(contentsOfFile: path)
        }
        let directPath = "PlantCare/Resources/Icons/\(name).png"
        if FileManager.default.fileExists(atPath: directPath) {
            return UIImage(contentsOfFile: directPath)
        }
        return nil
    }
}
