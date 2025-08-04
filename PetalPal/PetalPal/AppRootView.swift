import SwiftUI
import Charts
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck

struct AppRootView: View {
    @StateObject var authViewModel = AuthViewModel()
    @EnvironmentObject var textSizeManager: TextSizeManager
    
    var body: some View {
        if authViewModel.isAuthenticated {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(textSizeManager)
        } else {
            LoginView()
                .environmentObject(authViewModel)
                .environmentObject(textSizeManager)
        }
    }
}
