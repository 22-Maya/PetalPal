import SwiftUI

// define plant types
enum PlantType: String, Codable, Identifiable {
    case fruit = "Fruit"
    case vegetable = "Vegetable"
    case herb = "Herb"
    case flower = "Flower"

    var id: String { self.rawValue }

    var plantImage: Image {
        switch self {
        case .fruit:
            return Image(.fruit)
        case .vegetable:
            return Image(.veggie)
        case .herb:
            return Image(.herb)
        case .flower:
            return Image(.flower)
        }
    }
}

// Plant Model
struct Plant: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: PlantType
    var wateringFrequency: String = ""
    var wateringAmount: String = ""
    var sunlightNeeds: String = ""
    var careInstructions: String = ""
}

// Sample Plant Data
class PlantData {
    static var samplePlants: [Plant] = [
        Plant(
            name: "Hibiscus",
            type: .flower
        ),
        Plant(
            name: "Basil",
            type: .herb
        )
    ]
}

struct PlantsView: View {
    @State private var plants: [Plant] = PlantData.samplePlants

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // navbar
                HStack {
                    Text("Petal Pal")
                        .font(.custom("Prata-Regular", size: 28))
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                        .padding(.leading, 20)
                    Spacer()
                    NavigationLink {
                        HelpbotView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 56)
                .background(Color(red: 174/255, green: 213/255, blue: 214/255))
                .padding(.bottom, 15)

                // Plants List
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(plants) { plant in
                            NavigationLink {
                                MainView(plant: plant)
                            } label: {
                                PlantCardView(plant: plant)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                // bottom navbar
                HStack {
                    NavigationLink{
                        ContentView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    NavigationLink{
                        PlantsView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                            .frame(maxWidth: .infinity)
                    }
                    NavigationLink{
                        WifiView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "plus.app.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    NavigationLink{
                        JournalView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "book.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    NavigationLink{
                        SettingsView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 56)
                .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            }
            .navigationBarHidden(true)
            .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        }
    }
}

#Preview {
    PlantsView()
}
