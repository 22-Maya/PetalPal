//
//  MainView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI

struct MainView: View {
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
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            .padding(.bottom, 15)
            
            
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
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationView {
        MainView()
    }
}
