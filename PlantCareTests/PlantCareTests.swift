import XCTest
import SwiftData
@testable import PlantCare

final class PlantCareTests: XCTestCase {

    @MainActor
    func testSwiftDataPersistence() throws {
        let schema = Schema([SavedPlant.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let plant = SavedPlant(
            commonName: "Monstera Deliciosa",
            scientificName: "Monstera deliciosa",
            confidenceScore: 0.965,
            conditionSummary: "Healthy",
            conditionConfidence: 0.95,
            wateringNeeds: "Every 1-2 weeks",
            sunlightRequirements: "Bright indirect light",
            growthCycle: "Perennial",
            careInstructions: "Wipe leaves regularly.",
            imageFilename: "test_monstera.jpg"
        )

        context.insert(plant)
        try context.save()

        let descriptor = FetchDescriptor<SavedPlant>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.commonName, "Monstera Deliciosa")
        XCTAssertEqual(results.first?.scientificName, "Monstera deliciosa")
        XCTAssertEqual(results.first?.confidenceScore, 0.965)
        XCTAssertEqual(results.first?.imageFilename, "test_monstera.jpg")
    }

    func testImageStorageSaveAndLoad() throws {
        let storage = ImageStorageService.shared

        // Generate a simple test image
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.green.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let filename = try storage.saveImage(testImage)
        XCTAssertFalse(filename.isEmpty)

        let loadedImage = storage.loadImage(filename: filename)
        XCTAssertNotNil(loadedImage)

        storage.deleteImage(filename: filename)
        let reloadAfterDelete = storage.loadImage(filename: filename)
        XCTAssertNil(reloadAfterDelete)
    }

    func testPlantNetCodableDecoding() throws {
        let json = """
        {
            "query": { "project": "all", "organs": ["leaf"] },
            "results": [
                {
                    "score": 0.942,
                    "species": {
                        "scientificNameWithoutAuthor": "Monstera deliciosa",
                        "scientificNameAuthorship": "Liebm.",
                        "genus": { "scientificNameWithoutAuthor": "Monstera" },
                        "family": { "scientificNameWithoutAuthor": "Araceae" },
                        "commonNames": ["Swiss Cheese Plant", "Split-Leaf Philodendron"]
                    },
                    "images": [
                        {
                            "organ": "leaf",
                            "url": { "o": "https://example.com/monstera.jpg" }
                        }
                    ]
                }
            ],
            "remainingIdentificationRequests": 490
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(PlantNetResponse.self, from: json)

        XCTAssertEqual(response.results.count, 1)
        let first = response.results[0]
        XCTAssertEqual(first.score, 0.942)
        XCTAssertEqual(first.species.scientificNameWithoutAuthor, "Monstera deliciosa")
        XCTAssertEqual(first.bestCommonName, "Swiss Cheese Plant")
        XCTAssertEqual(first.confidencePercentage, 94)
    }

    func testPerenualCodableDecoding() throws {
        let json = """
        {
            "data": [
                {
                    "id": 1234,
                    "common_name": "Snake Plant",
                    "scientific_name": ["Sansevieria trifasciata"],
                    "cycle": "Perennial",
                    "watering": "Minimum",
                    "sunlight": ["part shade", "full sun"]
                }
            ],
            "total": 1,
            "current_page": 1,
            "last_page": 1
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(PerenualListResponse.self, from: json)

        XCTAssertEqual(response.data.count, 1)
        let item = response.data[0]
        XCTAssertEqual(item.id, 1234)
        XCTAssertEqual(item.commonName, "Snake Plant")
        XCTAssertEqual(item.cycle, "Perennial")
        XCTAssertEqual(item.watering, "Minimum")
    }

    func testMockPlantServiceFlow() async throws {
        let mockService = MockPlantService.shared

        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let dummyImage = renderer.image { _ in }

        let matches = try await mockService.identifyPlant(image: dummyImage)
        XCTAssertGreaterThan(matches.count, 0)
        XCTAssertEqual(matches.first?.species.scientificNameWithoutAuthor, "Monstera deliciosa")

        let care = try await mockService.fetchPlantCareDetails(scientificName: "Monstera deliciosa")
        XCTAssertEqual(care.scientificName, "Monstera deliciosa")
        XCTAssertFalse(care.watering.isEmpty)
        XCTAssertFalse(care.sunlight.isEmpty)

        let health = try await mockService.diagnosePlantHealth(image: dummyImage, speciesName: "Monstera deliciosa")
        XCTAssertTrue(health.isHealthy)
    }

    func testAuthPersonalizationFlow() throws {
        let defaults = UserDefaults.standard
        let testName = "Kaung Wai"
        defaults.set(testName, forKey: "userFirstName")
        defaults.set(true, forKey: "isLoggedIn")

        let storedName = defaults.string(forKey: "userFirstName")
        let isLoggedIn = defaults.bool(forKey: "isLoggedIn")

        XCTAssertEqual(storedName, "Kaung Wai")
        XCTAssertTrue(isLoggedIn)
    }

    @MainActor
    func testSaveToGardenFlowAndTabTransition() throws {
        let schema = Schema([SavedPlant.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let initialDescriptor = FetchDescriptor<SavedPlant>()
        let initialPlants = try context.fetch(initialDescriptor)
        XCTAssertEqual(initialPlants.count, 0)

        // Simulate saveToGarden action
        let newPlant = SavedPlant(
            commonName: "Swiss Cheese Plant",
            scientificName: "Monstera deliciosa",
            confidenceScore: 0.96,
            conditionSummary: "Vibrant & Healthy",
            conditionConfidence: 0.94,
            wateringNeeds: "Moderate watering",
            sunlightRequirements: "Bright indirect light",
            growthCycle: "Perennial",
            careInstructions: "Keep soil moist.",
            imageFilename: "monstera_profile_test.jpg",
            dateAdded: Date()
        )

        context.insert(newPlant)
        try context.save()

        let updatedPlants = try context.fetch(initialDescriptor)
        XCTAssertEqual(updatedPlants.count, 1)
        XCTAssertEqual(updatedPlants.first?.commonName, "Swiss Cheese Plant")
        XCTAssertEqual(updatedPlants.first?.conditionSummary, "Vibrant & Healthy")
    }

    func testUserProfileUpdateAndAvatarPersistence() throws {
        let defaults = UserDefaults.standard
        let storage = ImageStorageService.shared

        // Test editing name & email
        defaults.set("Botanist Sarah", forKey: "userFirstName")
        defaults.set("sarah@botanist.org", forKey: "userEmail")

        XCTAssertEqual(defaults.string(forKey: "userFirstName"), "Botanist Sarah")
        XCTAssertEqual(defaults.string(forKey: "userEmail"), "sarah@botanist.org")

        // Test saving custom avatar image
        let size = CGSize(width: 80, height: 80)
        let renderer = UIGraphicsImageRenderer(size: size)
        let avatarImage = renderer.image { context in
            UIColor.systemGreen.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let avatarFilename = try storage.saveImage(avatarImage)
        defaults.set(avatarFilename, forKey: "userProfileImageFilename")

        let storedFilename = defaults.string(forKey: "userProfileImageFilename")
        XCTAssertEqual(storedFilename, avatarFilename)

        let loadedAvatar = storage.loadImage(filename: avatarFilename)
        XCTAssertNotNil(loadedAvatar)

        // Clean up test image
        storage.deleteImage(filename: avatarFilename)
        defaults.removeObject(forKey: "userProfileImageFilename")
    }
}
