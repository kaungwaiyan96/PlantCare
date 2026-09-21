import SwiftUI
import SwiftData

@main
struct PlantCareApp: App {
    @State private var persistenceController = PersistenceController.shared
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    MainTabView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.98)),
                            removal: .opacity
                        ))
                } else {
                    AuthView()
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .opacity.combined(with: .scale(scale: 1.02))
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: isLoggedIn)
        }
        .modelContainer(persistenceController.container)
    }
}
