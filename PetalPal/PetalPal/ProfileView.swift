import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // State for managing UI and profile data
    @State private var isEditing = false
    @State private var profileName: String = ""
    @State private var username: String = ""
    @State private var joinedDate: Date?
    @State private var profileBio: String = ""
    
    // State for the PhotosPicker
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Text("PetalPal")
                        .font(.custom("Prata-Regular", size: 28))
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                        .padding(.leading, 20)
                    Spacer()
                    NavigationLink {
                        SettingsView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 56)
                .background(Color(red: 174/255, green: 213/255, blue: 214/255))
                .padding(.bottom, 15)
                
                // MARK: - Main Content Guard
                if authViewModel.user != nil {
                    ScrollView {
                        VStack {
                            // MARK: - Name Display
                            // The user's name is now displayed above the profile image.
                            if !isEditing {
                                Text("Hello, \(profileName)")
                                    .font(.custom("Lato-Bold", size: 24))
                                    .padding(.bottom, 5)
                            }
                            
                            // MARK: - Profile Image
                            ProfileImageView(profileImageData: profileImageData, photoURL: authViewModel.user?.photoURL)
                            
                            // Show PhotosPicker only when editing
                            if isEditing {
                                PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                                    Text("Change Photo")
                                        .font(.custom("Lato-Regular", size: 16))
                                        .foregroundColor(Color(.tealShade))
                                }
                                .padding(.top, 10)
                                .padding(.bottom)
                            }
                            
                            // MARK: - Display or Edit UI
                            if isEditing {
                                editProfileView
                            } else {
                                displayProfileView
                            }
                            
                            // MARK: - Log Out Button
                            Button(action: {
                                Task {
                                    await authViewModel.logout()
                                }
                            }) {
                                Text("Log Out")
                                    .font(.custom("Lato-Regular", size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.pinkShade))
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                            }
                        }
                    }
                } else {
                    // Show a loading indicator while waiting for authentication to complete.
                    ProgressView()
                    Spacer()
                }
            }
            .background(Color(.backgroundShade))
            .navigationBarHidden(true)
            .onAppear(perform: loadUserProfile)
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                        self.profileImageData = data
                    }
                }
            }
        }
    }
    
    // MARK: - Display View
    private var displayProfileView: some View {
        VStack(spacing: 15) {
            // MARK: - Display Username and Joined Date
            HStack(spacing: 5) {
                if !username.isEmpty {
                    Text("@\(username)")
                        .font(.custom("Lato-Regular", size: 16))
                        .foregroundColor(.gray)
                }
                
                if let joinedDate = joinedDate {
                    Text("· Joined \(joinedDate, formatter: itemFormatter)")
                        .font(.custom("Lato-Regular", size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 10)
            
            Text(profileBio)
                .font(.custom("Lato-Regular", size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 5)
            
            Button("Edit Profile") {
                isEditing = true
            }
            .font(.custom("Lato-Regular", size: 20))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.tealShade))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Edit View
    private var editProfileView: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $profileName)
                .textFieldStyle(.roundedBorder)
                .font(.custom("Lato-Regular", size: 18))
            
            // MARK: - Username TextField
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .font(.custom("Lato-Regular", size: 18))
                .autocapitalization(.none)
            
            TextField("Bio", text: $profileBio, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5)
                .font(.custom("Lato-Regular", size: 18))
            
            Button("Save") {
                Task {
                    await saveProfile()
                }
            }
            .font(.custom("Lato-Regular", size: 20))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.tealShade))
            .cornerRadius(15)
            
            Button("Cancel") {
                isEditing = false
                // Reset fields to original values
                loadUserProfile()
            }
            .foregroundColor(.red)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Firebase Functions
    
    /// Loads the user's profile data from Firebase Auth and Firestore.
    private func loadUserProfile() {
        guard let user = authViewModel.user else { return }
        self.profileName = user.displayName ?? "No Name"
        
        // Fetch bio, username, and creation date from Firestore
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                self.username = data["username"] as? String ?? ""
                self.profileBio = data["bio"] as? String ?? "No bio yet."
                // Convert Firestore Timestamp to Date
                if let timestamp = data["creationDate"] as? Timestamp {
                    self.joinedDate = timestamp.dateValue()
                }
            } else {
                self.profileBio = "No bio yet."
            }
        }
    }
    
    /// Saves the updated profile data to Firebase.
    private func saveProfile() async {
        guard let user = authViewModel.user else { return }
        
        var photoURL: URL?
        
        // 1. Upload new image to Firebase Storage if one was selected
        if let imageData = profileImageData {
            let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
            do {
                _ = try await storageRef.putDataAsync(imageData, metadata: nil)
                photoURL = try await storageRef.downloadURL()
            } catch {
                print("Failed to upload image: \(error)")
                return
            }
        }
        
        // 2. Update Firebase Auth profile
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = profileName
        if let photoURL = photoURL {
            changeRequest.photoURL = photoURL
        }
        
        do {
            try await changeRequest.commitChanges()
        } catch {
            print("Failed to update Auth profile: \(error)")
            return
        }
        
        // 3. Update Firestore document
        let db = Firestore.firestore()
        var userData: [String: Any] = [
            "username": username,
            "bio": profileBio,
        ]
        if let photoURL = photoURL {
            userData["photoURL"] = photoURL.absoluteString
        }
        
        do {
            try await db.collection("users").document(user.uid).setData(userData, merge: true)
            print("Profile successfully updated.")
            isEditing = false
            
            // MARK: - Refresh User Data
            // Call the function on the view model to handle the refresh safely.
            await authViewModel.refreshUserData()
            
        } catch {
            print("Failed to save or refresh profile: \(error)")
        }
    }
}

// MARK: - Date Formatter
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()


// MARK: - Helper View for Profile Image
struct ProfileImageView: View {
    let profileImageData: Data?
    let photoURL: URL?
    
    var body: some View {
        Group {
            if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                AsyncImage(url: photoURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color(.tealShade), lineWidth: 4))
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
