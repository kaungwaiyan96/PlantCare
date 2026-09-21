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
                    ScanPlantView(viewModel: scanViewModel, selectedTab: $selectedTab)
                case 2:
                    MyGardenView()
                default:
                    HomeView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ambientGlassBackground()

            // Custom Floating Liquid Glass Tab Bar (hidden during full-screen camera scanning)
            if !isTabBarHidden && selectedTab != 1 {
                CustomGlassTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 24)
                    .padding(.bottom, -8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(\.isTabBarHidden, $isTabBarHidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Floating Liquid Glass Tab Bar

struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, title: String, tag: Int)] = [
        ("house.fill", "Home", 0),
        ("camera.viewfinder", "Scan", 1),
        ("leaf.fill", "Garden", 2)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab.tag
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab.tag ? .bold : .medium))
                            .foregroundColor(selectedTab == tab.tag ? Color.botanicalEmerald : Color.secondary)

                        Text(tab.title)
                            .font(.caption2.weight(selectedTab == tab.tag ? .bold : .medium))
                            .foregroundColor(selectedTab == tab.tag ? Color.botanicalEmerald : Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedTab == tab.tag ? Color.botanicalMint.opacity(0.3) : Color.clear)
                    )
                }
            }
        }
        .padding(8)
        .liquidGlass(
            cornerRadius: 28,
            material: .ultraThinMaterial,
            opacity: 0.92,
            hasSpecularBorder: true
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    MainTabView()
}
