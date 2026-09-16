import SwiftUI

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var material: Material
    var opacity: Double
    var hasSpecularBorder: Bool

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(material)
                        .opacity(opacity)

                    if hasSpecularBorder {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),
                                        .white.opacity(0.25),
                                        .clear,
                                        .white.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}

extension View {
    func liquidGlass(
        cornerRadius: CGFloat = 24,
        material: Material = .ultraThinMaterial,
        opacity: Double = 0.85,
        hasSpecularBorder: Bool = true
    ) -> some View {
        modifier(LiquidGlassModifier(
            cornerRadius: cornerRadius,
            material: material,
            opacity: opacity,
            hasSpecularBorder: hasSpecularBorder
        ))
    }
}
