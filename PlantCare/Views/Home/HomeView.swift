import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @AppStorage("userFirstName") private var userFirstName: String = "FirstName"

    // Decoupled from tab switching; initializer retained with default nil for backward-compatibility
    init(selectedTab: Binding<Int>? = nil) {}

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Greeting Header
                    HStack {
                        Text("Hello, \(userFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "FirstName" : userFirstName)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Frosted Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search flora, care guides, tips...", text: $viewModel.searchText)
                            .foregroundColor(.primary)
                    }
                    .padding(14)
                    .liquidGlass(cornerRadius: 20, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                    .padding(.horizontal, 20)

                    // Featured Plants Carousel
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Featured Botanical Species")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("See All")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.botanicalEmerald)
                        }
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.filteredPlants) { plant in
                                    NavigationLink {
                                        PlantProfileView(
                                            plantName: plant.name,
                                            scientificName: plant.scientificName,
                                            imageURL: plant.imageURL,
                                            watering: plant.watering,
                                            sunlight: plant.sunlight
                                        )
                                    } label: {
                                        VStack(alignment: .leading, spacing: 10) {
                                            AsyncImage(url: URL(string: plant.imageURL)) { phase in
                                                switch phase {
                                                case .empty:
                                                    Rectangle()
                                                        .fill(Color.secondary.opacity(0.2))
                                                        .overlay(ProgressView())
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                case .failure(_):
                                                    Rectangle()
                                                        .fill(Color.botanicalSage.opacity(0.3))
                                                        .overlay(Image(systemName: "leaf.fill").foregroundColor(.botanicalEmerald))
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(width: 170, height: 160)
                                            .cornerRadius(18)
                                            .clipped()

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(plant.name)
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                Text(plant.scientificName)
                                                    .font(.caption.italic())
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .padding(12)
                                        .frame(width: 194)
                                        .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 6)
                            .padding(.bottom, 18)
                        }
                    }
                    .padding(.bottom, 6)

                    // MARK: - Redesigned Quick Plant Care Tips Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Quick Plant Care Tips")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("Curated")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.botanicalEmerald)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.botanicalMint.opacity(0.2))
                                )
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 14) {
                            ForEach(viewModel.careTips) { tip in
                                PlantCareTipCard(tip: tip)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer().frame(height: 110)
                }
            }
            .ambientGlassBackground()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Dedicated Care Tip Card Component
struct PlantCareTipCard: View {
    let tip: PlantCareTip

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Thematic Icon Badge
            CareTipIconBadge(
                iconName: tip.iconName,
                fallbackSymbol: tip.fallbackSymbol,
                themeColor: tip.themeColor
            )

            // Structured Content
            VStack(alignment: .leading, spacing: 6) {
                // Category Pill & Read Time
                HStack(spacing: 8) {
                    Text(tip.category.uppercased())
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(1.0)
                        .foregroundColor(tip.themeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(tip.themeColor.opacity(0.14))
                        )

                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.6))

                    Text(tip.readTime)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)

                    Spacer()
                }

                // Tip Title
                Text(tip.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                // Tip Description
                Text(tip.description)
                    .font(.system(size: 13, weight: .regular))
                    .lineSpacing(3.5)
                    .foregroundColor(.primary.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 22, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
    }
}

// MARK: - Resilient Flaticon & SF Symbol Badge Loader
struct CareTipIconBadge: View {
    let iconName: String
    let fallbackSymbol: String
    let themeColor: Color

    var body: some View {
        ZStack {
            // Frosted squircle container with ambient color gradient
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            themeColor.opacity(0.22),
                            themeColor.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(themeColor.opacity(0.35), lineWidth: 1)
                )

            // Primary: Flaticon Asset; Secondary Fallback: Polished SF Symbol
            if let image = loadIconImage(named: iconName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            } else {
                Image(systemName: fallbackSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeColor)
            }
        }
        .frame(width: 48, height: 48)
        .shadow(color: themeColor.opacity(0.18), radius: 6, x: 0, y: 3)
    }

    /// Resilient loader: checks Asset Catalog, Main Bundle root, and Resources/Icons folder
    private func loadIconImage(named name: String) -> UIImage? {
        if let asset = UIImage(named: name) {
            return asset
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Icons") {
            return UIImage(contentsOfFile: path)
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Resources/Icons") {
            return UIImage(contentsOfFile: path)
        }
        // Direct filesystem fallback for simulator run environments
        let directPath = "PlantCare/Resources/Icons/\(name).png"
        if FileManager.default.fileExists(atPath: directPath) {
            return UIImage(contentsOfFile: directPath)
        }
        return nil
    }
}
