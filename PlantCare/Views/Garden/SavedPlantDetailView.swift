import SwiftUI

struct SavedPlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isTabBarHidden) var isTabBarHidden
    var plant: SavedPlant

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                ZStack(alignment: .bottom) {
                    GeometryReader { proxy in
                        if let uiImage = ImageStorageService.shared.loadImage(filename: plant.imageFilename) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: 380)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.botanicalSage.opacity(0.3))
                                .frame(width: proxy.size.width, height: 380)
                                .overlay(Image(systemName: "leaf.fill").font(.system(size: 40)).foregroundColor(.botanicalEmerald))
                        }
                    }
                    .frame(height: 380)

                    // Gradient fade
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                }
                .frame(height: 380)

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
                        GlassMetricBadge(type: .date, value: plant.dateAdded.formatted(date: .abbreviated, time: .omitted))
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
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)

                    Spacer().frame(height: 32)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: -24)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .ambientGlassBackground()
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .top) {
            HStack {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .contentShape(Circle())
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
        }
        .navigationBarHidden(true)
        .onAppear { isTabBarHidden.wrappedValue = true }
        .onDisappear { isTabBarHidden.wrappedValue = false }
    }
}
