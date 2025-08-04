//
//  PlantCardView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import SwiftData

struct PlantCardView: View {
    let plant: Plant
    
    // get plant image based on type
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
            RoundedRectangle(cornerRadius: 25)
                .frame(height: 175)
                .foregroundColor(Color(red: 173/255, green: 194/255, blue: 153/255))
            
            VStack(alignment: .leading) {
                Text(plant.name)
                    .scaledFont("Lato-Bold", size: 20)
                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                
                Text(plant.type)
                    .scaledFont("Lato-Regular", size: 16)
                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                
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
        }
    }
}

#Preview {
    PlantCardView(plant: Plant(name: "Basil", type: .herb))
        .modelContainer(for: Plant.self, inMemory: true)
}