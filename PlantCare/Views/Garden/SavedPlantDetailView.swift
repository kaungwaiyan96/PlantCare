import SwiftUI

struct SavedPlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isTabBarHidden) var isTabBarHidden
    var plant: SavedPlant

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image
                    ZStack(alignment: .topLeading) {
                        if let uiImage = ImageStorageService.shared.loadImage(filename: plant.imageFilename) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 380)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.botanicalSage.opacity(0.3))
                                .frame(height: 380)
                                .overlay(Image(systemName: "leaf.fill").font(.system(size: 40)).foregroundColor(.botanicalEmerald))
                        }

                        // Gradient fade
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
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(plant.commonName)
                                    .font(.title.weight(.bold))
                                    .foregroundColor(.primary)

                                Text(plant.scientificName)
                                    .font(.subheadline.italic())
                                    .foregroundColor(.secondary)
                            }
                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Confidence")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(Int((plant.confidenceScore * 100).rounded()))%")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.botanicalEmerald)
                            }
                        }

                        // Care Metric Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            GlassMetricBadge(type: .watering, value: plant.wateringNeeds)
                            GlassMetricBadge(type: .sunlight, value: plant.sunlightRequirements)
                            GlassMetricBadge(type: .cycle, value: plant.growthCycle)
                            GlassMetricBadge(type: .cycle, value: "Added " + plant.dateAdded.formatted(date: .abbreviated, time: .omitted))
                        }

                        // Health Summary Card
                        if let summary = plant.conditionSummary {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "cross.case.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.botanicalEmerald)
                                    Text("Health Status")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.secondary)
                                }

                                Text(summary)
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.primary)
                            }
                            .padding(16)
                            .liquidGlass(cornerRadius: 20, material: .regularMaterial, opacity: 0.85, hasSpecularBorder: true)
                        }

                        // Care Instructions Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Botanical Care Guide")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.primary)

                            Text(plant.careInstructions)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)

                        Spacer().frame(height: 110)
                    }
                    .padding(20)
                    .offset(y: -24)
                }
            }
            .ambientGlassBackground()
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
        .onAppear { isTabBarHidden.wrappedValue = true }
        .onDisappear { isTabBarHidden.wrappedValue = false }
    }
}
