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
                                Text("\(savedPlants.count) thriving species saved")
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
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                                ForEach(filteredPlants) { plant in
                                    NavigationLink {
                                        SavedPlantDetailView(plant: plant)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 10) {
                                            // Plant Image from ImageStorageService
                                            if let uiImage = ImageStorageService.shared.loadImage(filename: plant.imageFilename) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: 140)
                                                    .cornerRadius(16)
                                                    .clipped()
                                            } else {
                                                Rectangle()
                                                    .fill(Color.botanicalSage.opacity(0.3))
                                                    .frame(height: 140)
                                                    .cornerRadius(16)
                                                    .overlay(
                                                        Image(systemName: "leaf.fill")
                                                            .foregroundColor(.botanicalEmerald)
                                                    )
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(plant.commonName)
                                                    .font(.subheadline.weight(.bold))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)

                                                Text(plant.scientificName)
                                                    .font(.caption2.italic())
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)

                                                // Condition Badge
                                                HStack(spacing: 4) {
                                                    Circle()
                                                        .fill(Color.botanicalEmerald)
                                                        .frame(width: 6, height: 6)
                                                    Text(plant.conditionSummary ?? "Thriving")
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .foregroundColor(.botanicalEmerald)
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(
                                                    Capsule()
                                                        .fill(Color.botanicalMint.opacity(0.25))
                                                )
                                                .padding(.top, 2)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .padding(12)
                                        .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deletePlant(plant)
                                            } label: {
                                                Label("Remove from Garden", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 100)
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
