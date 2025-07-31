//
//  MainView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var plantDatabase: [PlantInfo]
    
    let plant: Plant
    
    // finds the plant info from PlantModel
    private var plantInfo: PlantInfo? {
        plantDatabase.first { $0.name.lowercased() == plant.name.lowercased() }
    }
    
    // gets plant image based on type
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
        default:
            return Image(.flower)
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 249/255, green: 248/255, blue: 241/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // navbar
                HStack {
                    Text("PetalPal")
                        .font(.custom("Prata-Regular", size: 28))
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
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
                .frame(width: UIScreen.main.bounds.width, height: 56)
                .background(Color(red: 174/255, green: 213/255, blue: 214/255))
                
                // back button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                        .font(.custom("Lato-Regular", size: 18))
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                .padding(.vertical, 10)
                
                ScrollView {
                    // Plant Display
                    VStack(spacing: 10) {
                        getPlantImage(for: plant.type)
                            .resizable()
                            .frame(width: 250, height: 350)
                        
                        Text(plant.name)
                            .font(.custom("Lato-Bold", size: 50))
                            .foregroundColor(.black)
                        
                        Text(plant.type)
                            .font(.system(size: 25))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.vertical, 30)
                    
                    // user's plant info
                    VStack(alignment: .leading, spacing: 20) {
                        Text("My Plant")
                            .font(.custom("Lato-Bold", size: 24))
                            .padding(.bottom, 5)
                        
                        if !plant.wateringFrequency.isEmpty {
                            DetailSection(title: "Watering Frequency", content: plant.wateringFrequency)
                        }
                        if !plant.wateringAmount.isEmpty {
                            DetailSection(title: "Watering Amount", content: plant.wateringAmount)
                        }
                        if !plant.sunlightNeeds.isEmpty {
                            DetailSection(title: "Sunlight Needs", content: plant.sunlightNeeds)
                        }
                        if !plant.careInstructions.isEmpty {
                            DetailSection(title: "Care Instructions", content: plant.careInstructions)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(red: 216/255, green: 232/255, blue: 202/255))
                    )
                    .padding()
                    
                    // plant care details
                    if let info = plantInfo {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Plant Care Guide")
                                .font(.custom("Lato-Bold", size: 24))
                                .padding(.bottom, 5)
                            
                            DetailSection(title: "Watering", content: info.wateringDetails)
                            DetailSection(title: "Sunlight", content: info.sunlight)
                            DetailSection(title: "Soil", content: info.soil)
                            if let notes = info.notes {
                                DetailSection(title: "Additional Care Tips", content: notes)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(red: 173/255, green: 194/255, blue: 153/255))
                        )
                        .padding()
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .font(.custom("Lato-Regular", size: 20))
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        .onAppear {
            if plantDatabase.isEmpty {
                PlantInfo.populateDatabase(modelContext: modelContext)
            }
        }
    }
}

// consistent detail sections
struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Lato-Bold", size: 22))
            Text(content)
                .font(.custom("Lato-Regular", size: 18))
        }
    }
}

#Preview {
    NavigationStack {
        MainView(plant: Plant(name: "Basil", type: .herb))
    }
    .modelContainer(for: [Plant.self, PlantInfo.self], inMemory: true)
}