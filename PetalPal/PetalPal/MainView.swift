//
//  MainView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.

import SwiftUI

struct MainView: View {
    @Environment(\.dismiss) private var dismiss
    let plant: Plant
    
    var body: some View {
        ZStack {
            Color(red: 249/255, green: 248/255, blue: 241/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // navbar
                HStack {
                    Text("Petal Pal")
                        .font(.custom("KaushanScript-Regular", size: 28))
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
                
                // Custom back button
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
                        .font(.custom("Lato-Bold", size: 50))
                        .foregroundColor(.black)
                    
                    Text(plant.type.rawValue)
                        .font(.system(size: 25))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.vertical, 30)
                
                Text("Water Plant in 2 days")
                    .padding(20)
                    .background(Color(red: 67/255, green: 137/255, blue: 124/255))
                    .font(.custom("Lato-Regular",size: 25))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .font(.custom("Lato-Regular", size: 20))
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        
    }
}

#Preview {
    NavigationStack {
        MainView(plant: Plant(name: "Basil", type: .herb))
    }
}
