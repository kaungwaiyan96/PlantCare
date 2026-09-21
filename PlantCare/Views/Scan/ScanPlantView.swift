import SwiftUI
import PhotosUI

/// Refined, world-class Apple HIG camera scanner for botanical species identification.
/// Features a precision viewfinder with photorealistic specimen preview, Apple Pro Camera
/// corner brackets, dynamic autofocus indicator, ergonomic 3-item bottom dock,
/// and centered camera shutter button.
struct ScanPlantView: View {
    @ObservedObject var viewModel: ScanViewModel
    @Binding var selectedTab: Int

    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isShutterPressed = false
    @State private var isTorchOn = false
    @State private var statusIndex = 0

    // Staged status transitions during AI inference
    private let statusMessages = [
        "Browsing botanical index...",
        "Analyzing leaf morphology...",
        "Matching plant species..."
    ]

    init(viewModel: ScanViewModel, selectedTab: Binding<Int> = .constant(1)) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Cinematic Pro Camera Dark Canvas
                Color.black
                    .ignoresSafeArea()

                // Subtle ambient botanical depth glow
                RadialGradient(
                    colors: [
                        Color.botanicalEmerald.opacity(0.18),
                        Color.black.opacity(0.92),
                        Color.black
                    ],
                    center: .center,
                    startRadius: 80,
                    endRadius: 460
                )
                .ignoresSafeArea()

                // 2. Main Camera Interface Layout
                GeometryReader { geo in
                    let screenHeight = geo.size.height
                    let viewfinderHeight = min(max(screenHeight * 0.58, 380), 490)

                    VStack(spacing: 0) {
                        // Top Header Bar
                        topHeaderBar
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                        // Center Viewfinder Viewport
                        viewfinderViewport(height: viewfinderHeight)
                            .padding(.horizontal, 20)

                        // Diagnostics / Error Notification Banner (if any)
                        if let errorMsg = viewModel.errorMessage {
                            errorNotificationBanner(errorMsg)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                        }

                        Spacer(minLength: 16)

                        // Floating AI Analysis Status Pill (Visible during scanning)
                        if viewModel.isAnalyzing {
                            animatedStatusPill
                                .transition(.opacity.combined(with: .scale(scale: 0.94)))
                                .padding(.bottom, 14)
                        }

                        // Ergonomic 3-Item Control Toolbar (Gallery | Shutter | Retake/Specimen)
                        bottomControlsDock
                            .padding(.horizontal, 28)
                            .padding(.bottom, 32)
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
                            try? await Task.sleep(nanoseconds: 1_400_000_000)
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
            // Dismiss / Back Button (44x44pt touch target)
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
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .accessibilityLabel("Close camera")

            Spacer()

            // Guidance Prompt Pill (Apple HIG feedforward)
            HStack(spacing: 6) {
                Image(systemName: viewModel.isAnalyzing ? "sparkles" : "camera.viewfinder")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(viewModel.isAnalyzing ? .botanicalMint : .white.opacity(0.85))

                Text(viewModel.isAnalyzing ? "Analyzing specimen..." : "Point at leaves or flowers")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.55))
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(
                        Capsule()
                            .stroke(
                                viewModel.isAnalyzing
                                    ? Color.botanicalMint.opacity(0.6)
                                    : Color.white.opacity(0.18),
                                lineWidth: 1
                            )
                    )
            )

            Spacer()

            // Flash / Torch Toggle Button (44x44pt touch target)
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
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isTorchOn ? .botanicalAmber : .white)
                }
            }
            .accessibilityLabel(isTorchOn ? "Turn torch off" : "Turn torch on")
        }
    }

    // MARK: - 2. Center Viewfinder Viewport

    private func viewfinderViewport(height: CGFloat) -> some View {
        ZStack {
            // Viewfinder Base Content: Selected User Image OR Photorealistic Botanical Specimen
            Group {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                } else {
                    photorealisticSpecimenFeed(height: height)
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            // Apple Pro Camera Reticle Overlay (Corner Brackets, Autofocus Ring & Scanning Laser)
            GlassReticleOverlay(
                isScanning: viewModel.isAnalyzing,
                isTorchOn: isTorchOn
            )
            .frame(maxWidth: .infinity)
            .frame(height: height)
        }
        .frame(height: height)
        .shadow(color: Color.black.opacity(0.45), radius: 22, x: 0, y: 10)
    }

    // MARK: - 3. Photorealistic Botanical Specimen Feed

    private func photorealisticSpecimenFeed(height: CGFloat) -> some View {
        ZStack {
            // High-resolution botanical specimen photo
            if let _ = UIImage(named: "CameraSpecimen") {
                Image("CameraSpecimen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .overlay(
                        // Cinematic optical grading
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.18),
                                Color.clear,
                                Color.black.opacity(0.32)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                // Procedural fallback if asset is missing
                fallbackBotanicalSpecimen(height: height)
            }
        }
    }

    private func fallbackBotanicalSpecimen(height: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0x071D12),
                    Color(hex: 0x0E3322),
                    Color(hex: 0x06180E)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(Color.botanicalMint.opacity(0.4))
                Text("Monstera Deliciosa")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
    }

    // MARK: - 4. Live Scanning Status Pill

    private var animatedStatusPill: some View {
        HStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.botanicalMint))
                .scaleEffect(0.85)

            Text(statusMessages[statusIndex])
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .id(statusIndex)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.70))
                .background(Capsule().fill(.ultraThinMaterial))
                .overlay(
                    Capsule()
                        .stroke(Color.botanicalMint.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 3)
    }

    // MARK: - 5. Ergonomic 3-Item Bottom Control Dock

    private var bottomControlsDock: some View {
        HStack(alignment: .center) {
            // Left Item: Photo Library Gallery Button
            VStack(spacing: 6) {
                photoGalleryButton
                Text("Gallery")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)

            // Center Item: Primary Concentric Shutter Button with Centered Camera Icon
            VStack(spacing: 6) {
                shutterButton
                Text(viewModel.selectedImage != nil ? "Scan" : "Identify")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
            }
            .frame(maxWidth: .infinity)

            // Right Item: Sample Specimen Demo or Retake Button
            VStack(spacing: 6) {
                sampleOrRetakeButton
                Text(viewModel.selectedImage != nil ? "Retake" : "Sample")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - 6. Left Gallery Button

    private var photoGalleryButton: some View {
        PhotosPicker(selection: $photosPickerItem, matching: .images) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.55))
                    .background(Circle().fill(.ultraThinMaterial))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.28), lineWidth: 1.5)
                    )

                if let selected = viewModel.selectedImage {
                    Image(uiImage: selected)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
        }
        .disabled(viewModel.isAnalyzing)
        .accessibilityLabel("Photo gallery")
        .accessibilityHint("Select an existing plant photo from library")
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedImage = uiImage
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
        }
    }

    // MARK: - 7. Center Concentric Shutter Button with Centered Camera Icon

    private var shutterButton: some View {
        Button {
            triggerShutterCapture()
        } label: {
            ZStack {
                // Outer Concentric Ring (80pt diameter, 3.5pt white border with luminous halo)
                Circle()
                    .stroke(Color.white, lineWidth: 3.5)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.white.opacity(0.4), radius: 8, x: 0, y: 0)

                // Inner Plunger Circle (64pt diameter) containing centered camera icon
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 2)

                    if viewModel.isAnalyzing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.botanicalEmerald))
                            .scaleEffect(1.2)
                            .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    } else {
                        // Centered camera icon inside the circle
                        Image(systemName: "camera.fill")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(Color(hex: 0x081A12))
                            .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    }
                }
                .scaleEffect(isShutterPressed ? 0.90 : 1.0)
            }
            .frame(width: 80, height: 80)
            .contentShape(Circle())
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isShutterPressed)
            .animation(.easeInOut(duration: 0.25), value: viewModel.isAnalyzing)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isAnalyzing)
        .accessibilityLabel("Take photo and identify plant")
    }

    // MARK: - 8. Right Sample / Retake Button

    private var sampleOrRetakeButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            if viewModel.selectedImage != nil {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    viewModel.reset()
                }
            } else {
                // Quick load specimen
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    viewModel.selectedImage = UIImage(named: "CameraSpecimen") ?? createSamplePlantImage()
                }
                triggerShutterCapture()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.55))
                    .background(Circle().fill(.ultraThinMaterial))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.28), lineWidth: 1.5)
                    )

                if viewModel.selectedImage != nil {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.botanicalMint)
                }
            }
            .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
        }
        .disabled(viewModel.isAnalyzing)
        .accessibilityLabel(viewModel.selectedImage != nil ? "Retake photo" : "Sample specimen")
    }

    // MARK: - 9. Trigger Shutter Action

    private func triggerShutterCapture() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.16, dampingFraction: 0.5)) {
            isShutterPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.7)) {
                isShutterPressed = false
            }
        }

        // If no photo selected yet, automatically capture the live specimen photo
        if viewModel.selectedImage == nil {
            viewModel.selectedImage = UIImage(named: "CameraSpecimen") ?? createSamplePlantImage()
        }

        // Start AI identification pipeline
        Task {
            await viewModel.identifyCurrentPhoto()
        }
    }

    // MARK: - 10. Error Notification Banner

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

    // MARK: - 11. Botanical Sample Fallback Generator

    private func createSamplePlantImage() -> UIImage {
        let size = CGSize(width: 800, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext

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

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 42, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            ("Monstera Deliciosa").draw(at: CGPoint(x: 80, y: 870), withAttributes: titleAttrs)
        }
    }
}

#Preview {
    ScanPlantView(viewModel: ScanViewModel(), selectedTab: .constant(1))
}
