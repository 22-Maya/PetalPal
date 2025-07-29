//
//  ContentView.swift
//  Petal Pal
//
//  Created by Adishree Das on 7/21/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            // navbar
            HStack {
                Text("Petal Pal")
                    .font(.custom("Prata-Regular", size: 28))
                    .foregroundColor(Color(.tealShade))
                    .padding(.leading, 20)
                Spacer()
                NavigationLink{
                    HelpbotView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(.backgroundShade))
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 56)
            .background(Color(.blueShade))
            .padding(.bottom, 15)

            ScrollView {
                VStack(spacing: 30) {
                    // today's tasks section
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width:325, height:150)
                            .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255))
                        VStack(alignment: .leading) {
                            Text("Today's Tasks")
                                .font(.custom("Lato-Bold", size:25))
                                .padding(.top, 16)
                                .padding(.leading, 20)
                        }
                    }

                    // last watered
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width:325, height:150)
                            .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255))
                        VStack(alignment: .leading) {
                            Text("Last Watered")
                                .font(.custom("Lato-Bold", size:25))
                                .padding(.top, 16)
                                .padding(.leading, 20)
                        }
                    }

                    // watering overview
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 325, height: 340)
                            .foregroundColor(Color(red: 173/255, green: 194/255, blue: 153/255))

                        VStack(alignment: .leading, spacing: 20) {
                            Text("Watering Overview")
                                .font(.custom("Lato-Bold", size: 25))
                                .padding(.top, 16)
                                .padding(.leading, 20)

                            // Pie Chart
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 24)

                                Circle()
                                    .trim(from: 0.0, to: 0.5)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 24))
                                    .rotationEffect(.degrees(-90))

                                Circle()
                                    .trim(from: 0.5, to: 0.7)
                                    .stroke(Color.red, style: StrokeStyle(lineWidth: 24))
                                    .rotationEffect(.degrees(-90))

                                Circle()
                                    .trim(from: 0.7, to: 1.0)
                                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 24))
                                    .rotationEffect(.degrees(-90))
                            }
                            .frame(width: 100, height: 100)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)

                            // Key
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Circle().fill(Color.blue).frame(width: 16, height: 16)
                                    Text("Watered on time")
                                }
                                HStack {
                                    Circle().fill(Color.red).frame(width: 16, height: 16)
                                    Text("Skipped/Late")
                                }
                                HStack {
                                    Circle().fill(Color.yellow).frame(width: 16, height: 16)
                                    Text("Due soon")
                                }
                            }
                            .padding(.leading, 20)
                        }
                        .frame(width: 325, alignment: .topLeading)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }

            // bottom nav bar
            Spacer()
            HStack {
                NavigationLink{
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(.greenShade))
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    PlantsView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(.backgroundShade))
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    WifiView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(.backgroundShade))
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    JournalView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "book.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(.backgroundShade))
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    SettingsView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(.backgroundShade))
                        .frame(maxWidth: .infinity)
                }

            }
            .frame(width: UIScreen.main.bounds.width, height: 56)
            .background(Color(.blueShade))
        }
        .foregroundStyle(Color(.text))
        .font(.custom("Lato-Regular", size: 20))
        .background(Color(.backgroundShade))
    }
}

#Preview {
    ContentView()
}
