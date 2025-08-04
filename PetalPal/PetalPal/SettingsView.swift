import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var textSizeManager: TextSizeManager
    
    var body: some View {
        NavigationStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                        .padding(.leading, 20)
                }

                Text("PetalPal")
                    .scaledFont("Prata-Regular", size: 28)
                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                    .padding(.leading, 5)
                
                Spacer()
            }
            .frame(height: 56)
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            .padding(.bottom, 15)

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    //manual vs automatic mode section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Manual / Automatic")
                            .scaledFont("Lato-Bold", size: 28)
                            .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                        
                    }
                    
                    // Accessibility Settings Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Accessibility")
                            .scaledFont("Lato-Bold", size: 28)
                            .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Text Size")
                                .scaledFont("Lato-Bold", size: 20)
                                .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                            
                            HStack {
                                Text("Small")
                                    .scaledFont("Lato-Regular", size: 16)
                                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                                
                                Slider(value: $textSizeManager.textSizeMultiplier, in: 0.7...1.5, step: 0.1)
                                    .accentColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                                
                                Text("Large")
                                    .scaledFont("Lato-Regular", size: 16)
                                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                            }
                            
                            // Preview text
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Preview:")
                                    .scaledFont("Lato-Bold", size: 16)
                                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                                
                                Text("This is how your text will appear throughout the app.")
                                    .font(textSizeManager.getScaledCustomFont("Lato-Regular", baseSize: 18))
                                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
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
                                    .foregroundColor(.white)
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
                                .fill(Color(red: 216/255, green: 232/255, blue: 202/255))
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
    }
}

#Preview {
    SettingsView()
        .environmentObject(TextSizeManager.shared)
}
