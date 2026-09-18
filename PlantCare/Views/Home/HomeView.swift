import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Greeting Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Hello, Plant Parent! 🌿")
                            .font(.title.weight(.bold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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

                    // Scan a Plant Quick Action Banner
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation {
                            selectedTab = 1
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.botanicalEmerald)
                                    .frame(width: 52, height: 52)
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scan & Diagnose Plant")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.primary)
                                Text("Instant AI species identification & health check")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 24, material: .regularMaterial, opacity: 0.9, hasSpecularBorder: true)
                    }
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
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Quick Plant Care Tips Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Quick Plant Care Tips")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
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
