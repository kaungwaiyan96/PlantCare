import SwiftUI
import PhotosUI

struct ScanPlantView: View {
    @ObservedObject var viewModel: ScanViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showCameraUnavailableAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Top Bar Header
                        HStack {
                            Text("Identify & Diagnose")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                            Spacer()

                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                viewModel.reset()
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .liquidGlass(cornerRadius: 16, material: .ultraThinMaterial, opacity: 0.3, hasSpecularBorder: true)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Center Viewfinder or Selected Photo Preview (responsive size: 260 x 300)
                        ZStack {
                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 260, height: 300)
                                    .cornerRadius(28)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .stroke(Color.botanicalMint.opacity(0.8), lineWidth: 2)
                                    )
                                    .shadow(color: Color.botanicalMint.opacity(0.3), radius: 20)
                            } else {
                                // Simulated Viewfinder with GlassReticleOverlay
                                ZStack {
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(width: 260, height: 300)

                                    GlassReticleOverlay(guidanceText: "Position plant leaves inside reticle")
                                }
                            }

                            // Loading Spinner Overlay during analysis
                            if viewModel.isAnalyzing {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 260, height: 300)

                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .botanicalMint))
                                            .scaleEffect(1.5)

                                        Text("Analyzing Botanical DNA...")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }

                        // Error Message if any
                        if let errorMsg = viewModel.errorMessage {
                            Text(errorMsg)
                                .font(.caption.weight(.medium))
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(12)
                        }

                        // Bottom Action Controls
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                // Gallery PhotosPicker Button
                                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "photo.stack.fill")
                                            .font(.subheadline.weight(.semibold))
                                        Text("Gallery")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .liquidGlass(cornerRadius: 20, material: .ultraThinMaterial, opacity: 0.4, hasSpecularBorder: true)
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

                                // Camera / Demo Photo Button
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    viewModel.selectedImage = createSamplePlantImage()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.subheadline.weight(.semibold))
                                        Text("Capture")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .liquidGlass(cornerRadius: 20, material: .ultraThinMaterial, opacity: 0.4, hasSpecularBorder: true)
                                }
                            }
                            .padding(.horizontal, 24)

                            // Identify Plant Action Button
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                                Task {
                                    if viewModel.selectedImage == nil {
                                        viewModel.selectedImage = createSamplePlantImage()
                                    }
                                    await viewModel.identifyCurrentPhoto()
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "sparkles")
                                        .font(.headline)
                                    Text("Identify Plant & Health")
                                        .font(.headline.weight(.bold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color.botanicalMint)
                                )
                                .shadow(color: Color.botanicalMint.opacity(0.5), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 24)
                            .disabled(viewModel.isAnalyzing)
                        }

                        Spacer().frame(height: 110)
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToResult) {
                IdentificationResultView(viewModel: viewModel)
            }
            .navigationBarHidden(true)
        }
    }

    private func createSamplePlantImage() -> UIImage {
        // Generates a botanical green sample UIImage for robust testing
        let size = CGSize(width: 800, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGreen.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 48),
                .foregroundColor: UIColor.white
            ]
            ("Monstera Deliciosa").draw(at: CGPoint(x: 100, y: 450), withAttributes: attrs)
        }
    }
}
