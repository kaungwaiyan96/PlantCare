import Foundation

struct PlantCondition: Codable, Hashable, Sendable {
    let name: String
    let probability: Double
    let description: String
    let suggestedAction: String
    let isHealthy: Bool

    var probabilityPercentage: Int {
        Int((probability * 100).rounded())
    }

    static let optimal = PlantCondition(
        name: "Vibrant & Healthy",
        probability: 0.94,
        description: "Foliage exhibits vigorous turgidity, uniform chlorophyll pigmentation, and no discernible signs of blight or pest infestation.",
        suggestedAction: "Continue regular watering and light exposure routine. Monitor seasonal growth.",
        isHealthy: true
    )

    static let underwatered = PlantCondition(
        name: "Subtle Moisture Deficiency",
        probability: 0.82,
        description: "Lower leaves display marginal drooping and minor tip curling, indicative of dry substrate.",
        suggestedAction: "Conduct deep bottom watering until soil is evenly hydrated, then resume standard cycle.",
        isHealthy: false
    )

    static let leafSpot = PlantCondition(
        name: "Superficial Leaf Spot",
        probability: 0.76,
        description: "Small isolated necrotic lesions visible on upper leaf lamina. Likely fungal or moisture settling on foliage.",
        suggestedAction: "Isolate plant from direct drafts. Avoid wetting leaves when watering and gently prune affected areas.",
        isHealthy: false
    )
}
