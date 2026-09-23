import SwiftUI
import SwiftData
import PhotosUI

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isAnalyzing: Bool = false
    @Published var errorMessage: String?
    @Published var matches: [PlantNetMatch] = []
    @Published var selectedMatch: PlantNetMatch?
    @Published var careDetails: PlantCareDetails?
    @Published var condition: PlantCondition?
    @Published var isSaved: Bool = false
    @Published private(set) var savedPlantID: UUID?
    @Published var navigateToResult: Bool = false

    private let plantService: PlantServiceProtocol

    init(plantService: PlantServiceProtocol = PlantNetService.shared) {
        self.plantService = plantService
    }

    func identifyCurrentPhoto(context: ModelContext? = nil) async {
        guard let image = selectedImage else {
            errorMessage = "Please capture or select a plant photo first."
            return
        }

        isAnalyzing = true
        errorMessage = nil
        isSaved = false

        do {
            let results = try await plantService.identifyPlant(image: image)
            guard let topMatch = results.first else {
                throw NetworkError.noResultsFound
            }

            self.matches = results
            self.selectedMatch = topMatch

            // Fetch care details for top match
            async let careFetch = plantService.fetchPlantCareDetails(scientificName: topMatch.species.scientificNameWithoutAuthor)
            async let conditionFetch = plantService.diagnosePlantHealth(image: image, speciesName: topMatch.species.scientificNameWithoutAuthor)

            let (care, cond) = try await (careFetch, conditionFetch)
            self.careDetails = care
            self.condition = cond

            // Persist the complete identification before showing the result. This
            // keeps the Garden tab backed by local data even if the result screen
            // is dismissed before the user opens the care profile.
            if let context {
                try persistPlantToGarden(context: context)
            }
            self.navigateToResult = true
        } catch let error as LocalizedError {
            self.errorMessage = error.errorDescription ?? error.localizedDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    func selectCandidate(_ match: PlantNetMatch) async {
        self.selectedMatch = match
        isAnalyzing = true
        do {
            let care = try await plantService.fetchPlantCareDetails(scientificName: match.species.scientificNameWithoutAuthor)
            self.careDetails = care
        } catch {
            // Keep existing care or default
        }
        isAnalyzing = false
    }

    func savePlantToGarden(context: ModelContext) {
        do {
            try persistPlantToGarden(context: context)
        } catch {
            self.errorMessage = "Failed to save plant: \(error.localizedDescription)"
        }
    }

    private func persistPlantToGarden(context: ModelContext) throws {
        guard savedPlantID == nil,
              let image = selectedImage,
              let match = selectedMatch else { return }

        let filename = try ImageStorageService.shared.saveImage(image)
        let plant = SavedPlant(
            commonName: match.bestCommonName,
            scientificName: match.species.scientificNameWithoutAuthor,
            confidenceScore: match.score,
            conditionSummary: condition?.name ?? "Optimal Health",
            conditionConfidence: condition?.probability ?? 0.9,
            wateringNeeds: careDetails?.watering ?? "Moderate watering; keep soil moist.",
            sunlightRequirements: careDetails?.sunlight ?? "Bright indirect light.",
            growthCycle: careDetails?.cycle ?? "Perennial",
            careInstructions: careDetails?.careInstructions ?? "Maintain consistent moisture and adequate airflow.",
            imageFilename: filename,
            dateAdded: Date()
        )

        context.insert(plant)
        try context.save()
        savedPlantID = plant.id

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isSaved = true
        }
    }

    func reset() {
        selectedImage = nil
        isAnalyzing = false
        errorMessage = nil
        matches = []
        selectedMatch = nil
        careDetails = nil
        condition = nil
        isSaved = false
        savedPlantID = nil
        navigateToResult = false
    }
}
