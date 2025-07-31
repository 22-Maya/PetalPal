//
//  PlantsView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import SwiftData

struct PlantsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    
    func deletePlant(_ plant: Plant) {
        modelContext.delete(plant)
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
                                        .foregroundColor(Color(.pink))
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
        .modelContainer(for: Plant.self, inMemory: true)
}