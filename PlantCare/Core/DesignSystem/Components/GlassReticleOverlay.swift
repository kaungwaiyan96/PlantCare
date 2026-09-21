import SwiftUI

/// Clean, high-precision camera viewfinder overlay matching `camera_scan.mp4`.
/// Features a continuous 24pt white rounded rectangular border,
/// oscillating glowing white laser scanning beam, coordinate twinkling sparkles & crosshairs (`✦` / `+`),
/// and torch illumination effect.
struct GlassReticleOverlay: View {
    var isScanning: Bool = false
    var isTorchOn: Bool = false

    @State private var scanProgress: CGFloat = 0.0
    @State private var sparklePulse: Bool = false
    @State private var isBreathing: Bool = false

    var body: some View {
        ZStack {
            // 1. Torch Optical Illumination Cone (Active when Torch is Toggled On)
            if isTorchOn {
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        Color.botanicalAmber.opacity(0.08),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 30,
                    endRadius: 260
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .transition(.opacity)
            }

            // 2. Subtle Dark Vignette & Edge Shadowing
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.16)
                        ],
                        center: .center,
                        startRadius: 100,
                        endRadius: 240
                    )
                )

            // 3. Coordinate Twinkling Sparkles & Precision Crosshairs (✦ / +)
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    // Top-Left: Star Sparkle ✦
                    SparkleMarker(symbol: "✦", size: 14, isPulsing: sparklePulse, delay: 0.0)
                        .position(x: w * 0.22, y: h * 0.24)

                    // Top-Right: Precision Crosshair +
                    SparkleMarker(symbol: "+", size: 16, isPulsing: sparklePulse, delay: 0.3)
                        .position(x: w * 0.78, y: h * 0.26)

                    // Center Focus Sparkle ✦
                    SparkleMarker(symbol: "✦", size: 18, isPulsing: sparklePulse, delay: 0.6)
                        .position(x: w * 0.50, y: h * 0.48)

                    // Bottom-Left: Precision Crosshair +
                    SparkleMarker(symbol: "+", size: 15, isPulsing: sparklePulse, delay: 0.2)
                        .position(x: w * 0.25, y: h * 0.70)

                    // Bottom-Right: Star Sparkle ✦
                    SparkleMarker(symbol: "✦", size: 14, isPulsing: sparklePulse, delay: 0.5)
                        .position(x: w * 0.76, y: h * 0.66)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            // 4. Luminous Sweeping Laser Scanning Bar (Moves Up & Down when Scanning)
            if isScanning {
                GeometryReader { geo in
                    let height = geo.size.height
                    let minY: CGFloat = 20
                    let maxY: CGFloat = height - 20
                    let barY = minY + (maxY - minY) * scanProgress

                    ZStack {
                        // Wide ambient feathered laser aura
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.18),
                                Color.botanicalMint.opacity(0.35),
                                Color.white.opacity(0.18),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 36)

                        // Core bright white laser beam line
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white,
                                        Color.white.opacity(0.4)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2.2)
                            .shadow(color: Color.white, radius: 6, x: 0, y: 0)
                            .shadow(color: Color.botanicalMint, radius: 10, x: 0, y: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .position(x: geo.size.width / 2, y: barY)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .transition(.opacity)
            }

            // 5. Idle Subtle Center Reticle (When not scanning)
            if !isScanning {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
                        .frame(width: 48, height: 48)

                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(Color.white.opacity(0.65))
                }
                .scaleEffect(isBreathing ? 1.06 : 0.94)
                .opacity(isBreathing ? 0.75 : 0.3)
            }

            // 6. Continuous Crisp White Viewfinder Border (Clean 24pt radius, 2.2pt stroke matching camera_scan.mp4)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white, lineWidth: 2.2)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
        .onChange(of: isScanning) { _, scanning in
            if scanning {
                scanProgress = 0.0
                sparklePulse = false
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    scanProgress = 1.0
                }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    sparklePulse = true
                }
            } else {
                scanProgress = 0.0
                sparklePulse = false
            }
        }
    }
}

/// Dynamic coordinate sparkle marker supporting star (`✦`) and precision crosshair (`+`)
private struct SparkleMarker: View {
    let symbol: String
    let size: CGFloat
    let isPulsing: Bool
    let delay: Double

    @State private var localActive = false

    var body: some View {
        Text(symbol)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(Color.white)
            .shadow(color: Color.white.opacity(0.85), radius: 6, x: 0, y: 0)
            .shadow(color: Color.botanicalMint.opacity(0.6), radius: 10, x: 0, y: 0)
            .scaleEffect(localActive ? 1.25 : 0.85)
            .opacity(localActive ? 0.95 : 0.25)
            .onAppear {
                if isPulsing {
                    triggerPulse()
                }
            }
            .onChange(of: isPulsing) { _, pulsing in
                if pulsing {
                    triggerPulse()
                } else {
                    localActive = false
                }
            }
    }

    private func triggerPulse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                localActive = true
            }
        }
    }
}
