import SwiftUI
import FirebaseAuth
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var textSizeManager: TextSizeManager
    @Environment(\.modelContext) private var modelContext
    
    // Fetch the user's profile from SwiftData, filtered by the current user's ID.
    @Query private var userProfiles: [UserProfile]
    
    @State private var profileName: String = ""
    @State private var profileBio: String = ""
    @State private var showSuccessMessage = false
    
    // Initialize the view with existing profile data if it exists.
    init() {
        _userProfiles = Query()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            HStack {
                Text("PetalPal")
                    .scaledFont("Prata-Regular", size: 28)
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
            
            ScrollView {
                Text("Profile")
                    .scaledFont("Lato-Bold", size: 25)
                    .padding()
                
                // New UI to edit profile information.
                VStack(alignment: .leading, spacing: 20) {
                    Text("User Profile")
                        .scaledFont("Lato-Bold", size: 20)

                    TextField("Name", text: $profileName)
                        .textFieldStyle(.roundedBorder)
                        .scaledFont("Lato-Regular", size: 18)

                    
                    TextField("Bio", text: $profileBio)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(5)
                        .scaledFont("Lato-Regular", size: 18)

                }
                .padding(.horizontal)
                .onAppear {
                    // Load existing profile data when the view appears.
                    let userId = authViewModel.user?.uid ?? "guest"
                    if let existingProfile = userProfiles.first(where: { $0.userId == userId }) {
                        profileName = existingProfile.name
                        profileBio = existingProfile.bio
                    } else {
                        // Clear the fields for a new user.
                        profileName = ""
                        profileBio = ""
                    }
                    
                    // Configure TextSizeManager with current user
                    if let userId = authViewModel.user?.uid {
                        textSizeManager.configure(modelContext: modelContext, userId: userId)
                    }
                }
                
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save")
                        .scaledFont("Lato-Regular", size: 20)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.tealShade))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.top, 20)
                }
                
                if showSuccessMessage {
                    Text("Profile saved successfully!")
                        .foregroundColor(.green)
                        .padding(.top, 10)
                        .animation(.easeInOut, value: showSuccessMessage)
                        .onAppear {
                            // Hide the message after 2 seconds.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSuccessMessage = false
                            }
                        }
                }
                
                // Existing Log Out button
                Button(action: {
                    Task {
                        await authViewModel.logout()
                    }
                }) {
                    Text("Log Out")
                        .scaledFont("Lato-Regular", size: 20)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.pinkShade))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.top, 20)
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .foregroundStyle(Color(.text))
        .font(.custom("Lato-Regular", size: 20))
        .background(Color(.backgroundShade))
        }
    }
    
    // Function to save or update the user's profile.
    private func saveProfile() {
        guard let userId = authViewModel.user?.uid else { return }
        
        if let existingProfile = userProfiles.first(where: { $0.userId == userId }) {
            // Update existing profile.
            existingProfile.name = profileName
            existingProfile.bio = profileBio
            existingProfile.textSizeMultiplier = textSizeManager.textSizeMultiplier
        } else {
            // Create a new profile.
            let newProfile = UserProfile(name: profileName, bio: profileBio, userId: userId)
            newProfile.textSizeMultiplier = textSizeManager.textSizeMultiplier
            modelContext.insert(newProfile)
        }
        
        do {
            try modelContext.save()
            showSuccessMessage = true
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}
