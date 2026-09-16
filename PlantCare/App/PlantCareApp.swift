import SwiftUI
import SwiftData

@main
struct PlantCareApp: App {
    @State private var persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(persistenceController.container)
    }
}
