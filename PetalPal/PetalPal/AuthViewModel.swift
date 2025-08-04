import Foundation
import FirebaseAuth
import Combine
import SwiftUI

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
    
    // Asynchronous function to register a new user.
    func register(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
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
}
