import Foundation

struct PerenualListResponse: Codable, Sendable {
    let data: [PerenualSpeciesItem]
    let total: Int?
    let currentPage: Int?
    let lastPage: Int?
}

struct PerenualSpeciesItem: Codable, Identifiable, Sendable {
    let id: Int
    let commonName: String?
    let scientificName: [String]?
    let otherName: [String]?
    let cycle: String?
    let watering: String?
    let sunlight: [String]?
    let defaultImage: PerenualImage?

    enum CodingKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case otherName = "other_name"
        case cycle
        case watering
        case sunlight
        case defaultImage = "default_image"
    }
}

struct PerenualImage: Codable, Sendable {
    let imageId: Int?
    let license: Int?
    let licenseName: String?
    let licenseUrl: String?
    let originalUrl: String?
    let regularUrl: String?
    let mediumUrl: String?
    let smallUrl: String?
    let thumbnail: String?

    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case license
        case licenseName = "license_name"
        case licenseUrl = "license_url"
        case originalUrl = "original_url"
        case regularUrl = "regular_url"
        case mediumUrl = "medium_url"
        case smallUrl = "small_url"
        case thumbnail
    }
}

struct PlantCareDetails: Codable, Identifiable, Sendable {
    let id: String
    let commonName: String
    let scientificName: String
    let cycle: String
    let watering: String
    let sunlight: String
    let careLevel: String
    let careInstructions: String
    let optimalTemperature: String
    let soilType: String
}
