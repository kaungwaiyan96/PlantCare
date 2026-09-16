import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var material: Material
    var opacity: Double
    var content: Content

    init(
        cornerRadius: CGFloat = 24,
        material: Material = .ultraThinMaterial,
        opacity: Double = 0.85,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.material = material
        self.opacity = opacity
        self.content = content()
    }

    var body: some View {
        content
            .liquidGlass(
                cornerRadius: cornerRadius,
                material: material,
                opacity: opacity,
                hasSpecularBorder: true
            )
    }
}
