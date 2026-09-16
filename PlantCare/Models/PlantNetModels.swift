import Foundation

struct PlantNetResponse: Codable, Sendable {
    let query: PlantNetQuery?
    let results: [PlantNetMatch]
    let remainingIdentificationRequests: Int?
}

struct PlantNetQuery: Codable, Sendable {
    let project: String?
    let organs: [String]?
}

struct PlantNetMatch: Codable, Identifiable, Sendable {
    var id: String { species.scientificNameWithoutAuthor }
    let score: Double
    let species: PlantNetSpecies
    let images: [PlantNetImage]?

    var confidencePercentage: Int {
        Int((score * 100).rounded())
    }

    var bestCommonName: String {
        species.commonNames?.first ?? species.scientificNameWithoutAuthor
    }
}

struct PlantNetSpecies: Codable, Sendable {
    let scientificNameWithoutAuthor: String
    let scientificNameAuthorship: String?
    let genus: PlantNetTaxon?
    let family: PlantNetTaxon?
    let commonNames: [String]?
}

struct PlantNetTaxon: Codable, Sendable {
    let scientificNameWithoutAuthor: String?
}

struct PlantNetImage: Codable, Sendable {
    let organ: String?
    let url: PlantNetImageURL?
}

struct PlantNetImageURL: Codable, Sendable {
    let o: String?
    let m: String?
    let s: String?
}
