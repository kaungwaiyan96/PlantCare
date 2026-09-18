import SwiftUI

struct TabBarHiddenKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isTabBarHidden: Binding<Bool> {
        get { self[TabBarHiddenKey.self] }
        set { self[TabBarHiddenKey.self] = newValue }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var isTabBarHidden: Bool = false
    @StateObject private var scanViewModel = ScanViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    HomeView(selectedTab: $selectedTab)
                case 1:
                    ScanPlantView(viewModel: scanViewModel)
                case 2:
                    MyGardenView()
                default:
                    HomeView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ambientGlassBackground()

            // Refined Floating Liquid Glass Island Tab Bar
            if !isTabBarHidden {
                CustomGlassTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(\.isTabBarHidden, $isTabBarHidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Refined Liquid Glass Tab Bar

struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var tabAnimationNamespace
    @Environment(\.colorScheme) private var colorScheme

    struct TabItem {
        let tag: Int
        let title: String
        let unselectedIcon: String
        let selectedIcon: String
    }

    private let tabs: [TabItem] = [
        TabItem(tag: 0, title: "Home", unselectedIcon: "house", selectedIcon: "house.fill"),
        TabItem(tag: 1, title: "Scan", unselectedIcon: "camera.viewfinder", selectedIcon: "camera.viewfinder"),
        TabItem(tag: 2, title: "Garden", unselectedIcon: "leaf", selectedIcon: "leaf.fill")
    ]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs, id: \.tag) { tab in
                let isSelected = selectedTab == tab.tag

                Button {
                    if selectedTab != tab.tag {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                            selectedTab = tab.tag
                        }
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: isSelected ? tab.selectedIcon : tab.unselectedIcon)
                            .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(
                                isSelected
                                    ? (colorScheme == .dark ? Color.botanicalMint : Color.botanicalEmerald)
                                    : Color.secondary.opacity(0.8)
                            )
                            .scaleEffect(isSelected ? 1.05 : 1.0)

                        Text(tab.title)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .medium, design: .rounded))
                            .foregroundColor(
                                isSelected
                                    ? (colorScheme == .dark ? Color.botanicalMint : Color.botanicalEmerald)
                                    : Color.secondary.opacity(0.8)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .contentShape(Rectangle())
                    .background {
                        if isSelected {
                            // Fluid Sliding Pill Indicator (Slim & Sleek)
                            Capsule(style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.botanicalMint.opacity(colorScheme == .dark ? 0.28 : 0.16),
                                            Color.botanicalEmerald.opacity(colorScheme == .dark ? 0.18 : 0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(colorScheme == .dark ? 0.35 : 0.65),
                                                    Color.botanicalMint.opacity(0.25)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.8
                                        )
                                )
                                .matchedGeometryEffect(id: "activeTabIndicator", in: tabAnimationNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            ZStack {
                // Liquid Glass Backing Material
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.95)

                // Botanical Ambient Inner Tone
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.06 : 0.35),
                                Color.botanicalMint.opacity(colorScheme == .dark ? 0.05 : 0.03),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Refined Specular Light Rim
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.45 : 0.85),
                                .white.opacity(colorScheme == .dark ? 0.15 : 0.35),
                                .clear,
                                .white.opacity(colorScheme == .dark ? 0.08 : 0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            }
        )
        // Clean single elevation shadow
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.10),
            radius: 16,
            x: 0,
            y: 6
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    MainTabView()
}
