import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
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
                        .foregroundColor(Color(.tealShade))
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 56)
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            .padding(.bottom, 15)

            ScrollView {
                VStack {
                    Text("Profile - Work in Progress")
                        .scaledFont("Lato-Bold", size: 25)
                        .padding()
                    Circle()
                        .fill(Color(.tealShade))
                        .frame(width: 250, height: 250)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
    }
}

#Preview {
    ProfileView()
}
