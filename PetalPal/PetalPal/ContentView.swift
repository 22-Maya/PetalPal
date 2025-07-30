//
//  ContentView.swift
//  Petal Pal
//
//  Created by Adishree Das on 7/21/25.
//
import SwiftUI
import Charts

struct ContentView: View {
    @State private var wateringData: [WateringStatus] = [
        .init(status: "Watered on time", count: 70, color: Color(.blueShade)),
        .init(status: "Skipped/Late", count: 15, color: Color(.pinkShade)),
        .init(status: "Due soon", count: 15, color: Color(red: 255/255, green: 215/255, blue: 0/255))
    ]

    @State private var selectedStatusID: UUID?

    private var selectedStatus: WateringStatus? {
        wateringData.first(where: { $0.id == selectedStatusID })
    }

    private var totalWaterings: Double {
        wateringData.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        TabView {
            // Home Tab
            NavigationStack {
                HStack {
                    Text("Petal Pal")
                        .font(.custom("Prata-Regular", size: 28))
                        .foregroundColor(Color(.tealShade))
                        .padding(.leading, 20)
                    Spacer()
                    NavigationLink {
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
                        // tasks
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width:325)
                                .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255)) // Original color, consider dark mode
                            VStack(alignment: .leading) {
                                Text("Today's Tasks\n")
                                    .font(.custom("Lato-Bold", size:25))
                                    .padding(.top, 16)
                                    .padding(.leading, 20)
                            }
                        }

                        // last watered section
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width: 325)
                                .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255)) // Original color, consider dark mode
                            VStack(alignment: .leading) {
                                Text("Last Watered \n")
                                    .font(.custom("Lato-Bold", size:25))
                                    .padding(.top, 16)
                                    .padding(.leading, 20)
                            }
                        }

                        // watering overview
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width: 325)
                                .foregroundColor(Color(red: 173/255, green: 194/255, blue: 153/255)) // Original color, consider dark mode

                            VStack(alignment: .leading, spacing: 20) {
                                Text("Watering Overview")
                                    .font(.custom("Lato-Bold", size: 25))
                                    .padding(.top, 16)
                                    .padding(.leading, 20)

                                PieChartView(data: wateringData, selectedStatusID: $selectedStatusID, totalValue: totalWaterings)
                                    .frame(width: 200, height: 200)
                                    .frame(maxWidth: .infinity, alignment: .center)


                                // key
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(wateringData) { dataPoint in
                                        HStack {
                                            Circle()
                                                .fill(dataPoint.color)
                                                .frame(width: 16, height: 16)
                                            Text(dataPoint.status)
                                                .foregroundColor(Color(.text))
                                        }

                                        .onTapGesture {
                                            self.selectedStatusID = (self.selectedStatusID == dataPoint.id) ? nil : dataPoint.id
                                        }
                                    }
                                }
                                .padding(.leading, 20)
                                .padding(.bottom, 16)
                            }
                            .frame(width: 325, alignment: .topLeading)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                }
            }
            .toolbarBackground(Color(.blueShade), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tint(Color(.greenShade))
            .accentColor(Color(.greenShade))
            .tabItem {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            }
            
            // Plants Tab
            PlantsView()
                .tabItem {
                    VStack {
                        Image(systemName: "leaf.fill")
                        Text("Plants")
                    }
                }

            // Add Tab
            WifiView()
                .tabItem {
                    VStack {
                        Image(systemName: "plus.app.fill")
                        Text("Add")
                    }
                }

            // Journal Tab
            JournalView()
                .tabItem {
                    VStack {
                        Image(systemName: "book.fill")
                        Text("Journal")
                    }
                }

            // Settings Tab
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                        Text("Profile")
                    }
                }
        }
        .foregroundStyle(Color(.text))
        .font(.custom("Lato-Regular", size: 20))
        .background(Color(.backgroundShade))
    }
}

#Preview {
    ContentView()
}
