import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @AppStorage("userFirstName") private var userFirstName: String = "FirstName"
    @AppStorage("userProfileImageFilename") private var userProfileImageFilename: String = ""
    @State private var selectedCareTip: PlantCareTip?
    @State private var showProfileSheet: Bool = false

    // Decoupled from tab switching; initializer retained with default nil for backward-compatibility
    init(selectedTab: Binding<Int>? = nil) {}

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Greeting Header with Interactive Profile Avatar
                    HStack(alignment: .center) {
                        Text("Hello, \(userFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "FirstName" : userFirstName)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Spacer()

                        // Frosted Profile Avatar Trigger for Easy Sign Out / Inspection
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            showProfileSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                Circle()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1.2)

                                if !userProfileImageFilename.isEmpty,
                                   let profileImage = ImageStorageService.shared.loadImage(filename: userProfileImageFilename) {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Text(String((userFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "F" : userFirstName).prefix(1)).uppercased())
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.botanicalEmerald)
                                }
                            }
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
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
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    selectedCareTip = tip
                                } label: {
                                    PlantCareTipCard(tip: tip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer().frame(height: 110)
                }
            }
            .ambientGlassBackground()
            .navigationBarHidden(true)
            .sheet(item: $selectedCareTip) { tip in
                CareTipDetailView(tip: tip)
            }
            .sheet(isPresented: $showProfileSheet) {
                UserProfileSheet()
            }
        }
    }
}

// MARK: - Sophisticated Minimalist Tip Card
struct PlantCareTipCard: View {
    let tip: PlantCareTip

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Refined Minimalist Frosted Icon Badge (No loud colors/glows)
            CareTipIconBadge(
                iconName: tip.iconName,
                fallbackSymbol: tip.fallbackSymbol
            )

            // Clean Structured Content
            VStack(alignment: .leading, spacing: 5) {
                // Neutral Subdued Category Tag & Read Time
                HStack(spacing: 6) {
                    Text(tip.category.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.0)
                        .foregroundColor(.botanicalEmerald)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.botanicalEmerald.opacity(0.08))
                        )

                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.4))

                    Text(tip.readTime)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)

                    Spacer()
                }

                // Tip Title
                Text(tip.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                // Tip Description (Muted, readable)
                Text(tip.description)
                    .font(.system(size: 12, weight: .regular))
                    .lineSpacing(3)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            // Subtle Minimalist Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.35))
        }
        .padding(14)
        .liquidGlass(cornerRadius: 20, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
    }
}

// MARK: - Muted Botanical Frosted Icon Badge
struct CareTipIconBadge: View {
    let iconName: String
    let fallbackSymbol: String

    var body: some View {
        ZStack {
            // Neutral Frosted Squircle (Eliminates loud colors & harsh glows)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )

            // Understated botanical emerald icon glyph
            Image(systemName: fallbackSymbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.botanicalEmerald)
        }
        .frame(width: 40, height: 40)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
