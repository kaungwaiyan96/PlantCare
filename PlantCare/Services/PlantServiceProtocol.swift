import UIKit

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidImageData
    case requestFailed(Error)
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case noResultsFound
    case missingAPIKey
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL could not be formed."
        case .invalidImageData:
            return "The selected image could not be processed for transmission."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Server responded with status code \(statusCode)."
        case .decodingError(let error):
            return "Failed to parse data returned from API: \(error.localizedDescription)"
        case .noResultsFound:
            return "No plant species could be matched with sufficient confidence."
        case .missingAPIKey:
            return "API Key is missing or not configured."
        case .rateLimitExceeded:
            return "API usage quota reached. Please wait or use demo mode."
        }
    }
}

protocol PlantServiceProtocol: Sendable {
    func identifyPlant(image: UIImage) async throws -> [PlantNetMatch]
    func fetchPlantCareDetails(scientificName: String) async throws -> PlantCareDetails
    func diagnosePlantHealth(image: UIImage, speciesName: String) async throws -> PlantCondition
}
