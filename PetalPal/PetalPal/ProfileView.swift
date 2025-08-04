import SwiftUI
import Charts
import SwiftData
import FirebaseCore
import FirebaseAppCheck
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    
    // Fetch the user's profile from SwiftData, filtered by the current user's ID.
    @Query private var userProfiles: [UserProfile]
    
    @State private var profileName: String = ""
    @State private var profileBio: String = ""
    @State private var showSuccessMessage = false
    
    // Initialize the view with existing profile data if it exists.
    init(authViewModel: AuthViewModel) {
        let userId = authViewModel.user?.uid ?? "guest"
        _userProfiles = Query(filter: #Predicate<UserProfile> {
            $0.userId == userId
        })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("PetalPal")
                    .font(.custom("Prata-Regular", size: 28))
                    .foregroundColor(Color(.tealShade))
                    .padding(.leading, 20)
                Spacer()
                NavigationLink {
                    HelpbotView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(.backgroundShade))
                        .padding(.trailing, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.blueShade))
            .padding(.bottom, 15)
            
            ScrollView {
                Text("Profile - Work in Progress")
                    .font(.custom("Lato-Bold", size: 25))
                    .padding()
                
                // New UI to edit profile information.
                VStack(alignment: .leading, spacing: 20) {
                    Text("User Profile")
                        .font(.custom("Lato-Bold", size: 20))
                    
                    TextField("Name", text: $profileName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Bio", text: $profileBio)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(5)
                }
                .padding(.horizontal)
                .onAppear {
                    // Load existing profile data when the view appears.
                    if let existingProfile = userProfiles.first {
                        profileName = existingProfile.name
                        profileBio = existingProfile.bio
                    } else {
                        // Clear the fields for a new user.
                        profileName = ""
                        profileBio = ""
                    }
                }
                
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save")
                        .font(.custom("Lato-Bold", size: 20))
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
                        .font(.custom("Lato-Bold", size: 20))
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
    
    // Function to save or update the user's profile.
    private func saveProfile() {
        guard let userId = authViewModel.user?.uid else { return }
        
        if let existingProfile = userProfiles.first {
            // Update existing profile.
            existingProfile.name = profileName
            existingProfile.bio = profileBio
        } else {
            // Create a new profile.
            let newProfile = UserProfile(name: profileName, bio: bio, userId: userId)
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

#Preview {
    ProfileView()
}
