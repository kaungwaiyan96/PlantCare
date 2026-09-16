import UIKit

final class PlantNetService: PlantServiceProtocol, @unchecked Sendable {
    static let shared = PlantNetService()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func identifyPlant(image: UIImage) async throws -> [PlantNetMatch] {
        let apiKey = APIConfig.plantNetAPIKey

        // If no API key configured, automatically fallback to realistic Mock Service
        guard !apiKey.isEmpty else {
            return try await MockPlantService.shared.identifyPlant(image: image)
        }

        guard let resizedImage = image.resizedForUpload(),
              let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.invalidImageData
        }

        var urlComponents = URLComponents(string: APIConfig.plantNetBaseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "api-key", value: apiKey),
            URLQueryItem(name: "lang", value: "en")
        ]

        guard let requestURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        var body = Data()

        // Organ field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"organs\"\r\n\r\n".data(using: .utf8)!)
        body.append("leaf\r\n".data(using: .utf8)!)

        // Image file part
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"plant.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse(statusCode: -1)
            }

            if httpResponse.statusCode == 404 {
                throw NetworkError.noResultsFound
            } else if httpResponse.statusCode == 429 {
                throw NetworkError.rateLimitExceeded
            } else if !(200...299).contains(httpResponse.statusCode) {
                throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            let decoded = try decoder.decode(PlantNetResponse.self, from: data)
            guard !decoded.results.isEmpty else {
                throw NetworkError.noResultsFound
            }
            return decoded.results
        } catch let error as NetworkError {
            throw error
        } catch let decodingErr as DecodingError {
            throw NetworkError.decodingError(decodingErr)
        } catch {
            // If offline / network dropped, gracefully fallback to mock for live presentation stability
            if (error as NSError).domain == NSURLErrorDomain {
                return try await MockPlantService.shared.identifyPlant(image: image)
            }
            throw NetworkError.requestFailed(error)
        }
    }

    func fetchPlantCareDetails(scientificName: String) async throws -> PlantCareDetails {
        return try await PerenualService.shared.fetchPlantCareDetails(scientificName: scientificName)
    }

    func diagnosePlantHealth(image: UIImage, speciesName: String) async throws -> PlantCondition {
        return try await MockPlantService.shared.diagnosePlantHealth(image: image, speciesName: speciesName)
    }
}

extension UIImage {
    func resizedForUpload(maxDimension: CGFloat = 1024) -> UIImage? {
        let size = self.size
        guard size.width > maxDimension || size.height > maxDimension else {
            return self
        }
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
