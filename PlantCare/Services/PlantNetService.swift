import UIKit

final class PlantNetService: PlantServiceProtocol, @unchecked Sendable {
    static let shared = PlantNetService()
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let apiRoot = "https://my-api.plantnet.org/v2"

    init(session: URLSession = .shared) { self.session = session }

    func identifyPlant(image: UIImage) async throws -> [PlantNetMatch] {
        try await identifyPlant(images: [image]).results
    }

    func identifyPlant(images: [UIImage], options: PlantNetIdentificationOptions = .init()) async throws -> PlantNetResponse {
        let response: PlantNetResponse = try await postImages(
            path: "/identify/\(options.project)", images: images, organs: options.organs,
            query: [
                "lang": options.language,
                "include-related-images": options.includeRelatedImages ? "true" : "false",
                "no-reject": options.noReject ? "true" : "false",
                "detailed": options.detailed ? "true" : "false",
                "nb-results": options.numberOfResults.map { String($0) }
            ])
        guard !response.results.isEmpty else { throw NetworkError.noResultsFound }
        return response
    }

    func identifyDiseases(images: [UIImage], language: String = "en", organs: [String] = [], includeRelatedImages: Bool = false, noReject: Bool = false, numberOfResults: Int? = nil) async throws -> PlantNetDiseaseResponse {
        try await postImages(path: "/diseases/identify", images: images, organs: organs, query: [
            "lang": language, "include-related-images": includeRelatedImages ? "true" : "false",
            "no-reject": noReject ? "true" : "false", "nb-results": numberOfResults.map { String($0) }
        ])
    }

    func identifyVarieties(images: [UIImage], language: String = "en", organs: [String] = [], includeRelatedImages: Bool = false, noReject: Bool = false, numberOfResults: Int? = nil) async throws -> PlantNetVarietyResponse {
        try await postImages(path: "/varieties/identify", images: images, organs: organs, query: [
            "lang": language, "include-related-images": includeRelatedImages ? "true" : "false",
            "no-reject": noReject ? "true" : "false", "nb-results": numberOfResults.map { String($0) }
        ])
    }

    func status() async throws -> PlantNetAPIStatus { try await get(path: "/_status") }
    func languages() async throws -> [String] { try await get(path: "/languages") }
    func projects(language: String = "en", latitude: Double? = nil, longitude: Double? = nil) async throws -> [PlantNetProject] {
        try await get(path: "/projects", query: ["lang": language, "lat": latitude.map { String($0) }, "lon": longitude.map { String($0) }])
    }
    func species(project: String? = nil, language: String = "en", prefix: String? = nil, page: Int? = nil, pageSize: Int? = nil, includeImages: Bool = false) async throws -> [PlantNetTaxonomySpecies] {
        let path = project.map { "/projects/\($0)/species" } ?? "/species"
        return try await get(path: path, query: ["lang": language, "prefix": prefix, "page": page.map { String($0) }, "pageSize": pageSize.map { String($0) }, "images": includeImages ? "true" : "false"])
    }
    func alignSpecies(name: String, project: String = "all", language: String = "en") async throws -> [PlantNetTaxonomySpecies] {
        try await get(path: "/projects/\(project)/species/align", query: ["name": name, "lang": language])
    }
    func diseases(prefix: String? = nil, language: String = "en") async throws -> [PlantNetDisease] {
        try await get(path: "/diseases", query: ["prefix": prefix, "lang": language])
    }
    func varieties(prefix: String? = nil, language: String = "en") async throws -> [PlantNetVariety] {
        try await get(path: "/varieties", query: ["prefix": prefix, "lang": language])
    }
    func quota() async throws -> PlantNetQuotaResponse { try await get(path: "/quota") }
    func dailyQuota() async throws -> PlantNetQuotaResponse { try await get(path: "/quota/daily") }
    func quotaHistory() async throws -> PlantNetQuotaResponse { try await get(path: "/quota/history") }
    func probableSpecies(topLeftLongitude: Double, topLeftLatitude: Double, bottomRightLongitude: Double, bottomRightLatitude: Double, language: String = "en") async throws -> [PlantNetGeoSpecies] {
        try await get(path: "/prediction/geo/species", query: [
            "topLeftLon": String(topLeftLongitude), "topLeftLat": String(topLeftLatitude),
            "bottomRightLon": String(bottomRightLongitude), "bottomRightLat": String(bottomRightLatitude),
            "lang": language
        ])
    }

    // Survey is a restricted beta feature; these calls are available to enabled accounts.
    func surveyCost(project: String, imageSize: CGSize) async throws -> PlantNetSurveyCost {
        try await postForm(path: "/cost/survey/\(project)", fields: ["size": "\(Int(imageSize.width))x\(Int(imageSize.height))"])
    }
    func survey(image: UIImage, project: String, tileSize: Int = 518, tileStride: Int = 259) async throws -> PlantNetSurveyResponse {
        try await postImages(path: "/survey/tiles/\(project)", images: [image], organs: [], query: ["tile_size": String(tileSize), "tile_stride": String(tileStride), "show_species": "true"])
    }

    func fetchPlantCareDetails(scientificName: String) async throws -> PlantCareDetails {
        try await PerenualService.shared.fetchPlantCareDetails(scientificName: scientificName)
    }

    func diagnosePlantHealth(image: UIImage, speciesName: String) async throws -> PlantCondition {
        let response = try await identifyDiseases(images: [image], numberOfResults: 1)
        guard let result = response.results.first else { return .optimal }
        return PlantCondition(
            name: result.description ?? result.name,
            probability: result.score,
            description: "Pl@ntNet disease match: \(result.name)",
            suggestedAction: "Review the diagnosis and isolate affected tissue if symptoms continue.",
            isHealthy: false
        )
    }

    private func authorizedURL(path: String, query: [String: String?] = [:]) throws -> URL {
        guard !APIConfig.plantNetAPIKey.isEmpty else { throw NetworkError.missingAPIKey }
        guard var components = URLComponents(string: apiRoot + path) else { throw NetworkError.invalidURL }
        var items = query.compactMap { key, value in value.map { URLQueryItem(name: key, value: $0) } }
        items.append(URLQueryItem(name: "api-key", value: APIConfig.plantNetAPIKey))
        components.queryItems = items
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    private func get<T: Decodable>(path: String, query: [String: String?] = [:]) async throws -> T {
        var request = URLRequest(url: try authorizedURL(path: path, query: query))
        request.httpMethod = "GET"
        return try await send(request)
    }

    private func postForm<T: Decodable>(path: String, fields: [String: String]) async throws -> T {
        let boundary = "PlantCare-\(UUID().uuidString)"
        var request = URLRequest(url: try authorizedURL(path: path))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        for field in fields {
            body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(field.key)\"\r\n\r\n\(field.value)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        return try await send(request)
    }

    private func postImages<T: Decodable>(path: String, images: [UIImage], organs: [String], query: [String: String?]) async throws -> T {
        guard !images.isEmpty, images.count <= 5 else { throw NetworkError.invalidImageData }
        let boundary = "PlantCare-\(UUID().uuidString)"
        var request = URLRequest(url: try authorizedURL(path: path, query: query))
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        for (index, image) in images.enumerated() {
            guard let data = image.resizedForUpload().flatMap({ $0.jpegData(compressionQuality: 0.84) }) else { throw NetworkError.invalidImageData }
            if index < organs.count {
                body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"organs\"\r\n\r\n\(organs[index])\r\n".data(using: .utf8)!)
            }
            body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"images\"; filename=\"plant-\(index).jpg\"\r\nContent-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        return try await send(request)
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse(statusCode: -1) }
            guard (200...299).contains(http.statusCode) else {
                if http.statusCode == 429 { throw NetworkError.rateLimitExceeded }
                throw NetworkError.invalidResponse(statusCode: http.statusCode)
            }
            do { return try decoder.decode(T.self, from: data) }
            catch { throw NetworkError.decodingError(error) }
        } catch let error as NetworkError { throw error }
        catch { throw NetworkError.requestFailed(error) }
    }
}

extension UIImage {
    func resizedForUpload(maxDimension: CGFloat = 1024) -> UIImage? {
        let size = self.size
        guard size.width > maxDimension || size.height > maxDimension else { return self }
        let ratio = size.width / size.height
        let newSize = size.width > size.height ? CGSize(width: maxDimension, height: maxDimension / ratio) : CGSize(width: maxDimension * ratio, height: maxDimension)
        return UIGraphicsImageRenderer(size: newSize).image { _ in draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
