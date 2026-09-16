import SwiftUI

extension Color {
    static let botanicalEmerald = Color(hex: 0x0D5C3B)
    static let botanicalSage = Color(hex: 0x87A96B)
    static let botanicalJade = Color(hex: 0x2E8B57)
    static let botanicalMint = Color(hex: 0x52B788)
    static let botanicalAmber = Color(hex: 0xE67E22)
    static let glassBackgroundDark = Color(hex: 0x0A1810)
    static let glassBackgroundLight = Color(hex: 0xF2F7F4)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

/// Ambient botanical background glow mesh modifier for Liquid Glass aesthetic
struct AmbientGlassBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base color
                    (colorScheme == .dark ? Color.glassBackgroundDark : Color.glassBackgroundLight)
                        .ignoresSafeArea()

                    // Ambient glowing mesh blobs
                    GeometryReader { proxy in
                        let size = proxy.size
                        ZStack {
                            Circle()
                                .fill(Color.botanicalEmerald.opacity(colorScheme == .dark ? 0.35 : 0.25))
                                .frame(width: size.width * 0.8, height: size.width * 0.8)
                                .blur(radius: 80)
                                .offset(x: -size.width * 0.2, y: -size.height * 0.15)

                            Circle()
                                .fill(Color.botanicalJade.opacity(colorScheme == .dark ? 0.3 : 0.2))
                                .frame(width: size.width * 0.7, height: size.width * 0.7)
                                .blur(radius: 70)
                                .offset(x: size.width * 0.3, y: size.height * 0.2)

                            Circle()
                                .fill(Color.botanicalSage.opacity(colorScheme == .dark ? 0.25 : 0.15))
                                .frame(width: size.width * 0.6, height: size.width * 0.6)
                                .blur(radius: 60)
                                .offset(x: -size.width * 0.15, y: size.height * 0.4)

                            Circle()
                                .fill(Color.botanicalMint.opacity(colorScheme == .dark ? 0.2 : 0.12))
                                .frame(width: size.width * 0.5, height: size.width * 0.5)
                                .blur(radius: 50)
                                .offset(x: size.width * 0.25, y: -size.height * 0.35)
                        }
                        .frame(width: size.width, height: size.height)
                    }
                    .ignoresSafeArea()
                }
            )
    }
}

extension View {
    func ambientGlassBackground() -> some View {
        modifier(AmbientGlassBackground())
    }
}
