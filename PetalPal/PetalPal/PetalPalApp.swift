import SwiftUI
import FirebaseAuth
import FirebaseCore

@main
struct PetalPalApp: App {
    // This sets up Firebase when your app starts.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var textSizeManager = TextSizeManager.shared
    // The AuthViewModel is now created here, at the root of the app.
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            // The ContentView now handles the main logic of the app.
            ContentView()
                .environmentObject(textSizeManager)
                // The AuthViewModel is injected into the environment for all child views.
                .environmentObject(authViewModel)
        }
    }
}

// This class is used to configure Firebase.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
