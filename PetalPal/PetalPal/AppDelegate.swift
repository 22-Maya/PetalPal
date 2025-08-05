import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FirebaseAI

final class AppCheckManager: NSObject, AppCheckProviderFactory {
    public static let shared = AppCheckManager()
    
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if targetEnvironment(simulator)
                return AppCheckDebugProvider(app: app)
        #else
                return AppAttestProvider(app: app)
        #endif
    }
    
    public func setProviderFactory() {
        AppCheck.setAppCheckProviderFactory(self)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppCheckManager.shared.setProviderFactory()
        FirebaseApp.configure()
        return true
    }
}
