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
    
    // MARK: - Published Tasks
    // This array will hold the user's tasks and update the UI when changed.
    @Published var tasks: [TaskItem] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for changes in the authentication state.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.user = user
            self.isAuthenticated = user != nil
            
            if let user = user {
                // If a user is logged in, start listening for task updates.
                self.fetchTasks(userId: user.uid)
            } else {
                // If the user logs out, stop listening and clear the tasks.
                self.listenerRegistration?.remove()
                self.tasks = []
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        listenerRegistration?.remove()
    }
    
    // MARK: - Authentication Functions
    
    /// Logs a user in with the provided email and password.
    func login(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidEmail:
                    self.errorMessage = "Please enter a valid email address."
                case .wrongPassword:
                    self.errorMessage = "Incorrect password. Please try again."
                case .userNotFound:
                    self.errorMessage = "No user found with this email."
                default:
                    self.errorMessage = "An internal error occurred: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "An internal error occurred. Please check your console for details."
            }
        }
    }
    
    /// Registers a new user with email, password, name, and username.
    func register(email: String, password: String, name: String, username: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            let userData: [String: Any] = [
                "username": username,
                "name": name,
                "bio": "",
                "creationDate": Timestamp(date: Date())
            ]
            try await db.collection("users").document(result.user.uid).setData(userData)
            
            self.isAuthenticated = true
        } catch {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidEmail:
                    self.errorMessage = "Please enter a valid email address."
                case .weakPassword:
                    self.errorMessage = "The password is too weak. It must be at least 6 characters long."
                case .emailAlreadyInUse:
                    self.errorMessage = "This email address is already in use."
                default:
                    self.errorMessage = "An internal error occurred: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "An internal error occurred. Please check your console for details."
            }
        }
    }

    /// Logs the current user out.
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
    
    /// Safely reloads the current user's data from Firebase.
    func refreshUserData() async {
        guard let user = self.user else { return }
        
        do {
            try await user.reload()
            self.user = Auth.auth().currentUser
        } catch {
            print("Failed to refresh user data: \(error.localizedDescription)")
        }
    }
    
    /// Deletes the user's account and all associated data from Firebase.
    func deleteAccount() async -> Bool {
        guard let user = self.user else {
            self.errorMessage = "No user is currently signed in."
            return false
        }
        
        let storage = Storage.storage()
        
        do {
            try await db.collection("users").document(user.uid).delete()
            
            let storageRef = storage.reference().child("profile_images/\(user.uid).jpg")
            try? await storageRef.delete()
            
            try await user.delete()
            
            print("Account successfully deleted.")
            return true
            
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
            self.errorMessage = "Failed to delete account. Please try logging in again to complete this action."
            return false
        }
    }
    
    // MARK: - Task Functions
    
    /// Sets up a real-time listener to fetch tasks from Firestore.
    func fetchTasks(userId: String) {
        listenerRegistration?.remove()
        
        let query = db.collection("users").document(userId).collection("tasks")
        
        self.listenerRegistration = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching tasks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // MARK: - Corrected Line
            // The return type of the closure now correctly matches the 'tasks' property.
            self.tasks = documents.compactMap { document -> TaskItem? in
                try? document.data(as: TaskItem.self)
            }
        }
    }
    
    /// Adds a new task to the user's subcollection in Firestore.
    func addTask(name: String) {
        guard let userId = user?.uid else { return }
        
        let newTask = TaskItem(name: name, isCompleted: false)
        
        do {
            _ = try db.collection("users").document(userId).collection("tasks").addDocument(from: newTask)
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }
    
    /// Deletes a task from Firestore.
    func deleteTask(task: TaskItem) {
        guard let userId = user?.uid, let taskId = task.id else { return }
        
        db.collection("users").document(userId).collection("tasks").document(taskId).delete()
    }
    
    /// Toggles the completion status of a task in Firestore.
    func toggleTaskCompletion(task: TaskItem) {
        guard let userId = user?.uid, let taskId = task.id else { return }
        
        let updatedTask = TaskItem(id: taskId, name: task.name, isCompleted: !task.isCompleted)
        
        do {
            try db.collection("users").document(userId).collection("tasks").document(taskId).setData(from: updatedTask)
        } catch {
            print("Error updating task: \(error.localizedDescription)")
        }
    }
}
