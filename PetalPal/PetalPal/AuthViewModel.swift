import Foundation
import FirebaseAuth
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    @Published var user: User?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for changes in the authentication state.
        authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
            self.isAuthenticated = user != nil
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func login(email: String, password: String) async {
        // ... (existing code)
    }
    
    func register(email: String, password: String, name: String, username: String) async {
        // ... (existing code)
    }

    func logout() async {
        // ... (existing code)
    }
    
    func refreshUserData() async {
        // ... (existing code)
    }
    
    // MARK: - Delete Account
    /// Deletes the user's account and all associated data from Firebase.
    /// Returns true on success, false on failure.
    func deleteAccount() async -> Bool {
        guard let user = self.user else {
            self.errorMessage = "No user is currently signed in."
            return false
        }
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        do {
            // 1. Delete Firestore document
            try await db.collection("users").document(user.uid).delete()
            
            // 2. Delete Storage profile image (optional, ignore errors if it doesn't exist)
            let storageRef = storage.reference().child("profile_images/\(user.uid).jpg")
            try? await storageRef.delete()
            
            // 3. Delete the user from Firebase Authentication
            try await user.delete()
            
            print("Account successfully deleted.")
            // The authStateHandle will automatically set isAuthenticated to false.
            return true
            
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
            self.errorMessage = "Failed to delete account. Please try logging in again to complete this action."
            return false
        }
    }
}
