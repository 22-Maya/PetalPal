import SwiftUI

// define plant types
enum PlantType: String, Codable, Identifiable, CaseIterable {
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
    private static let plantsKey = "savedPlants"

    static var samplePlants: [Plant] {
        get {
            if let data = UserDefaults.standard.data(forKey: plantsKey),
               let plants = try? JSONDecoder().decode([Plant].self, from: data) {
                return plants
            }
            
            return [
                Plant(name: "Hibiscus", type: .flower),
                Plant(name: "Basil", type: .herb)
            ]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: plantsKey)
            }
        }
    }
}

struct PlantsView: View {
    @State private var plants: [Plant] = PlantData.samplePlants

    func deletePlant(_ plant: Plant) {
        DispatchQueue.main.async {
            if let index = plants.firstIndex(where: { $0.id == plant.id }) {
                plants.remove(at: index)
                PlantData.samplePlants = plants
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("PetalPal")
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
                            .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 56)
                .background(Color(red: 174/255, green: 213/255, blue: 214/255))
                .padding(.bottom, 15)

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(plants) { plant in
                            ZStack(alignment: .topTrailing) {
                                NavigationLink {
                                    MainView(plant: plant)
                                } label: {
                                    PlantCardView(plant: plant)
                                }

                                Button {
                                    deletePlant(plant)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color(.pink)) // Assuming .pink is a custom color or system pink
                                        .font(.system(size: 24))
                                }
                                .padding(8)
                                .offset(x: -5, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
            .font(.custom("Lato-Regular", size: 20))
            .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        }
    }
}

#Preview {
    PlantsView()
}
