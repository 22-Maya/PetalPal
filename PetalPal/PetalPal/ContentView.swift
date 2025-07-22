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
                
                
                //            today's tasks section
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width:325, height:150)
                        .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255))
                    VStack(alignment: .leading) {
                        Text("Today's Tasks")
                            .font(.custom("MadimiOne-Regular", size:25))
                            .padding(.top, 16)
                            .padding(.leading, 20)
                        // Filler task list
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("Add water to your plant")
                                .font(.system(size: 18))
                        }
                        .padding(.leading, 20)
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("Check if weeding is needed")
                                .font(.system(size: 18))
                        }
                        .padding(.leading, 20)
                        HStack {
                            Image(systemName: "book.pages.fill")
                                .foregroundColor(.orange)
                            Text("Record a journal entry")
                                .font(.system(size: 18))
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(width: 325, height: 150, alignment: .topLeading)
                }
                .padding(.bottom, 30)
                .padding(.top, 30)
                
                //            watering overview
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 325, height: 200)
                        .foregroundColor(Color(red: 173/255, green: 194/255, blue: 153/255))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Watering Overview")
                            .font(.custom("MadimiOne-Regular", size: 25))
                            .padding(.top, 18)
                            .padding(.leading, 20)
                        Spacer().frame(height: 12)
                        HStack(alignment: .center) {
                            // Key
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 16, height: 16)
                                    Text("Watered on time")
                                        .font(.system(size: 20))
                                }
                                HStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 16, height: 16)
                                    Text("Skipped/Late")
                                        .font(.system(size: 20))
                                }
                                HStack {
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 16, height: 16)
                                    Text("Due soon")
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.leading, 20)
                            Spacer()
                            // Pie Chart
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 24)
                                    .frame(width: 100, height: 100)
                                Circle()
                                    .trim(from: 0.0, to: 0.5)
                                    .stroke(Color.blue, lineWidth: 24)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 100, height: 100)
                                Circle()
                                    .trim(from: 0.5, to: 0.7)
                                    .stroke(Color.red, lineWidth: 24)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 100, height: 100)
                                Circle()
                                    .trim(from: 0.7, to: 1.0)
                                    .stroke(Color.yellow, lineWidth: 24)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 100, height: 100)
                            }
                            .padding(.trailing, 20)
                        }
                        Spacer()
                    }
                    .frame(width: 325, height: 200, alignment: .topLeading)
                }
                .padding(.bottom, 30)
                .padding(.top, 30)
                
                //            bottom nav bar
                Spacer()
                HStack {
                    NavigationLink{
                        ContentView()
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
            .background(Color(red: 240/255, green: 238/255, blue: 221/255))
        }
    }
}
    
#Preview {
    ContentView()
}

