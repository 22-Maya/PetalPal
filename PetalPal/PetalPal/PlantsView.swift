//
//  PlantsView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI

// define plant types
enum PlantType: String, Codable, Identifiable {
    case fruit = "Fruit"
    case vegetable = "Vegetable"
    case herb = "Herb"
    case flower = "Flower"
    
    var id: String { self.rawValue }
}

// Plant Model
struct Plant: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: PlantType
    var wateringFrequency: Int // days between watering
    var lastWatered: Date
    var notes: String?
}

// Sample Plant Data
class PlantData {
    static let samplePlants: [Plant] = [
        Plant(
            name: "Hibiscus",
            type: .flower,
            wateringFrequency: 2,
            lastWatered: Date(),
            notes: "Cherry tomato variety"
        ),
        Plant(
            name: "Basil",
            type: .herb,
            wateringFrequency: 1,
            lastWatered: Date(),
            notes: "Sweet basil"
        )
    ]
}

struct PlantsView: View {
    @State private var plants: [Plant] = PlantData.samplePlants
    
    var body: some View {
        VStack(spacing: 0) {
            //            navbar
            HStack {
                Text("Petal Pal")
                    .font(.custom("MadimiOne-Regular", size: 28))
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                Spacer()
                NavigationLink{
                    HelpbotView()
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 56)
            .background(Color(red: 195/255, green: 225/255, blue: 243/255))
            .padding(.bottom, 15)
            
            // Plants List
            List(plants) { plant in
                VStack(alignment: .leading) {
                    Text(plant.name)
                        .font(.headline)
                    Text(plant.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if let notes = plant.notes {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Text("Water every \(plant.wateringFrequency) days")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
            
            //        bottom navbar
            HStack {
                NavigationLink{
                    JournalView()
                } label: {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    PlantsView()
                } label: {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    BluetoothView()
                } label: {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    JournalView()
                } label: {
                    Image(systemName: "book.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 56)
            .background(Color(red: 195/255, green: 225/255, blue: 243/255))
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationView {
        PlantsView()
    }
}
