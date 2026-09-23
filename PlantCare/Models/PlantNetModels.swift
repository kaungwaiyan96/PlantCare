import Foundation

struct PlantNetIdentificationOptions: Sendable {
    var project = "all"
    var language = "en"
    var organs: [String] = []
    var includeRelatedImages = false
    var noReject = false
    var numberOfResults: Int?
    var detailed = false
}

struct PlantNetResponse: Codable, Sendable {
    let query: PlantNetQuery?
    let predictedOrgans: [PlantNetPredictedOrgan]?
    let bestMatch: String?
    let results: [PlantNetMatch]
    let otherResults: [PlantNetMatch]?
    let language: String?
    let preferredReferential: String?
    let version: String?
    let remainingIdentificationRequests: Int?
}

struct PlantNetQuery: Codable, Sendable {
    let project: String?
    let images: [String]?
    let organs: [String]?
    let includeRelatedImages: Bool?
    let noReject: Bool?
    let type: String?
}

struct PlantNetPredictedOrgan: Codable, Sendable {
    let image: String?
    let filename: String?
    let organ: String?
    let score: Double?
}

struct PlantNetMatch: Codable, Identifiable, Sendable {
    var id: String { species.scientificNameWithoutAuthor }
    let score: Double
    let species: PlantNetSpecies
    let images: [PlantNetImage]?
    var confidencePercentage: Int { Int((score * 100).rounded()) }
    var bestCommonName: String { species.commonNames?.first ?? species.scientificNameWithoutAuthor }
}

struct PlantNetSpecies: Codable, Sendable {
    let scientificNameWithoutAuthor: String
    let scientificNameAuthorship: String?
    let scientificName: String?
    let genus: PlantNetTaxon?
    let family: PlantNetTaxon?
    let commonNames: [String]?
    let gbif: PlantNetIdentifier?
    let powo: PlantNetIdentifier?
}

struct PlantNetTaxon: Codable, Sendable {
    let scientificNameWithoutAuthor: String?
    let scientificNameAuthorship: String?
    let scientificName: String?
}

struct PlantNetIdentifier: Codable, Sendable { let id: String? }

struct PlantNetImage: Codable, Sendable {
    let organ: String?
    let author: String?
    let license: String?
    let citation: String?
    let url: PlantNetImageURL?
}

struct PlantNetImageURL: Codable, Sendable {
    let o: String?
    let m: String?
    let s: String?
}

extension PlantNetSpecies {
    init(scientificNameWithoutAuthor: String, scientificNameAuthorship: String?, genus: PlantNetTaxon?, family: PlantNetTaxon?, commonNames: [String]?) {
        self.init(scientificNameWithoutAuthor: scientificNameWithoutAuthor, scientificNameAuthorship: scientificNameAuthorship, scientificName: nil, genus: genus, family: family, commonNames: commonNames, gbif: nil, powo: nil)
    }
}

extension PlantNetTaxon {
    init(scientificNameWithoutAuthor: String?) {
        self.init(scientificNameWithoutAuthor: scientificNameWithoutAuthor, scientificNameAuthorship: nil, scientificName: nil)
    }
}

extension PlantNetImage {
    init(organ: String?, url: PlantNetImageURL?) {
        self.init(organ: organ, author: nil, license: nil, citation: nil, url: url)
    }
}

struct PlantNetDisease: Codable, Identifiable, Sendable {
    var id: String { name }
    let label: String?
    let name: String
    let categories: [String]?
    let description: String?
}

struct PlantNetDiseaseMatch: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let score: Double
    let images: [PlantNetImage]?
    let description: String?
}

struct PlantNetDiseaseResponse: Codable, Sendable {
    let query: PlantNetQuery?
    let language: String?
    let results: [PlantNetDiseaseMatch]
    let version: String?
    let remainingIdentificationRequests: Int?
}

struct PlantNetVariety: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let species: PlantNetSpecies?
}

struct PlantNetVarietyMatch: Codable, Identifiable, Sendable {
    var id: String { species.scientificNameWithoutAuthor }
    let score: Double
    let species: PlantNetSpecies
    let images: [PlantNetImage]?
    let varieties: [PlantNetNamedVariety]?
}

struct PlantNetNamedVariety: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let score: Double
    let images: [PlantNetImage]?
}

struct PlantNetVarietyResponse: Codable, Sendable {
    let query: PlantNetQuery?
    let language: String?
    let results: [PlantNetVarietyMatch]
    let version: String?
    let remainingIdentificationRequests: Int?
}

struct PlantNetProject: Codable, Identifiable, Sendable {
    let id: String
    let name: String?
    let description: String?
    let type: String?
    let isPrivate: Bool?
    let isLegacy: Bool?
    let speciesCount: Int?
}

struct PlantNetTaxonomySpecies: Codable, Identifiable, Sendable {
    let id: String?
    let scientificName: String?
    let scientificNameWithoutAuthor: String
    let scientificNameAuthorship: String?
    let genus: String?
    let family: String?
    let commonNames: [String]?
    let gbif: PlantNetIdentifier?
    let powo: PlantNetIdentifier?
}

struct PlantNetAPIStatus: Codable, Sendable { let status: String }

struct PlantNetQuotaEntry: Codable, Sendable {
    let quota: Int?
    let total: Int?
    let count: Int?
    let used: Int?
    let remaining: Int?
}

struct PlantNetQuotaResponse: Codable, Sendable {
    let values: [String: PlantNetQuotaEntry]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        if let quota = try? container.decode([String: PlantNetQuotaEntry].self, forKey: DynamicCodingKey(stringValue: "quota")) {
            values = quota
        } else {
            var decoded: [String: PlantNetQuotaEntry] = [:]
            for key in container.allKeys {
                if let entry = try? container.decode(PlantNetQuotaEntry.self, forKey: key) {
                    decoded[key.stringValue] = entry
                }
            }
            values = decoded
        }
    }
}

struct PlantNetGeoSpecies: Codable, Identifiable, Sendable {
    var id: String { scientificName }
    let scientificName: String
    let author: String?
    let genus: String?
    let family: String?
    let commonNames: [String]?
    let probability: Double?
    let images: [PlantNetImage]?
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil
    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { return nil }
}

struct PlantNetSurveyCost: Codable, Sendable {
    let estimatedCost: Int?
    let query: PlantNetSurveyQuery?
}

struct PlantNetSurveyQuery: Codable, Sendable {
    let project: String?
    let stats: [String: Double]?
}

struct PlantNetSurveyResponse: Codable, Sendable {
    let status: String?
    let query: PlantNetSurveyQuery?
    let results: PlantNetSurveyResults?
    let version: String?
}

struct PlantNetSurveyResults: Codable, Sendable {
    let nbSubQueries: Int?
    let nbMatchingSubQueries: Int?
    let uncovered: Double?
    let species: [PlantNetSurveySpecies]?
}

struct PlantNetSurveySpecies: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let binomial: String?
    let family: String?
    let genus: String?
    let coverage: Double?
    let maxScore: Double?
    let count: Int?
}
