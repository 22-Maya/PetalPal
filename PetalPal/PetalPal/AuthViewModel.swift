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
    @Published var tasks: [TaskItem] = []
    @Published var journalEntries: [JournalEntry] = []
    
    // MARK: - Published Plants
    @Published var plants: [Plant] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var journalListenerRegistration: ListenerRegistration?
    private var plantsListenerRegistration: ListenerRegistration?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for changes in the authentication state.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.user = user
            self.isAuthenticated = user != nil
            
            if let user = user {
                // If a user is logged in, start listening for data updates.
                self.fetchTasks(userId: user.uid)
                self.fetchJournalEntries(userId: user.uid)
                self.fetchPlants(userId: user.uid)
            } else {
                // If the user logs out, stop listening and clear data.
                self.listenerRegistration?.remove()
                self.journalListenerRegistration?.remove()
                self.plantsListenerRegistration?.remove()
                self.tasks = []
                self.journalEntries = []
                self.plants = []
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        listenerRegistration?.remove()
        journalListenerRegistration?.remove()
        plantsListenerRegistration?.remove()
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
    
    // MARK: - Journal Functions
    
    /// Sets up a real-time listener to fetch journal entries from Firestore.
    func fetchJournalEntries(userId: String) {
        journalListenerRegistration?.remove()
        
        let query = db.collection("users").document(userId).collection("journalEntries").order(by: "date", descending: true)
        
        self.journalListenerRegistration = query.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching journal entries: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No journal entry documents found.")
                return
            }
            
            self.journalEntries = documents.compactMap { document -> JournalEntry? in
                try? document.data(as: JournalEntry.self)
            }
        }
    }
    
    /// Adds a new journal entry to the user's subcollection in Firestore.
    func addJournalEntry(content: String, plantName: String?) {
        guard let userId = user?.uid else { return }
        
        let newEntry = JournalEntry(content: content, date: Timestamp(date: Date()), plantName: plantName)
        
        do {
            _ = try db.collection("users").document(userId).collection("journalEntries").addDocument(from: newEntry)
        } catch {
            print("Error adding journal entry: \(error.localizedDescription)")
        }
    }
    
    /// Deletes a journal entry from Firestore.
    func deleteJournalEntry(entry: JournalEntry) {
        guard let userId = user?.uid, let entryId = entry.id else { return }
        
        db.collection("users").document(userId).collection("journalEntries").document(entryId).delete { error in
            if let error = error {
                print("Error deleting journal entry: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Task Functions
    
    /// Sets up a real-time listener to fetch tasks from Firestore.
    func fetchTasks(userId: String) {
        listenerRegistration?.remove()
        
        let query = db.collection("users").document(userId).collection("tasks")
        
        self.listenerRegistration = query.addSnapshotListener { querySnapshot, error in
            // UPDATED: More specific error handling.
            if let error = error {
                print("Error fetching tasks: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No task documents found.")
                return
            }
            
            self.tasks = documents.compactMap { document -> TaskItem? in
                // This line requires your `TaskItem` struct to conform to the `Codable` protocol.
                // It also requires a property like `@DocumentID var id: String?` in your model
                // to automatically decode the document ID.
                try? document.data(as: TaskItem.self)
            }
        }
    }
    
    /// Adds a new task to the user's subcollection in Firestore.
    func addTask(name: String) {
        guard let userId = user?.uid else {
            print("Error: User not logged in.")
            return
        }
        
        let newTask = TaskItem(name: name, isCompleted: false)
        
        do {
            _ = try db.collection("users").document(userId).collection("tasks").addDocument(from: newTask)
        } catch {
            // UPDATED: More specific error handling.
            print("Error adding task to Firestore: \(error.localizedDescription)")
        }
    }
    
    /// Deletes a task from Firestore.
    func deleteTask(task: TaskItem) {
        guard let userId = user?.uid, let taskId = task.id else {
            print("Error: Could not delete task. User ID or Task ID is missing.")
            return
        }
        
        db.collection("users").document(userId).collection("tasks").document(taskId).delete { error in
            // UPDATED: More specific error handling.
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
    }
    
    /// Toggles the completion status of a task in Firestore.
    func toggleTaskCompletion(task: TaskItem) {
        guard let userId = user?.uid, let taskId = task.id else {
            print("Error: Could not update task. User ID or Task ID is missing.")
            return
        }
        
        // It's safer to update a single field than to overwrite the whole document.
        db.collection("users").document(userId).collection("tasks").document(taskId).updateData([
            "isCompleted": !task.isCompleted
        ]) { error in
            // UPDATED: More specific error handling.
            if let error = error {
                print("Error updating task completion status: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Plant Functions
    
    /// Sets up a real-time listener to fetch plants from Firestore.
    func fetchPlants(userId: String) {
        plantsListenerRegistration?.remove()
        
        let query = db.collection("users").document(userId).collection("plants")
        
        self.plantsListenerRegistration = query.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching plants: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No plant documents found.")
                return
            }
            
            self.plants = documents.compactMap { document -> Plant? in
                try? document.data(as: Plant.self)
            }
        }
    }
    
    /// Adds a new plant to the user's subcollection in Firestore.
    func addPlant(name: String, plantPalName: String, type: PlantType, wateringFrequency: String, wateringAmount: String, sunlightNeeds: String, careInstructions: String) {
        guard let userId = user?.uid else { return }
        
        let newPlant = Plant(name: name, plantPalName: plantPalName, type: type.rawValue, wateringFrequency: wateringFrequency, wateringAmount: wateringAmount, sunlightNeeds: sunlightNeeds, careInstructions: careInstructions)
        
        do {
            _ = try db.collection("users").document(userId).collection("plants").addDocument(from: newPlant)
        } catch {
            print("Error adding plant: \(error.localizedDescription)")
        }
    }
    
    /// Updates an existing plant in Firestore.
    func updatePlant(plant: Plant) {
        guard let userId = user?.uid, let plantId = plant.id else { return }
        
        do {
            try db.collection("users").document(userId).collection("plants").document(plantId).setData(from: plant)
        } catch {
            print("Error updating plant: \(error.localizedDescription)")
        }
    }
    
    /// Deletes a plant from Firestore.
    func deletePlant(plant: Plant) {
        guard let userId = user?.uid, let plantId = plant.id else { return }
        
        db.collection("users").document(userId).collection("plants").document(plantId).delete { error in
            if let error = error {
                print("Error deleting plant: \(error.localizedDescription)")
            }
        }
    }
}
