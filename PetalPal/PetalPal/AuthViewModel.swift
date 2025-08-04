import Foundation
import FirebaseAuth
import Combine
import SwiftUI
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    @Published var user: User?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for changes in the authentication state.
        // This ensures the UI automatically updates when the user logs in or out.
        authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
            self.isAuthenticated = user != nil
        }
    }

    deinit {
        // Clean up the listener when the view model is deallocated.
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Asynchronous function to log a user in.
    func login(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            // Log the full error to the console for debugging purposes.
            print("Login error details: \(error)")
            // Provide more user-friendly error messages for common Firebase issues.
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidEmail:
                    self.errorMessage = "Please enter a valid email address."
                case .wrongPassword:
                    self.errorMessage = "Incorrect password. Please try again."
                case .userNotFound:
                    self.errorMessage = "No user found with this email."
                default:
                    // Fallback for other known errors.
                    self.errorMessage = "An internal error occurred: \(error.localizedDescription)"
                }
            } else {
                // Generic fallback for unknown errors.
                self.errorMessage = "An internal error occurred. Please check your console for details."
            }
        }
    }
    
    // MARK: - Updated Register Function
    // The register function now accepts 'name' and 'username' parameters.
    func register(email: String, password: String, name: String, username: String) async {
        errorMessage = nil
        do {
            // 1. Create the user with email and password in Firebase Auth.
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            
            // 2. Set the user's display name in their Auth profile.
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // MARK: - Create User Document in Firestore
            // 3. Create a new document in Firestore to store additional user data.
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "username": username,
                "name": name,
                "bio": "", // Start with an empty bio
                "creationDate": Timestamp(date: Date()) // Set the join date
            ]
            
            try await db.collection("users").document(result.user.uid).setData(userData)
            
            self.isAuthenticated = true
            
        } catch {
            // Log the full error to the console for debugging purposes.
            print("Registration error details: \(error)")
            // Provide more user-friendly error messages for common Firebase issues.
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidEmail:
                    self.errorMessage = "Please enter a valid email address."
                case .weakPassword:
                    self.errorMessage = "The password is too weak. It must be at least 6 characters long."
                case .emailAlreadyInUse:
                    self.errorMessage = "This email address is already in use."
                default:
                    // Fallback for other known errors.
                    self.errorMessage = "An internal error occurred: \(error.localizedDescription)"
                }
            } else {
                // Generic fallback for unknown errors.
                self.errorMessage = "An internal error occurred. Please check your console for details."
            }
        }
    }

    // Asynchronous function to log a user out.
    func logout() async {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = "Failed to log out: \(error.localizedDescription)"
        }
    }
    
    // MARK: - New Refresh Function
    /// Safely reloads the current user's data from Firebase.
    func refreshUserData() async {
        guard let user = self.user else { return }
        
        do {
            try await user.reload()
            // The AuthStateDidChangeListener will automatically update self.user
            // after a reload, so we don't need to manually assign it.
            // Forcing an update just to be safe in all scenarios.
            self.user = Auth.auth().currentUser
        } catch {
            print("Failed to refresh user data: \(error.localizedDescription)")
        }
    }
}
