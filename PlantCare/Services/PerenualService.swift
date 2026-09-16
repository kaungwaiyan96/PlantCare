import Foundation
import UIKit

final class PerenualService: PlantServiceProtocol, @unchecked Sendable {
    static let shared = PerenualService()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func identifyPlant(image: UIImage) async throws -> [PlantNetMatch] {
        return try await PlantNetService.shared.identifyPlant(image: image)
    }

    func fetchPlantCareDetails(scientificName: String) async throws -> PlantCareDetails {
        let apiKey = APIConfig.perenualAPIKey

        guard !apiKey.isEmpty else {
            return try await MockPlantService.shared.fetchPlantCareDetails(scientificName: scientificName)
        }

        var urlComponents = URLComponents(string: "\(APIConfig.perenualBaseURL)/species-list")
        urlComponents?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: scientificName)
        ]

        guard let requestURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return try await MockPlantService.shared.fetchPlantCareDetails(scientificName: scientificName)
            }

            let decoder = JSONDecoder()
            let listResponse = try decoder.decode(PerenualListResponse.self, from: data)

            if let firstMatch = listResponse.data.first {
                let wateringText = firstMatch.watering?.capitalized ?? "Moderate watering"
                let cycleText = firstMatch.cycle?.capitalized ?? "Perennial"
                let sunlightText = firstMatch.sunlight?.joined(separator: ", ").capitalized ?? "Bright indirect light"

                return PlantCareDetails(
                    id: String(firstMatch.id),
                    commonName: firstMatch.commonName?.capitalized ?? scientificName,
                    scientificName: scientificName,
                    cycle: cycleText,
                    watering: "\(wateringText) - check soil moisture weekly.",
                    sunlight: sunlightText,
                    careLevel: "Moderate",
                    careInstructions: "Provide adequate aeration, keep away from artificial heaters or cold draughts, and fertilize lightly during active growing seasons.",
                    optimalTemperature: "18°C – 28°C",
                    soilType: "Well-draining, nutrient-rich potting soil."
                )
            } else {
                return try await MockPlantService.shared.fetchPlantCareDetails(scientificName: scientificName)
            }
        } catch {
            return try await MockPlantService.shared.fetchPlantCareDetails(scientificName: scientificName)
        }
    }

    func diagnosePlantHealth(image: UIImage, speciesName: String) async throws -> PlantCondition {
        return try await MockPlantService.shared.diagnosePlantHealth(image: image, speciesName: speciesName)
    }
}
