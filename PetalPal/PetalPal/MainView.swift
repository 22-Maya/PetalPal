//
//  MainView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.

import SwiftUI

struct MainView: View {
<<<<<<< Updated upstream
    let plant: Plant
    
=======
>>>>>>> Stashed changes
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Navbar
                HStack {
                    Text("Petal Pal")
                        .font(.custom("MadimiOne-Regular", size: 28))
<<<<<<< Updated upstream
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
=======
                        .foregroundColor(.black)
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                .background(Color(red: 174/255, green: 213/255, blue: 214/255))
                .padding(.bottom, 15)
                
                // Plant Display
                VStack(spacing: 10) {
                    switch plant.type {
                    case .flower:
                        Image(.flower)
                            .resizable()
                            .frame(width: 250, height: 350)
                    case .vegetable:
                        Image(.veggie)
                            .resizable()
                            .frame(width: 250, height: 350)
                    case .herb:
                        Image(.herb)
                            .resizable()
                            .frame(width: 250, height: 350)
                    case .fruit:
                        Image(.fruit)
                            .resizable()
                            .frame(width: 250, height: 350)
                    }
                    
                    Text(plant.name)
                        .font(.custom("MadimiOne-Regular", size: 50))
                        .foregroundColor(.black)
                    
                    Text(plant.type.rawValue)
                        .font(.system(size: 25))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.vertical, 30)
                
                Text("Water Plant in 2 days")
                    .padding(20)
                    .background(Color(red: 67/255, green: 137/255, blue: 124/255))
                    .font(.custom("MadimiOne-Regular",size: 25))
                    .foregroundColor(.white)
                
                Spacer()
            }
=======
                .background(Color(red: 195/255, green: 225/255, blue: 243/255))
                .padding(.bottom, 15)
                
                // Plant Display
                
                VStack(spacing: 10) {
                    Image(.herb)
                        .resizable()
                        .frame(width: 250, height: 350)
                        
                    Text("Basil")
                        .font(.custom("MadimiOne-Regular", size: 50))
                        .foregroundColor(.black)
                        
                    Text("Herb")
                        .font(.system(size: 25))
                        .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.vertical, 30)
                
                Text("Water Plant in"+" 2 days")
                    .padding(20)
                    .background(Color(red: 67/255, green: 137/255, blue: 124/255))
                    .font(.custom("MadimiOne-Regular",size: 25))
                
                Spacer()
                }
            
            
>>>>>>> Stashed changes
        }
    }
}

#Preview {
<<<<<<< Updated upstream
    MainView(plant: Plant(name: "Basil", type: .herb))
=======
    MainView()
>>>>>>> Stashed changes
}
