//
//  JournalView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI

struct JournalView: View {
    var body: some View {
        NavigationStack{
            //            navbar
            HStack {
                Text("Petal Pal")
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
            .frame(height: 56)
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            .padding(.bottom, 15)
            
            ScrollView {
                Text("Journal-work in progress")
            }
            
            //        bottom navbar
            Spacer()
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
                        .foregroundColor(.white)
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
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
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
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .font(.custom("Lato-Regular", size: 20))
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
    }
}

#Preview {
    JournalView()
}
