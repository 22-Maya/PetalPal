import SwiftUI

struct PlantsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("PetalPal")
                        .scaledFont("Prata-Regular", size: 28)
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
                            .foregroundColor(Color(.greenShade))
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 56)
                .background(Color(.blueShade))
                .padding(.bottom, 15)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(authViewModel.plants) { plant in
                            ZStack(alignment: .topTrailing) {
                                NavigationLink(destination: MainView(plant: plant)) {
                                    PlantCardView(plant: plant)
                                }
                                
                                Button(action: { authViewModel.deletePlant(plant: plant) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.red)
                                        .font(.system(size: 24))
                                }
                                .padding(8)
                                .offset(x: -5, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.backgroundShade))
        }
    }
}

struct PlantCardView: View {
    let plant: Plant
    
    private func getPlantImage(for type: String) -> Image {
        switch type {
        case "Flower":
            return Image(.flower)
        case "Vegetable":
            return Image(.veggie)
        case "Herb":
            return Image(.herb)
        case "Fruit":
            return Image(.fruit)
        case "Other":
            return Image(.other)
        default:
            return Image(.other)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(height: 175)
                .foregroundColor(Color(.info))
            
            VStack(alignment: .leading) {
                Text(plant.name)
                    .scaledFont("Lato-Bold", size: 20)
                if !plant.plantPalName.isEmpty && plant.plantPalName != plant.name {
                    Text(plant.plantPalName)
                        .scaledFont("Lato-Regular", size: 14)
                        .foregroundColor(Color(.text).opacity(0.7))
                }
                Text(plant.type)
                    .scaledFont("Lato-Regular", size: 16)
                
                if !plant.lastReceivedData.isEmpty {
                    Text(plant.lastReceivedData)
                        .scaledFont("Lato-Regular", size: 12)
                        .foregroundColor(Color(.tealShade))
                        .padding(.top, 4)
                }
                
                Spacer()
                HStack {
                    Spacer()
                    getPlantImage(for: plant.type)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 85)
                }
            }
            .padding()
            .foregroundColor(Color(.text))
        }
    }
}

#Preview {
    PlantsView()
        .environmentObject(AuthViewModel())
        .environmentObject(TextSizeManager.shared)
}
