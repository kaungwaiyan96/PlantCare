import SwiftUI
import SwiftData

struct PlantProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var plantName: String
    var scientificName: String
    var imageURL: String
    var watering: String
    var sunlight: String
    var growthCycle: String = "Perennial"
    var careInstructions: String = "Maintain consistent soil moisture and ensure adequate indirect sunlight."
    var conditionName: String? = "Vibrant & Healthy"
    var conditionDescription: String? = "Foliage exhibits vigorous turgidity, uniform chlorophyll pigmentation, and no discernible signs of blight."
    var localImage: UIImage? = nil

    @State private var isSaved = false
    @State private var isExpandedDetails = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Plant Image Header with Frosted Overlay
                    ZStack(alignment: .topLeading) {
                        if let localImage = localImage {
                            Image(uiImage: localImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 380)
                                .clipped()
                        } else {
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.2))
                                        .overlay(ProgressView())
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure(_):
                                    Rectangle()
                                        .fill(Color.botanicalSage.opacity(0.3))
                                        .overlay(Image(systemName: "leaf.fill").font(.system(size: 40)).foregroundColor(.botanicalEmerald))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 380)
                            .clipped()
                        }

                        // Gradient fade at bottom of hero image
                        VStack {
                            Spacer()
                            LinearGradient(
                                colors: [.clear, Color.black.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 120)
                        }

                        // Back Button
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .liquidGlass(cornerRadius: 16, material: .ultraThinMaterial, opacity: 0.5, hasSpecularBorder: true)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    }

                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Title & Scientific Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text(plantName)
                                .font(.title.weight(.bold))
                                .foregroundColor(.primary)

                            Text(scientificName)
                                .font(.subheadline.italic())
                                .foregroundColor(.secondary)
                        }

                        // Glass Care Metric Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            GlassMetricBadge(type: .watering, value: watering)
                            GlassMetricBadge(type: .sunlight, value: sunlight)
                            GlassMetricBadge(type: .cycle, value: growthCycle)
                            GlassMetricBadge(type: .cycle, value: "Beginner Friendly")
                        }

                        // Plant Condition / Health Diagnosis Card (Soft Amber / Emerald Frosted Glass)
                        if let condName = conditionName, let condDesc = conditionDescription {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "cross.case.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.botanicalAmber)
                                    Text("Health Diagnosis (Non-Diagnostic Suggestion)")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.secondary)
                                }

                                Text(condName)
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.primary)

                                Text(condDesc)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .liquidGlass(
                                cornerRadius: 20,
                                material: .regularMaterial,
                                opacity: 0.85,
                                hasSpecularBorder: true
                            )
                        }

                        // Detailed Care Guide Expandable Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Detailed Botanical Care Guide")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Button {
                                    withAnimation(.spring()) {
                                        isExpandedDetails.toggle()
                                    }
                                } label: {
                                    Image(systemName: isExpandedDetails ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.botanicalEmerald)
                                        .font(.subheadline.weight(.bold))
                                }
                            }

                            Text(careInstructions)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(isExpandedDetails ? nil : 3)

                            if !isExpandedDetails {
                                Button("Read More") {
                                    withAnimation(.spring()) {
                                        isExpandedDetails = true
                                    }
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.botanicalEmerald)
                            }
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)

                        Spacer().frame(height: 120)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.clear)
                    )
                    .offset(y: -24)
                }
            }
            .ambientGlassBackground()
            .ignoresSafeArea(edges: .top)

            // Floating Liquid Glass "Save to My Garden" Action Button
            VStack {
                Button {
                    saveToGarden()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isSaved ? "checkmark.circle.fill" : "bookmark.fill")
                            .font(.headline)
                        Text(isSaved ? "Saved in My Garden 🌿" : "Save to My Garden")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(isSaved ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(isSaved ? Color.botanicalEmerald : Color.botanicalMint)
                    )
                    .shadow(color: (isSaved ? Color.botanicalEmerald : Color.botanicalMint).opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .disabled(isSaved)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }

    private func saveToGarden() {
        do {
            let imgToSave = localImage ?? createFallbackImage()
            let filename = try ImageStorageService.shared.saveImage(imgToSave)

            let savedPlant = SavedPlant(
                commonName: plantName,
                scientificName: scientificName,
                confidenceScore: 0.96,
                conditionSummary: conditionName ?? "Vibrant & Healthy",
                conditionConfidence: 0.94,
                wateringNeeds: watering,
                sunlightRequirements: sunlight,
                growthCycle: growthCycle,
                careInstructions: careInstructions,
                imageFilename: filename,
                dateAdded: Date()
            )

            modelContext.insert(savedPlant)
            try modelContext.save()

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isSaved = true
            }
        } catch {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    private func createFallbackImage() -> UIImage {
        let size = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
