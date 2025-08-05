import SwiftUI
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck
import FirebaseAI

@main
struct PetalPalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var textSizeManager = TextSizeManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Plant.self,
            PlantInfo.self,
            SmartPot.self,
            JournalEntry.self,
            Pot.self,
            UserProfile.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(textSizeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
