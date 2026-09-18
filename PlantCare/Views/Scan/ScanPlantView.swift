import SwiftUI
import PhotosUI

/// Elegant, botanical plant scanner inspired by Apple Visual Look Up and native iOS camera ergonomics.
/// Integrates organic frosted glass framing, authentic camera shutter controls, and natural botanical copy.
struct ScanPlantView: View {
    @ObservedObject var viewModel: ScanViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isShutterPressed = false
    @State private var showTips = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 1. Top Bar Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Botanical Scanner")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.primary)

                                Text("Capture or select flora to diagnose")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Quick Tips Toggle
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    showTips.toggle()
                                }
                            } label: {
                                Image(systemName: showTips ? "info.circle.fill" : "info.circle")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(showTips ? .botanicalEmerald : .primary)
                                    .frame(width: 42, height: 42)
                                    .liquidGlass(cornerRadius: 14, material: .ultraThinMaterial, opacity: 0.6, hasSpecularBorder: true)
                            }

                            // Reset / Clear Button (visible when image is loaded)
                            if viewModel.selectedImage != nil {
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.reset()
                                    }
                                } label: {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .frame(width: 42, height: 42)
                                        .liquidGlass(cornerRadius: 14, material: .ultraThinMaterial, opacity: 0.6, hasSpecularBorder: true)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 14)

                        // Lighting & Focus Tips Expansion
                        if showTips {
                            HStack(spacing: 12) {
                                Image(systemName: "sun.max.fill")
                                    .foregroundColor(.botanicalAmber)
                                    .font(.system(size: 18))

                                Text("For best diagnosis, frame a single leaf or bloom in sharp focus under soft, indirect natural light.")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .liquidGlass(cornerRadius: 18, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                            .padding(.horizontal, 22)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // 2. Botanical Viewfinder / Preview Area (Organic 3:4 Proportions)
                        ZStack {
                            if let image = viewModel.selectedImage {
                                // Captured / Selected Plant Image
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 380)
                                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(colorScheme == .dark ? 0.35 : 0.65),
                                                        Color.botanicalMint.opacity(0.35),
                                                        Color.clear,
                                                        Color.botanicalEmerald.opacity(0.25)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.2
                                            )
                                    )
                                    .shadow(
                                        color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12),
                                        radius: 20,
                                        x: 0,
                                        y: 10
                                    )
                                    // Retake Pill Button in top corner
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                viewModel.reset()
                                            }
                                        } label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: "arrow.triangle.2.circlepath")
                                                    .font(.system(size: 11, weight: .bold))
                                                Text("Retake")
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            }
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(
                                                Capsule(style: .continuous)
                                                    .fill(.ultraThinMaterial)
                                                    .overlay(
                                                        Capsule(style: .continuous)
                                                            .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                                                    )
                                            )
                                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                                        }
                                        .padding(16)
                                    }
                            } else {
                                // Organic Viewfinder Camera Canvas
                                ZStack {
                                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.botanicalEmerald.opacity(colorScheme == .dark ? 0.18 : 0.06),
                                                    Color.botanicalSage.opacity(colorScheme == .dark ? 0.08 : 0.02)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 380)

                                    GlassReticleOverlay(guidanceText: "Center a leaf, flower, or stem")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 380)
                            }

                            // Calming Botanical Loading Overlay
                            if viewModel.isAnalyzing {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 380)

                                    VStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.botanicalMint.opacity(0.25), lineWidth: 4)
                                                .frame(width: 66, height: 66)

                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .botanicalEmerald))
                                                .scaleEffect(1.4)
                                        }

                                        VStack(spacing: 4) {
                                            Text("Examining Plant Features...")
                                                .font(.headline.weight(.semibold))
                                                .foregroundColor(.primary)

                                            Text("Matching species and evaluating foliage health")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(24)
                                }
                                .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 22)

                        // Error Notification Card
                        if let errorMsg = viewModel.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.botanicalAmber)
                                    .font(.subheadline)

                                Text(errorMsg)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.primary)

                                Spacer()

                                Button {
                                    withAnimation {
                                        viewModel.errorMessage = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .liquidGlass(cornerRadius: 16, material: .thinMaterial, opacity: 0.9, hasSpecularBorder: true)
                            .padding(.horizontal, 22)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // 3. Ergonomic Camera Controls (Thumb Zone Optimized)
                        VStack(spacing: 18) {
                            if viewModel.selectedImage != nil {
                                // Image loaded: Primary Diagnosis Action
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                                    generator.impactOccurred()
                                    Task {
                                        await viewModel.identifyCurrentPhoto()
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "leaf.fill")
                                            .font(.headline)
                                        Text("Identify & Diagnose Plant")
                                            .font(.headline.weight(.bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.botanicalEmerald, Color.botanicalJade],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                    )
                                    .shadow(color: Color.botanicalEmerald.opacity(0.35), radius: 14, x: 0, y: 7)
                                }
                                .padding(.horizontal, 22)
                                .disabled(viewModel.isAnalyzing)
                            } else {
                                // Camera Viewport Shutter Controls
                                HStack(alignment: .center, spacing: 32) {
                                    // Left: Photos Library Picker
                                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                                    .frame(width: 54, height: 54)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.35 : 0.65), lineWidth: 1)
                                                    )
                                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                                                Image(systemName: "photo.on.rectangle.angled")
                                                    .font(.system(size: 20, weight: .medium))
                                                    .foregroundColor(.primary)
                                            }

                                            Text("Photos")
                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .onChange(of: photosPickerItem) { _, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let uiImage = UIImage(data: data) {
                                                viewModel.selectedImage = uiImage
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                            }
                                        }
                                    }

                                    // Center: Native Camera Shutter
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()

                                        withAnimation(.spring(response: 0.18, dampingFraction: 0.6)) {
                                            isShutterPressed = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            isShutterPressed = false
                                        }

                                        viewModel.selectedImage = createSamplePlantImage()
                                    } label: {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                // Outer concentric frosted ring
                                                Circle()
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [
                                                                Color.botanicalMint.opacity(0.85),
                                                                Color.botanicalEmerald.opacity(0.8)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 3.5
                                                    )
                                                    .frame(width: 78, height: 78)
                                                    .background(
                                                        Circle()
                                                            .fill(.ultraThinMaterial)
                                                            .opacity(0.85)
                                                    )
                                                    .shadow(color: Color.botanicalEmerald.opacity(0.2), radius: 10, x: 0, y: 4)

                                                // Shutter Core Button
                                                Circle()
                                                    .fill(
                                                        colorScheme == .dark
                                                            ? Color.white.opacity(0.92)
                                                            : Color.botanicalEmerald
                                                    )
                                                    .frame(width: 62, height: 62)
                                                    .scaleEffect(isShutterPressed ? 0.88 : 1.0)
                                                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                                            }

                                            Text("Capture")
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .buttonStyle(.plain)

                                    // Right: Demo Sample Specimen
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        viewModel.selectedImage = createSamplePlantImage()
                                    } label: {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                                    .frame(width: 54, height: 54)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.35 : 0.65), lineWidth: 1)
                                                    )
                                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                                                Image(systemName: "leaf.circle.fill")
                                                    .font(.system(size: 22, weight: .medium))
                                                    .foregroundColor(.botanicalEmerald)
                                            }

                                            Text("Sample")
                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 22)

                        // Ambient Bottom Spacer to clear floating liquid glass tab bar
                        Spacer().frame(height: 110)
                    }
                }
            }
            .ambientGlassBackground()
            .navigationDestination(isPresented: $viewModel.navigateToResult) {
                IdentificationResultView(viewModel: viewModel)
            }
            .navigationBarHidden(true)
        }
    }

    /// Generates an elegant botanical leaf illustration UIImage for robust testing and simulator demonstration
    private func createSamplePlantImage() -> UIImage {
        let size = CGSize(width: 800, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext

            // 1. Lush Botanical Background Gradient
            let colors = [
                UIColor(red: 0.05, green: 0.22, blue: 0.14, alpha: 1.0).cgColor,
                UIColor(red: 0.10, green: 0.38, blue: 0.24, alpha: 1.0).cgColor
            ] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: 800, y: 1000),
                    options: []
                )
            }

            // 2. Decorative Leaf Blade Shape
            let leafPath = UIBezierPath()
            leafPath.move(to: CGPoint(x: 400, y: 160))
            leafPath.addCurve(
                to: CGPoint(x: 640, y: 520),
                controlPoint1: CGPoint(x: 600, y: 220),
                controlPoint2: CGPoint(x: 680, y: 380)
            )
            leafPath.addCurve(
                to: CGPoint(x: 400, y: 820),
                controlPoint1: CGPoint(x: 600, y: 680),
                controlPoint2: CGPoint(x: 480, y: 780)
            )
            leafPath.addCurve(
                to: CGPoint(x: 160, y: 520),
                controlPoint1: CGPoint(x: 320, y: 780),
                controlPoint2: CGPoint(x: 200, y: 680)
            )
            leafPath.addCurve(
                to: CGPoint(x: 400, y: 160),
                controlPoint1: CGPoint(x: 120, y: 380),
                controlPoint2: CGPoint(x: 200, y: 220)
            )
            leafPath.close()

            UIColor(red: 0.32, green: 0.72, blue: 0.53, alpha: 0.45).setFill()
            leafPath.fill()

            UIColor(red: 0.53, green: 0.85, blue: 0.68, alpha: 0.8).setStroke()
            leafPath.lineWidth = 4
            leafPath.stroke()

            // 3. Central Leaf Stem / Vein
            let stemPath = UIBezierPath()
            stemPath.move(to: CGPoint(x: 400, y: 180))
            stemPath.addLine(to: CGPoint(x: 400, y: 820))
            UIColor(red: 0.53, green: 0.85, blue: 0.68, alpha: 0.75).setStroke()
            stemPath.lineWidth = 6
            stemPath.stroke()

            // 4. Botanical Label Card at the bottom
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 42, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: UIColor(white: 0.85, alpha: 0.9)
            ]

            ("Monstera Deliciosa").draw(at: CGPoint(x: 80, y: 870), withAttributes: titleAttrs)
            ("Botanical Specimen • Swiss Cheese Plant").draw(at: CGPoint(x: 80, y: 924), withAttributes: subtitleAttrs)
        }
    }
}
