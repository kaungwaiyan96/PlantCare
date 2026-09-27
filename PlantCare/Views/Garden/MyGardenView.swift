import SwiftUI
import SwiftData

struct MyGardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedPlant.dateAdded, order: .reverse) private var savedPlants: [SavedPlant]
    @State private var searchText = ""

    var filteredPlants: [SavedPlant] {
        if searchText.isEmpty {
            return savedPlants
        } else {
            return savedPlants.filter {
                $0.commonName.localizedStandardContains(searchText) ||
                $0.scientificName.localizedStandardContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Botanical Garden")
                                    .font(.title.weight(.bold))
                                    .foregroundColor(.primary)
                                Text("\(savedPlants.count) \(savedPlants.count == 1 ? "botanical species" : "botanical species") saved")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()

                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.botanicalEmerald)
                                    .padding(12)
                                    .liquidGlass(cornerRadius: 16, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // Search Bar
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search your garden plants...", text: $searchText)
                                .foregroundColor(.primary)
                        }
                        .padding(14)
                        .liquidGlass(cornerRadius: 20, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                        .padding(.horizontal, 20)

                        // Garden Grid or Empty State
                        if filteredPlants.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "leaf.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(.botanicalEmerald.opacity(0.8))
                                    .padding(.top, 40)

                                VStack(spacing: 8) {
                                    Text("Your Garden is Empty")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.primary)
                                    Text("Scan and identify your first plant to begin cultivating your digital botanical sanctuary.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .liquidGlass(cornerRadius: 28, material: .ultraThinMaterial, opacity: 0.8, hasSpecularBorder: true)
                            .padding(.horizontal, 20)
                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 14),
                                    GridItem(.flexible(), spacing: 14)
                                ],
                                spacing: 14
                            ) {
                                ForEach(filteredPlants) { plant in
                                    NavigationLink {
                                        SavedPlantDetailView(plant: plant)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 10) {
                                            // Plant Image strictly bounded to column cell width
                                            Color.clear
                                                .frame(height: 135)
                                                .overlay(
                                                    Group {
                                                        if let uiImage = ImageStorageService.shared.loadImage(filename: plant.imageFilename) {
                                                            Image(uiImage: uiImage)
                                                                .resizable()
                                                                .scaledToFill()
                                                        } else {
                                                            ZStack {
                                                                Color.botanicalSage.opacity(0.3)
                                                                Image(systemName: "leaf.fill")
                                                                    .font(.system(size: 32))
                                                                    .foregroundColor(.botanicalEmerald)
                                                            }
                                                        }
                                                    }
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(plant.commonName)
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)

                                                Text(plant.scientificName)
                                                    .font(.caption2.italic())
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)

                                                // Condition Badge
                                                let isHealthy = (plant.conditionSummary?.localizedCaseInsensitiveContains("healthy") == true) || (plant.conditionSummary?.localizedCaseInsensitiveContains("thriving") == true) || plant.conditionSummary == nil
                                                let badgeColor = isHealthy ? Color.botanicalEmerald : Color.botanicalAmber
                                                let badgeBg = isHealthy ? Color.botanicalMint.opacity(0.25) : Color.botanicalAmber.opacity(0.2)

                                                HStack(spacing: 4) {
                                                    Circle()
                                                        .fill(badgeColor)
                                                        .frame(width: 6, height: 6)
                                                    Text(plant.conditionSummary ?? "Thriving")
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .foregroundColor(badgeColor)
                                                        .lineLimit(1)
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(
                                                    Capsule()
                                                        .fill(badgeBg)
                                                )
                                                .padding(.top, 2)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deletePlant(plant)
                                            } label: {
                                                Label("Remove from Garden", systemImage: "trash")
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 110)
                    }
                }
                .ambientGlassBackground()
                .navigationBarHidden(true)
            }
        }
    }

    private func deletePlant(_ plant: SavedPlant) {
        ImageStorageService.shared.deleteImage(filename: plant.imageFilename)
        modelContext.delete(plant)
        try? modelContext.save()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
