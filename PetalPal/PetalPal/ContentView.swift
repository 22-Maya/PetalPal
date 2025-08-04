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

    // tabview colors
    init() {
        let appearance = UITabBarAppearance()

        appearance.backgroundColor = UIColor(Color(.blueShade))
        appearance.selectionIndicatorTintColor = UIColor(Color(.text))
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(.text))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(.text)),
            .font: UIFont(name: "Lato-Regular", size: 12)!
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(.tealShade))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color(.tealShade)),
            .font: UIFont(name: "Lato-Regular", size: 12)!
        ]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            // home tab
            NavigationStack {
                HStack {
                    Text("PetalPal")
                        .scaledFont("Prata-Regular", size: 28)
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
                        VStack(alignment: .leading) {
                            Text("Today's Tasks")
                                .scaledFont("Lato-Bold", size: 25)
                                .padding(.top, 20)
                                .padding(.bottom, 5)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("- Check on all plants")
                                    .scaledFont("Lato-Regular", size: 18)
                                Text("- Spend some time outdoors")
                                    .scaledFont("Lato-Regular", size: 18)
                                Text("- Water your tomato plant soon")
                                    .scaledFont("Lato-Regular", size: 18)
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                        }
                        .frame(maxWidth: 325)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(red: 216/255, green: 232/255, blue: 202/255))
                        )

                        // watering overview
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Watering Overview")
                                .scaledFont("Lato-Bold", size: 25)
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
                                            .scaledFont("Lato-Regular", size: 16)
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
                        .frame(maxWidth: 325)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(red: 173/255, green: 194/255, blue: 153/255))
                        )
                    }
                }
            }
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
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(.backgroundShade))
    }
}

#Preview {
    ContentView()
}
