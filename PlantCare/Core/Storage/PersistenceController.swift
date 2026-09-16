import Foundation
import SwiftData
import UIKit

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([
            SavedPlant.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.mainContext

        let sample1 = SavedPlant(
            commonName: "Monstera Deliciosa",
            scientificName: "Monstera deliciosa",
            confidenceScore: 0.96,
            conditionSummary: "Healthy with vibrant glossy foliage",
            conditionConfidence: 0.92,
            wateringNeeds: "Water every 1-2 weeks; allow top 2 inches of soil to dry out between waterings.",
            sunlightRequirements: "Bright, indirect sunlight (protect from harsh afternoon sun).",
            growthCycle: "Perennial",
            careInstructions: "Wipe large fenestrated leaves periodically with a damp cloth to clear dust and encourage photosynthesis.",
            imageFilename: "preview_monstera.jpg"
        )

        let sample2 = SavedPlant(
            commonName: "Snake Plant",
            scientificName: "Sansevieria trifasciata",
            confidenceScore: 0.98,
            conditionSummary: "Optimal condition, zero pest indicators",
            conditionConfidence: 0.95,
            wateringNeeds: "Water sparingly every 2-3 weeks. Allow soil to completely dry out.",
            sunlightRequirements: "Tolerates low light up to bright indirect light.",
            growthCycle: "Perennial",
            careInstructions: "Very drought-hardy. Use a well-draining cactus or succulent soil mix to prevent root rot.",
            imageFilename: "preview_snake_plant.jpg"
        )

        context.insert(sample1)
        context.insert(sample2)
        return controller
    }()
}
