import UIKit

final class MockPlantService: PlantServiceProtocol, @unchecked Sendable {
    static let shared = MockPlantService()

    func identifyPlant(image: UIImage) async throws -> [PlantNetMatch] {
        // Simulate real-world network latency (0.8s)
        try await Task.sleep(nanoseconds: 800_000_000)

        let topMatch = PlantNetMatch(
            score: 0.962,
            species: PlantNetSpecies(
                scientificNameWithoutAuthor: "Monstera deliciosa",
                scientificNameAuthorship: "Liebm.",
                genus: PlantNetTaxon(scientificNameWithoutAuthor: "Monstera"),
                family: PlantNetTaxon(scientificNameWithoutAuthor: "Araceae"),
                commonNames: ["Swiss Cheese Plant", "Split-Leaf Philodendron", "Monstera"]
            ),
            images: [
                PlantNetImage(
                    organ: "leaf",
                    url: PlantNetImageURL(
                        o: "https://images.unsplash.com/photo-1614594975525-e45190c55d0b",
                        m: "https://images.unsplash.com/photo-1614594975525-e45190c55d0b",
                        s: "https://images.unsplash.com/photo-1614594975525-e45190c55d0b"
                    )
                )
            ]
        )

        let alt1 = PlantNetMatch(
            score: 0.814,
            species: PlantNetSpecies(
                scientificNameWithoutAuthor: "Monstera adansonii",
                scientificNameAuthorship: "Schott",
                genus: PlantNetTaxon(scientificNameWithoutAuthor: "Monstera"),
                family: PlantNetTaxon(scientificNameWithoutAuthor: "Araceae"),
                commonNames: ["Monkey Mask", "Adanson's Monstera"]
            ),
            images: nil
        )

        let alt2 = PlantNetMatch(
            score: 0.671,
            species: PlantNetSpecies(
                scientificNameWithoutAuthor: "Epipremnum pinnatum",
                scientificNameAuthorship: "(L.) Engl.",
                genus: PlantNetTaxon(scientificNameWithoutAuthor: "Epipremnum"),
                family: PlantNetTaxon(scientificNameWithoutAuthor: "Araceae"),
                commonNames: ["Dragon Tail Plant", "Cebu Blue Pothos"]
            ),
            images: nil
        )

        return [topMatch, alt1, alt2]
    }

    func fetchPlantCareDetails(scientificName: String) async throws -> PlantCareDetails {
        try await Task.sleep(nanoseconds: 500_000_000)

        let lowercased = scientificName.lowercased()
        if lowercased.contains("sansevieria") || lowercased.contains("snake") {
            return PlantCareDetails(
                id: "snake-plant-01",
                commonName: "Snake Plant",
                scientificName: "Sansevieria trifasciata",
                cycle: "Perennial",
                watering: "Water every 2–3 weeks. Allow soil to dry completely between cycles.",
                sunlight: "Low light to bright indirect sunlight.",
                careLevel: "Beginner Friendly",
                careInstructions: "Extremely resilient. Overwatering is the single greatest threat; ensure pot has free drainage.",
                optimalTemperature: "18°C – 27°C (65°F – 80°F)",
                soilType: "Well-draining cactus and succulent mix."
            )
        } else if lowercased.contains("ficus") || lowercased.contains("fig") {
            return PlantCareDetails(
                id: "fiddle-leaf-01",
                commonName: "Fiddle Leaf Fig",
                scientificName: "Ficus lyrata",
                cycle: "Perennial",
                watering: "Water when top 2 inches of soil feel dry to the touch.",
                sunlight: "Bright, consistent filtered sunlight.",
                careLevel: "Intermediate",
                careInstructions: "Avoid drafty air vents. Rotate 90 degrees every month to promote symmetrical trunk growth.",
                optimalTemperature: "16°C – 24°C (60°F – 75°F)",
                soilType: "Peat-based potting mix with perlite."
            )
        } else {
            // Default Monstera
            return PlantCareDetails(
                id: "monstera-01",
                commonName: "Monstera Deliciosa",
                scientificName: "Monstera deliciosa",
                cycle: "Perennial",
                watering: "Water every 1–2 weeks, allowing top 50% of soil volume to dry out.",
                sunlight: "Medium to bright indirect light. Shield from direct scorching sunlight.",
                careLevel: "Easy to Moderate",
                careInstructions: "Clean large broad leaves gently with a damp microfiber cloth. Provide a moss trellis as aerial roots develop.",
                optimalTemperature: "18°C – 30°C (65°F – 85°F)",
                soilType: "Chunky, aerated tropical aroid soil blend (bark, perlite, peat)."
            )
        }
    }

    func diagnosePlantHealth(image: UIImage, speciesName: String) async throws -> PlantCondition {
        try await Task.sleep(nanoseconds: 400_000_000)
        return PlantCondition.optimal
    }
}
