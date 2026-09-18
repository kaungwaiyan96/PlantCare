import SwiftUI

/// Organic botanical viewfinder overlay inspired by Apple Visual Look Up & native camera interfaces.
/// Replaces harsh cyberpunk laser reticles with soft frosted glass framing and breathing focus cues.
struct GlassReticleOverlay: View {
    @State private var isBreathing = false
    var guidanceText: String = "Center a leaf, flower, or stem"

    var body: some View {
        ZStack {
            // Subtle ambient inner vignette
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.08)
                        ],
                        center: .center,
                        startRadius: 100,
                        endRadius: 220
                    )
                )

            // Organic Viewfinder Framing with specular glass rim
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            Color.botanicalSage.opacity(0.25),
                            Color.white.opacity(0.12),
                            Color.botanicalMint.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )

            // Soft organic corner brackets (curved, elegant, non-military)
            BotanicalCornerAccents()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.botanicalMint.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
                .padding(2)

            // Gentle center focus indicator (breathing botanical motif)
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.botanicalMint.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Color.botanicalMint.opacity(0.75))
            }
            .scaleEffect(isBreathing ? 1.06 : 0.94)
            .opacity(isBreathing ? 0.75 : 0.35)
            .animation(
                .easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                value: isBreathing
            )

            // Natural guidance pill at the bottom of the viewfinder
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "camera.macro")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.botanicalEmerald)

                    Text(guidanceText)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                .padding(.bottom, 22)
            }
        }
        .onAppear {
            isBreathing = true
        }
    }
}

/// Soft, rounded botanical corner markers replacing harsh sci-fi HUD brackets
struct BotanicalCornerAccents: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 26
        let r: CGFloat = 30

        // Top-Left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: rect.minY),
            tangent2End: CGPoint(x: rect.minX + length, y: rect.minY),
            radius: r
        )
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        // Top-Right
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
            tangent2End: CGPoint(x: rect.maxX, y: rect.minY + length),
            radius: r
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        // Bottom-Right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.maxX - length, y: rect.maxY),
            radius: r
        )
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        // Bottom-Left
        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.minX, y: rect.maxY - length),
            radius: r
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

        return path
    }
}
