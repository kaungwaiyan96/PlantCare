import SwiftUI

struct GlassReticleOverlay: View {
    @State private var isScanning = false
    var guidanceText: String = "Align plant within the reticle"

    var body: some View {
        ZStack {
            // Darkened vignette outside reticle
            Color.black.opacity(0.35)
                .mask(
                    Rectangle()
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .frame(width: 280, height: 380)
                                .blendMode(.destinationOut)
                        )
                )
                .ignoresSafeArea()

            // Reticle frame and corner brackets
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 280, height: 380)

                // Animated Corner Brackets [ ]
                CornerBrackets()
                    .stroke(Color.botanicalMint, lineWidth: 3.5)
                    .frame(width: 288, height: 388)
                    .shadow(color: Color.botanicalMint.opacity(0.8), radius: 10)

                // Laser scan line
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color.botanicalMint, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2.5)
                        .shadow(color: Color.botanicalMint, radius: 8)
                        .offset(y: isScanning ? 180 : -180)
                        .animation(
                            Animation.easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                            value: isScanning
                        )
                }
                .frame(width: 280, height: 380)
                .clipped()

                // Guidance text at bottom of reticle
                VStack {
                    Spacer()
                    Text(guidanceText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .liquidGlass(cornerRadius: 20, material: .thinMaterial, opacity: 0.9, hasSpecularBorder: true)
                        .padding(.bottom, 28)
                }
                .frame(width: 280, height: 380)
            }
        }
        .onAppear {
            isScanning = true
        }
    }
}

struct CornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 36
        let r: CGFloat = 32

        // Top-Left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.minX + length, y: rect.minY), radius: r)
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        // Top-Right
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.minY + length), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        // Bottom-Right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX - length, y: rect.maxY), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        // Bottom-Left
        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.maxY - length), radius: r)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

        return path
    }
}
