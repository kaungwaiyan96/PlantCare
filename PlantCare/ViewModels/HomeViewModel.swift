import SwiftUI

struct FeaturedPlant: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let scientificName: String
    let imageURL: String
    let sunlight: String
    let watering: String
    let careLevel: String
    let description: String
}

struct PlantCareTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var featuredPlants: [FeaturedPlant] = []
    @Published var careTips: [PlantCareTip] = []

    init() {
        loadData()
    }

    private func loadData() {
        featuredPlants = [
            FeaturedPlant(
                name: "Monstera Deliciosa",
                scientificName: "Monstera deliciosa",
                imageURL: "https://images.unsplash.com/photo-1614594975525-e45190c55d0b",
                sunlight: "Bright Indirect",
                watering: "Every 1–2 weeks",
                careLevel: "Easy",
                description: "Famous for its iconic fenestrated leaves. Thrives in warm, humid indoor spaces."
            ),
            FeaturedPlant(
                name: "Fiddle Leaf Fig",
                scientificName: "Ficus lyrata",
                imageURL: "https://images.unsplash.com/photo-1545241047-6083a3684587",
                sunlight: "Filtered Sunlight",
                watering: "When dry (2 in)",
                careLevel: "Moderate",
                description: "Striking architectural foliage. Prefers stable positions away from cold drafts."
            ),
            FeaturedPlant(
                name: "Snake Plant",
                scientificName: "Sansevieria trifasciata",
                imageURL: "https://images.unsplash.com/photo-1599598425947-490d565612d3",
                sunlight: "Low to Bright",
                watering: "Every 2–3 weeks",
                careLevel: "Very Easy",
                description: "Remarkably indestructible. Excellent air purifying qualities and low water needs."
            ),
            FeaturedPlant(
                name: "Golden Pothos",
                scientificName: "Epipremnum aureum",
                imageURL: "https://images.unsplash.com/photo-1581783342605-2d49fac7f787",
                sunlight: "Medium Light",
                watering: "When dry",
                careLevel: "Beginner",
                description: "Cascading vine with heart-shaped leaves variegated with warm gold splashes."
            )
        ]

        careTips = [
            PlantCareTip(
                title: "Bottom Watering Technique",
                description: "Allow thirsty potted plants to absorb moisture from the base to prevent root rot and fungus gnats.",
                icon: "drop.triangle.fill"
            ),
            PlantCareTip(
                title: "Foliage Dusting",
                description: "Wipe broad leaves with a damp microfiber cloth to maximize photosynthetic efficiency.",
                icon: "sparkles"
            ),
            PlantCareTip(
                title: "Seasonal Sunlight Rotation",
                description: "Rotate houseplants 90 degrees monthly to ensure balanced growth toward window light.",
                icon: "sun.max.fill"
            )
        ]
    }

    var filteredPlants: [FeaturedPlant] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return featuredPlants
        }
        return featuredPlants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.scientificName.localizedCaseInsensitiveContains(searchText)
        }
    }
}
