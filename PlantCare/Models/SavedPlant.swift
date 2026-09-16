import Foundation
import SwiftData

@Model
final class SavedPlant {
    @Attribute(.unique) var id: UUID
    var commonName: String
    var scientificName: String
    var confidenceScore: Double
    var conditionSummary: String?
    var conditionConfidence: Double?
    var wateringNeeds: String
    var sunlightRequirements: String
    var growthCycle: String
    var careInstructions: String
    var imageFilename: String
    var dateAdded: Date

    init(
        id: UUID = UUID(),
        commonName: String,
        scientificName: String,
        confidenceScore: Double = 0.95,
        conditionSummary: String? = nil,
        conditionConfidence: Double? = nil,
        wateringNeeds: String = "Moderate watering",
        sunlightRequirements: String = "Bright indirect sunlight",
        growthCycle: String = "Perennial",
        careInstructions: String = "Keep soil moist but well-drained.",
        imageFilename: String,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.confidenceScore = confidenceScore
        self.conditionSummary = conditionSummary
        self.conditionConfidence = conditionConfidence
        self.wateringNeeds = wateringNeeds
        self.sunlightRequirements = sunlightRequirements
        self.growthCycle = growthCycle
        self.careInstructions = careInstructions
        self.imageFilename = imageFilename
        self.dateAdded = dateAdded
    }
}
