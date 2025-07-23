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
}

// Sample Plant Data
class PlantData {
    static let samplePlants: [Plant] = [
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
        VStack(spacing: 0) {
            //    navbar
            HStack {
                Text("Petal Pal")
                    .font(.custom("MadimiOne-Regular", size: 28))
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                Spacer()
                NavigationLink{
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
            .background(Color(red: 195/255, green: 225/255, blue: 243/255))
            .padding(.bottom, 15)
            
            // Plants List
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(plants) { plant in
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(height: 175)
                                .foregroundColor(Color(red: 173/255, green: 194/255, blue: 153/255))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(plant.name)
                                    .font(.custom("MadimiOne-Regular", size: 20))
                                    .foregroundColor(.black)
                                Text(plant.type.rawValue)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black.opacity(0.7))
                                    .padding(.bottom, 0)
//                                shows images based on plant type
                                HStack {
                                    Spacer()
                                    switch plant.type {
                                    case .flower:
                                        Image(.flower)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .padding(.top, 0)
                                    case .vegetable:
                                        Image(.veggie)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .padding(.top, 0)
                                    case .herb:
                                        Image(.herb)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .padding(.top, 0)
                                    case .fruit:
                                        Image(.fruit)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .padding(.top, 0)
                                    }
                                }
                            }
                            .padding(15)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            //        bottom navbar
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
                    BluetoothView()
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
