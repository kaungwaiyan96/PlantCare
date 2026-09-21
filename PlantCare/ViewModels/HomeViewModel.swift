import SwiftUI

struct FeaturedPlant: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let scientificName: String
    let imageURL: String
    let sunlight: String
    let watering: String
    let careLevel: String
    let description: String
}

// MARK: - Step-by-Step Execution Model
struct CareStep: Identifiable, Hashable {
    let id = UUID()
    let stepNumber: Int
    let title: String
    let instruction: String
}

// MARK: - Rich Plant Care Tip Model
struct PlantCareTip: Identifiable {
    let id = UUID()
    let category: String
    let title: String
    let subtitle: String
    let description: String
    let theScience: String
    let steps: [CareStep]
    let suitablePlants: [String]
    let proTip: String
    let iconName: String
    let fallbackSymbol: String
    let themeColor: Color
    let readTime: String
    let difficulty: String
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var featuredPlants: [FeaturedPlant] = []
    @Published var careTips: [PlantCareTip] = []

    init() {
        loadData()
    }

    private func loadData() {
        featuredPlants = [
            FeaturedPlant(
                name: "Monstera Deliciosa",
                scientificName: "Monstera deliciosa",
                imageURL: "https://images.unsplash.com/photo-1614594975525-e45190c55d0b",
                sunlight: "Bright Indirect",
                watering: "Every 1–2 weeks",
                careLevel: "Easy",
                description: "Famous for its iconic fenestrated leaves. Thrives in warm, humid indoor spaces."
            ),
            FeaturedPlant(
                name: "Fiddle Leaf Fig",
                scientificName: "Ficus lyrata",
                imageURL: "https://images.unsplash.com/photo-1545241047-6083a3684587",
                sunlight: "Filtered Sunlight",
                watering: "When dry (2 in)",
                careLevel: "Moderate",
                description: "Striking architectural foliage. Prefers stable positions away from cold drafts."
            ),
            FeaturedPlant(
                name: "Snake Plant",
                scientificName: "Sansevieria trifasciata",
                imageURL: "https://images.unsplash.com/photo-1599598425947-490d565612d3",
                sunlight: "Low to Bright",
                watering: "Every 2–3 weeks",
                careLevel: "Very Easy",
                description: "Remarkably indestructible. Excellent air purifying qualities and low water needs."
            ),
            FeaturedPlant(
                name: "Golden Pothos",
                scientificName: "Epipremnum aureum",
                imageURL: "https://images.unsplash.com/photo-1581783342605-2d49fac7f787",
                sunlight: "Medium Light",
                watering: "When dry",
                careLevel: "Beginner",
                description: "Cascading vine with heart-shaped leaves variegated with warm gold splashes."
            )
        ]

        careTips = [
            PlantCareTip(
                category: "Hydration",
                title: "Bottom Watering Technique",
                subtitle: "Sub-irrigation for deep root hydration & gnat prevention",
                description: "Allow thirsty potted plants to absorb moisture from the base to prevent root rot and fungus gnats.",
                theScience: "By allowing the potting mix to draw moisture upward via capillary action, root zones receive uniform saturation. The top 1 inch of soil remains mostly dry, depriving fungus gnat larvae of damp soil and preventing stem crown rot.",
                steps: [
                    CareStep(stepNumber: 1, title: "Check Topsoil Dryness", instruction: "Insert your index finger 1–2 inches into the soil. If it feels completely dry and the pot feels lightweight, the plant is ready for sub-irrigation."),
                    CareStep(stepNumber: 2, title: "Prepare Shallow Basin", instruction: "Fill a bowl, tray, or sink with 1–2 inches of room-temperature, dechlorinated or filtered water."),
                    CareStep(stepNumber: 3, title: "Submerge Potted Plant", instruction: "Place the planter into the basin. Ensure the pot has drainage holes at the bottom so capillary action can begin."),
                    CareStep(stepNumber: 4, title: "Soak for 15–30 Minutes", instruction: "Allow the soil to wick moisture upward until the surface feels cool and slightly damp to the touch."),
                    CareStep(stepNumber: 5, title: "Drain Excess Thoroughly", instruction: "Lift the plant out and let excess water drain away for 10 minutes before placing it back onto its decorative saucer.")
                ],
                suitablePlants: ["Monstera", "Calathea", "African Violet", "Pothos", "Peace Lily"],
                proTip: "Never leave your plants sitting in standing water for longer than 45 minutes, as roots need access to oxygen to avoid root rot.",
                iconName: "flaticon_watering_can",
                fallbackSymbol: "drop.fill",
                themeColor: Color(hex: 0x0288D1),
                readTime: "1 min read",
                difficulty: "Beginner"
            ),
            PlantCareTip(
                category: "Maintenance",
                title: "Foliage Dusting Routine",
                subtitle: "Unlocking maximum photosynthetic efficiency & deterring pests",
                description: "Wipe broad leaves with a damp microfiber cloth to maximize photosynthetic efficiency and deter pests.",
                theScience: "Indoor dust, cooking grease, and pet dander form an opaque microscopic layer on leaves. This film can block up to 35% of incoming solar radiation, slowing down chlorophyll synthesis and trapping dust-mite colonies.",
                steps: [
                    CareStep(stepNumber: 1, title: "Prepare Soft Microfiber", instruction: "Dampen a clean microfiber cloth with lukewarm distilled or filtered water. Avoid commercial leaf-shine sprays as their oils clog leaf stomata."),
                    CareStep(stepNumber: 2, title: "Support Leaf Underside", instruction: "Place your open palm gently behind each leaf to support its weight and prevent creasing or stem snap while wiping."),
                    CareStep(stepNumber: 3, title: "Wipe Outward in One Motion", instruction: "Gently glide the cloth from the stem base outward along the leaf veins toward the tip in a single smooth, continuous stroke."),
                    CareStep(stepNumber: 4, title: "Scout for Pests", instruction: "Inspect the leaf underside and stem joints for fine webbing, thrips, scale, or powdery mildew residue."),
                    CareStep(stepNumber: 5, title: "Optional Neem Polish", instruction: "For added shine and natural protection, add one drop of cold-pressed organic neem oil to your damp cloth once a month.")
                ],
                suitablePlants: ["Fiddle Leaf Fig", "Rubber Tree", "Bird of Paradise", "Snake Plant", "Philodendron"],
                proTip: "Dust your plants in the morning so any residual droplets have ample time to evaporate under natural air circulation during the day.",
                iconName: "flaticon_foliage_leaf",
                fallbackSymbol: "leaf.fill",
                themeColor: Color.botanicalJade,
                readTime: "2 min read",
                difficulty: "Easy"
            ),
            PlantCareTip(
                category: "Lighting",
                title: "Seasonal Sunlight Rotation",
                subtitle: "Balanced phototropic canopy architecture & symmetrical foliage",
                description: "Rotate houseplants 90 degrees monthly to ensure balanced growth and prevent phototropic leaning toward windows.",
                theScience: "Plants synthesize the auxin growth hormone in apical shoots. Auxin migrates away from light toward the shaded side of stems, causing those cells to elongate faster and bending the entire plant toward the window (phototropism).",
                steps: [
                    CareStep(stepNumber: 1, title: "Identify Primary Light Source", instruction: "Note which window or skylight delivers the strongest natural foot-candles to your plant throughout the day."),
                    CareStep(stepNumber: 2, title: "Perform 90° Clockwise Turn", instruction: "Gently turn the planter 90 degrees (one quarter turn) clockwise. Mark the back with a tiny sticker to track rotations."),
                    CareStep(stepNumber: 3, title: "Observe Hormone Re-alignment", instruction: "Within 48 to 72 hours, the leaves will gradually twist to face the incoming light, developing a symmetrical, balanced shape."),
                    CareStep(stepNumber: 4, title: "Adjust for Seasonal Sun Path", instruction: "In autumn and winter when the sun's trajectory drops lower, shift light-hungry plants 1–2 feet closer to the window.")
                ],
                suitablePlants: ["Monstera", "Ficus Lyrata", "Umbrella Tree", "Pilea Peperomioides", "Dracaena"],
                proTip: "If a plant has developed a severe lean, use gentle bamboo stakes for 2 weeks after turning to support the stem while cells adjust.",
                iconName: "flaticon_sunlight",
                fallbackSymbol: "sun.max.fill",
                themeColor: Color.botanicalAmber,
                readTime: "1 min read",
                difficulty: "Effortless"
            )
        ]
    }

    var filteredPlants: [FeaturedPlant] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return featuredPlants
        }
        return featuredPlants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.scientificName.localizedCaseInsensitiveContains(searchText)
        }
    }
}
