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
                                .font(.title3.weight(.bold))
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
                                                    .font(.subheadline.weight(.bold))
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
                    .padding(.bottom, 10)

                    // Quick Plant Care Tips Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Quick Plant Care Tips")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 14) {
                            ForEach(viewModel.careTips) { tip in
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: tip.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(.botanicalEmerald)
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(Color.botanicalMint.opacity(0.2))
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(tip.title)
                                            .font(.subheadline.weight(.bold))
                                            .foregroundColor(.primary)
                                        Text(tip.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .liquidGlass(cornerRadius: 20, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    Spacer().frame(height: 110)
                }
            }
            .ambientGlassBackground()
            .navigationBarHidden(true)
        }
    }
}
