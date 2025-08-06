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
                Text("FAQ & AI Helpbot View")
                    .scaledFont("Lato-Bold", size: 25)
                    .padding()
            }

        }
        .navigationBarBackButtonHidden(true)
        .foregroundStyle(Color(.text))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(.backgroundShade))
    }
}

#Preview {
    HelpbotView()
}
