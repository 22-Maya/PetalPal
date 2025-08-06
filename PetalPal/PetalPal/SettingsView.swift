import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var textSizeManager: TextSizeManager
    @StateObject private var wifiManager = WifiManager.shared
    @State private var isAutomaticMode = false
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingDeleteAlert = false
    @State private var deletionError: String?
    @State private var isShowingDeletionError = false
    
    private func getConnectionStatusColor() -> Color {
        if wifiManager.isSendingCommand {
            return Color.red
        } else if wifiManager.connectionStatus.contains("Connected") || wifiManager.connectionStatus.contains("Sent:") {
            return Color.green
        } else {
            return Color.red
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing:0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(.tealShade))
                            .padding(.leading, 20)
                    }
                    
                    Text("PetalPal")
                        .scaledFont("Prata-Regular", size: 28)
                        .foregroundColor(Color(.tealShade))
                        .padding(.leading, 5)
                    
                    Spacer()
                }
                .frame(height: 56)
                .background(Color(.blueShade))
                .padding(.bottom, 15)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Manual vs automatic mode section
                        VStack(alignment: .leading, spacing: 20) {
                                 Text("Manual / Automatic")
                                     .scaledFont("Lato-Bold", size: 28)
                                     .foregroundColor(Color(.text))
                                 
                                 VStack(alignment: .leading, spacing: 15) {
                                                                           Toggle(isOn: $isAutomaticMode) {
                                          Text("Automatic Mode")
                                              .scaledFont("Lato-Regular", size: 16)
                                      }
                                         .toggleStyle(SwitchToggleStyle(tint: Color(red: 0/255, green: 122/255, blue: 69/255)))
                                         .onChange(of: isAutomaticMode) { newValue in
                                             wifiManager.sendModeCommand(isAutomatic: newValue, fromSettings: true)
                                         }
                                     
                                     // Connection status indicator
                                     HStack {
                                         Circle()
                                             .fill(getConnectionStatusColor())
                                             .frame(width: 8, height: 8)
                                         Text(wifiManager.connectionStatus)
                                             .scaledFont("Lato-Regular", size: 14)
                                             .foregroundColor(.gray)
                                     }
                                     
                                     if let errorMessage = wifiManager.errorMessage {
                                         Text(errorMessage)
                                             .scaledFont("Lato-Regular", size: 14)
                                             .foregroundColor(.red)
                                     }
                                 }
                                 .padding()
                                 .background(
                                     RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(.info))
                                         .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                                 )
                             }
                             .padding()
                            
                            // Accessibility Settings Section
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Accessibility")
                                    .scaledFont("Lato-Bold", size: 28)
                                    .foregroundColor(Color(.text))
                                
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Text Size")
                                        .scaledFont("Lato-Bold", size: 20)
                                        .foregroundColor(Color(.text))
                                    
                                    HStack {
                                        Text("Small")
                                            .scaledFont("Lato-Regular", size: 16)
                                            .foregroundColor(Color(.text))
                                        
                                        Slider(value: $textSizeManager.textSizeMultiplier, in: 0.7...1.5, step: 0.1)
                                            .accentColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                                        
                                        Text("Large")
                                            .scaledFont("Lato-Regular", size: 16)
                                            .foregroundColor(Color(.text))
                                    }
                                    
                                    // Preview text
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Preview:")
                                            .scaledFont("Lato-Bold", size: 16)
                                            .foregroundColor(Color(.text))
                                        
                                        Text("Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem.")
                                            .font(textSizeManager.getScaledCustomFont("Lato-Regular", baseSize: 18))
                                            .foregroundColor(Color(.text))
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color(red: 249/255, green: 248/255, blue: 241/255))
                                            )
                                    }
                                    
                                    // Reset button
                                    Button(action: {
                                        textSizeManager.textSizeMultiplier = 1.0
                                    }) {
                                        Text("Reset to Default")
                                            .scaledFont("Lato-Regular", size: 16)
                                            .foregroundColor(Color(.backgroundShade))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color(red: 0/255, green: 122/255, blue: 69/255))
                                            )
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(.info))
                                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            VStack {
                                Button(role: .destructive) {
                                    isShowingDeleteAlert = true
                                } label: {
                                    Text("Delete Account")
                                        .scaledFont("Lato-Bold", size: 18)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            
                        }
                        .padding(.top, 20)
                    }
                }
                .background(Color(red: 249/255, green: 248/255, blue: 241/255))
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .alert("Are you sure you want to delete your account?", isPresented: $isShowingDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        Task {
                            let success = await authViewModel.deleteAccount()
                            if !success {
                                deletionError = authViewModel.errorMessage
                                isShowingDeletionError = true
                            }
                        }
                    }
                } message: {
                    Text("This action is permanent and cannot be undone. All of your data will be deleted.")
                }
                .alert("Error", isPresented: $isShowingDeletionError, presenting: deletionError) { _ in
                    Button("OK") { }
                } message: { error in
                    Text(error)
                }
        }
        .foregroundStyle(Color(.text))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(.backgroundShade))
    }
}


#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(TextSizeManager.shared)
}
