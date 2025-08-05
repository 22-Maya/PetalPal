import SwiftUI
import Charts
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck

struct HelpbotView: View {
    
    @Environment(\.dismiss) var dismiss
    
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
                Text("FAQ & AI Helpbot View")
                    .scaledFont("Lato-Bold", size: 25)
                    .padding()
            }

        }
        .navigationBarBackButtonHidden(true)
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
    }
}

#Preview {
    HelpbotView()
}
