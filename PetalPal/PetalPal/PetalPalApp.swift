import SwiftUI
import Charts
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck

@main
struct PetalPalApp: App {
    let container: ModelContainer
    @StateObject private var textSizeManager = TextSizeManager.shared
    
    init() {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pot.self,
            UserProfile.self, // Include the UserProfile model in the schema
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
            NavigationStack {
                ContentView()
                    .background(Color(red: 249/255, green: 248/255, blue: 241/255))
            }
            .background(Color(red: 249/255, green: 248/255, blue: 241/255))
            .environmentObject(textSizeManager)
            AppRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
