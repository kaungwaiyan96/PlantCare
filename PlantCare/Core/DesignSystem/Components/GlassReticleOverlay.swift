import SwiftUI

/// World-class Apple HIG camera viewfinder overlay for botanical specimen scanning.
/// Features precision corner brackets, subtle hairline frame, breathing autofocus reticle,
/// ethereal scanning laser bar with feathered gradient aura, and detection keypoint nodes.
struct GlassReticleOverlay: View {
    var isScanning: Bool = false
    var isTorchOn: Bool = false

    @State private var scanProgress: CGFloat = 0.0
    @State private var isBreathing: Bool = false
    @State private var keypointPulse: Bool = false

    var body: some View {
        ZStack {
            // 1. Torch Optical Illumination Cone (when flash/torch is active)
            if isTorchOn {
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.24),
                        Color.botanicalAmber.opacity(0.10),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 280
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .transition(.opacity)
            }

            // 2. Optical Edge Vignette (subtle contrast enhancement framing the specimen)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.22)
                        ],
                        center: .center,
                        startRadius: 90,
                        endRadius: 260
                    )
                )

            // 3. Ultra-fine Continuous Hairline Viewport Border
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )

            // 4. Precision Corner Brackets (Apple HIG Pro Camera Aesthetic)
            CornerBracketsShape(bracketLength: 28, cornerRadius: 18)
                .stroke(
                    isScanning
                        ? LinearGradient(
                            colors: [Color.botanicalMint, Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.95), Color.white.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                    style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round)
                )
                .shadow(
                    color: isScanning ? Color.botanicalMint.opacity(0.6) : Color.black.opacity(0.25),
                    radius: isScanning ? 6 : 2,
                    x: 0,
                    y: 0
                )
                .padding(10)
                .animation(.easeInOut(duration: 0.3), value: isScanning)

            // 5. Idle Autofocus Target Reticle (Subtle breathing ring when camera is ready)
            if !isScanning {
                autofocusIndicator
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            // 6. Computer Vision Keypoint Detection Nodes (Micro-dots indicating AI point tracking)
            if isScanning {
                keypointOverlay
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .transition(.opacity)
            }

            // 7. Ethereal Sweeping Laser Beam (Smooth vertical pass during AI inference)
            if isScanning {
                GeometryReader { geo in
                    let height = geo.size.height
                    let minY: CGFloat = 16
                    let maxY: CGFloat = height - 16
                    let currentY = minY + (maxY - minY) * scanProgress

                    ZStack {
                        // Ambient feathered laser aura
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.botanicalMint.opacity(0.22),
                                Color.white.opacity(0.35),
                                Color.botanicalMint.opacity(0.22),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 36)

                        // High-intensity core laser blade
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.botanicalMint.opacity(0.2),
                                        Color.white,
                                        Color.botanicalMint.opacity(0.2)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2.0)
                            .shadow(color: Color.white, radius: 4, x: 0, y: 0)
                            .shadow(color: Color.botanicalMint, radius: 8, x: 0, y: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .position(x: geo.size.width / 2, y: currentY)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
        .onChange(of: isScanning) { _, scanning in
            if scanning {
                scanProgress = 0.0
                keypointPulse = false
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    scanProgress = 1.0
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    keypointPulse = true
                }
            } else {
                scanProgress = 0.0
                keypointPulse = false
            }
        }
    }

    // MARK: - Subcomponents

    /// Centered autofocus ring with 4 subtle tick marks
    private var autofocusIndicator: some View {
        ZStack {
            // Outer dashed / ticked ring
            Circle()
                .stroke(
                    Color.white.opacity(isBreathing ? 0.65 : 0.35),
                    style: StrokeStyle(lineWidth: 1.2, dash: [4, 6])
                )
                .frame(width: 48, height: 48)

            // Inner precision crosshair center
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .light))
                .foregroundColor(Color.white.opacity(isBreathing ? 0.8 : 0.4))
        }
        .scaleEffect(isBreathing ? 1.05 : 0.95)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 1)
    }

    /// Feature tracking keypoint indicators
    private var keypointOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                KeypointDot(x: w * 0.28, y: h * 0.30, isPulsing: keypointPulse, delay: 0.0)
                KeypointDot(x: w * 0.72, y: h * 0.34, isPulsing: keypointPulse, delay: 0.25)
                KeypointDot(x: w * 0.50, y: h * 0.52, isPulsing: keypointPulse, delay: 0.5)
                KeypointDot(x: w * 0.32, y: h * 0.68, isPulsing: keypointPulse, delay: 0.15)
                KeypointDot(x: w * 0.68, y: h * 0.70, isPulsing: keypointPulse, delay: 0.4)
            }
        }
    }
}

/// Precision L-shaped corner bracket shape for high-end camera viewfinders
struct CornerBracketsShape: Shape {
    var bracketLength: CGFloat = 28
    var cornerRadius: CGFloat = 24

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let l = bracketLength
        let r = min(cornerRadius, l)

        // Top-Left Corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + l))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + l, y: rect.minY))

        // Top-Right Corner
        path.move(to: CGPoint(x: rect.maxX - l, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + l))

        // Bottom-Right Corner
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - l))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - l, y: rect.maxY))

        // Bottom-Left Corner
        path.move(to: CGPoint(x: rect.minX + l, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - r), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - l))

        return path
    }
}

/// Subtle glowing feature-point tracker dot
private struct KeypointDot: View {
    let x: CGFloat
    let y: CGFloat
    let isPulsing: Bool
    let delay: Double

    @State private var active: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.botanicalMint.opacity(0.35))
                .frame(width: 14, height: 14)
                .scaleEffect(active ? 1.6 : 0.8)

            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
                .shadow(color: Color.botanicalMint, radius: 4, x: 0, y: 0)
        }
        .position(x: x, y: y)
        .opacity(active ? 0.95 : 0.3)
        .onAppear {
            if isPulsing {
                startPulsing()
            }
        }
        .onChange(of: isPulsing) { _, pulsing in
            if pulsing {
                startPulsing()
            } else {
                active = false
            }
        }
    }

    private func startPulsing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                active = true
            }
        }
    }
}
