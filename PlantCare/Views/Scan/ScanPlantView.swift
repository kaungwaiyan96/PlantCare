import SwiftUI
import PhotosUI

/// Elegant, production-grade camera scanner faithfully matching `camera_scan.mp4`.
/// Features a continuous 24pt white rounded rectangular viewfinder,
/// sweeping glowing laser beam, coordinate twinkling sparkles (`✦` / `+`),
/// circular gallery thumbnail button, concentric physical camera shutter,
/// dynamic rotating search status typography, and a floating dark mode capsule.
struct ScanPlantView: View {
    @ObservedObject var viewModel: ScanViewModel
    @Binding var selectedTab: Int

    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isShutterPressed = false
    @State private var isTorchOn = false
    @State private var selectedMode: ScannerMode = .photo
    @State private var statusIndex = 0
    @Namespace private var modeNamespace

    // Staged status transitions matching camera_scan.mp4
    private let statusMessages = [
        "Browsing our database",
        "Narrowing down the search",
        "Identifying the plant species"
    ]

    init(viewModel: ScanViewModel, selectedTab: Binding<Int> = .constant(1)) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Cinematic Dark Camera Canvas Background
                Color.black
                    .ignoresSafeArea()

                // Ambient botanical subtle background glow
                RadialGradient(
                    colors: [
                        Color.botanicalEmerald.opacity(0.16),
                        Color.black.opacity(0.90),
                        Color.black
                    ],
                    center: .center,
                    startRadius: 80,
                    endRadius: 420
                )
                .ignoresSafeArea()

                // 2. Main Camera Interface Layout
                GeometryReader { geo in
                    let screenHeight = geo.size.height
                    let viewfinderHeight = min(max(screenHeight * 0.58, 380), 470)

                    VStack(spacing: 0) {
                        // Top Header Bar
                        topHeaderBar
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                        // Center Viewfinder Viewport
                        viewfinderViewport(height: viewfinderHeight)
                            .padding(.horizontal, 20)

                        // Diagnostics / Error Card (if any)
                        if let errorMsg = viewModel.errorMessage {
                            errorNotificationBanner(errorMsg)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }

                        Spacer(minLength: 16)

                        // Concentric Camera Shutter Control
                        shutterControlArea
                            .padding(.bottom, viewModel.isAnalyzing ? 12 : 18)

                        // Animated Progress Status Text (displayed below shutter during scanning)
                        if viewModel.isAnalyzing {
                            animatedStatusIndicator
                                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                                .padding(.bottom, 16)
                        }

                        // Floating Mode Switcher Capsule (Photo vs Barcode)
                        modeSwitcherCapsule
                            .padding(.bottom, 20)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToResult) {
                IdentificationResultView(viewModel: viewModel)
            }
            .navigationBarHidden(true)
            .onChange(of: viewModel.isAnalyzing) { _, isAnalyzing in
                if isAnalyzing {
                    statusIndex = 0
                    Task {
                        while viewModel.isAnalyzing {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            guard viewModel.isAnalyzing else { break }
                            withAnimation(.easeInOut(duration: 0.35)) {
                                statusIndex = (statusIndex + 1) % statusMessages.count
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 1. Top Header Bar

    private var topHeaderBar: some View {
        HStack(alignment: .center) {
            // Left: Circular dark frosted button with xmark (dismiss / return to home)
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    if viewModel.selectedImage != nil {
                        viewModel.reset()
                    } else {
                        selectedTab = 0
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.55))
                        .background(Circle().fill(.ultraThinMaterial))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.20), lineWidth: 1)
                        )

                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            // Right: Circular dark frosted button with sun.max / flash/torch toggle
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isTorchOn.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isTorchOn ? Color.botanicalAmber.opacity(0.30) : Color.black.opacity(0.55))
                        .background(Circle().fill(.ultraThinMaterial))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(
                                    isTorchOn ? Color.botanicalAmber.opacity(0.85) : Color.white.opacity(0.20),
                                    lineWidth: 1
                                )
                        )

                    Image(systemName: isTorchOn ? "sun.max.fill" : "sun.max")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isTorchOn ? .botanicalAmber : .white)
                }
            }
        }
    }

    // MARK: - 2. Center Viewfinder Viewport

    private func viewfinderViewport(height: CGFloat) -> some View {
        ZStack {
            // Viewfinder Base Content (Camera feed or Selected Image)
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                simulatedCameraFeed(height: height)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            // High-Precision Reticle Overlay (Continuous 24pt White Border, Scanning Laser & Twinkling Sparkles)
            GlassReticleOverlay(
                isScanning: viewModel.isAnalyzing,
                isTorchOn: isTorchOn
            )
            .frame(maxWidth: .infinity)
            .frame(height: height)

            // Inside/at bottom-left of viewfinder: Photo Gallery Thumbnail Button (~46x46)
            VStack {
                Spacer()
                HStack {
                    photoGalleryThumbnailButton
                        .padding(.leading, 16)
                        .padding(.bottom, 16)

                    Spacer()

                    // If photo is loaded and idle, show Retake button in bottom right
                    if viewModel.selectedImage != nil && !viewModel.isAnalyzing {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.reset()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Retake")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.65))
                                    .background(Capsule().fill(.ultraThinMaterial))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                                    )
                            )
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .frame(height: height)
        .shadow(color: Color.black.opacity(0.4), radius: 18, x: 0, y: 8)
    }

    // MARK: - 3. Simulated Botanical Camera Specimen (Simulator & Zero-Hardware Experience)

    private func simulatedCameraFeed(height: CGFloat) -> some View {
        ZStack {
            // Camera sensor depth gradient
            LinearGradient(
                colors: [
                    Color(hex: 0x081A12),
                    Color(hex: 0x0E2E20),
                    Color(hex: 0x07150E)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Botanical specimen preview graphic
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    // Soft background glow
                    Circle()
                        .fill(Color.botanicalMint.opacity(0.20))
                        .frame(width: w * 0.7, height: w * 0.7)
                        .blur(radius: 40)
                        .position(x: w * 0.5, y: h * 0.45)

                    // Specimen Leaf Icon
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: w * 0.44, height: h * 0.44)
                        .foregroundColor(Color.botanicalMint.opacity(0.32))
                        .rotationEffect(.degrees(-18))
                        .position(x: w * 0.5, y: h * 0.46)
                }
            }
        }
    }

    // MARK: - 4. Circular Photo Gallery Thumbnail Button (~46x46)

    private var photoGalleryThumbnailButton: some View {
        PhotosPicker(selection: $photosPickerItem, matching: .images) {
            ZStack {
                // Background & Border
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .background(Circle().fill(.ultraThinMaterial))
                    .frame(width: 46, height: 46)

                // Thumbnail if user selected an image
                if let selected = viewModel.selectedImage {
                    Image(uiImage: selected)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                } else {
                    // Specimen leaf preview thumbnail inside circle
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.botanicalEmerald, Color.botanicalMint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                }

                // Crisp White Ring
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 46, height: 46)
            }
            .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
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
    }

    // MARK: - 5. Concentric Camera Shutter Button

    private var shutterControlArea: some View {
        Button {
            triggerShutterCapture()
        } label: {
            ZStack {
                // Concentric Outer White Stroke Ring (~72pt)
                Circle()
                    .stroke(Color.white, lineWidth: 3.5)
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.white.opacity(0.35), radius: 8, x: 0, y: 0)

                // Concentric Inner Solid White Circular Button (~58pt with smooth press scale effect)
                Circle()
                    .fill(Color.white)
                    .frame(width: 58, height: 58)
                    .scaleEffect(isShutterPressed ? 0.88 : 1.0)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)

                // When analyzing, display subtle circular emerald spinner inside shutter
                if viewModel.isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .botanicalEmerald))
                        .scaleEffect(1.1)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isAnalyzing)
    }

    private func triggerShutterCapture() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.18, dampingFraction: 0.55)) {
            isShutterPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isShutterPressed = false
            }
        }

        // If no photo has been picked, instantaneously capture the simulated plant specimen
        if viewModel.selectedImage == nil {
            viewModel.selectedImage = createSamplePlantImage()
        }

        // Initiate identification task
        Task {
            await viewModel.identifyCurrentPhoto()
        }
    }

    // MARK: - 6. Animated Progress Status Indicator (Matching camera_scan.mp4 typography)

    private var animatedStatusIndicator: some View {
        Text(statusMessages[statusIndex])
            .font(.system(size: 16, weight: .medium, design: .serif))
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
            .contentTransition(.numericText())
            .id(statusIndex)
    }

    // MARK: - 7. Bottom Mode Switcher Capsule

    private var modeSwitcherCapsule: some View {
        HStack(spacing: 6) {
            ForEach(ScannerMode.allCases) { mode in
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .semibold))

                        Text(mode.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.70))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background {
                        if selectedMode == mode {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.botanicalEmerald, Color.botanicalMint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.botanicalEmerald.opacity(0.45), radius: 8, x: 0, y: 3)
                                .matchedGeometryEffect(id: "ActiveModeCapsule", in: modeNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.75))
                .background(Capsule().fill(.ultraThinMaterial))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 6)
    }

    // MARK: - 8. Error Notification Banner

    private func errorNotificationBanner(_ errorMsg: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.botanicalAmber)
                .font(.subheadline)

            Text(errorMsg)
                .font(.caption.weight(.medium))
                .foregroundColor(.white)

            Spacer()

            Button {
                withAnimation {
                    viewModel.errorMessage = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.85))
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.botanicalAmber.opacity(0.5), lineWidth: 1)
                )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - 9. Botanical Sample Image Generator (Robust Simulator Specimen)

    private func createSamplePlantImage() -> UIImage {
        let size = CGSize(width: 800, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext

            // Lush Botanical Background Gradient
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

            // Decorative Leaf Blade Shape
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

            // Central Leaf Stem / Vein
            let stemPath = UIBezierPath()
            stemPath.move(to: CGPoint(x: 400, y: 180))
            stemPath.addLine(to: CGPoint(x: 400, y: 820))
            UIColor(red: 0.53, green: 0.85, blue: 0.68, alpha: 0.75).setStroke()
            stemPath.lineWidth = 6
            stemPath.stroke()

            // Botanical Label Card at the bottom
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

// MARK: - Scanner Mode Definition

enum ScannerMode: String, CaseIterable, Identifiable {
    case photo = "Photo"
    case barcode = "Barcode"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .photo: return "camera.fill"
        case .barcode: return "barcode.viewfinder"
        }
    }
}

#Preview {
    ScanPlantView(viewModel: ScanViewModel(), selectedTab: .constant(1))
}
