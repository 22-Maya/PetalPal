import SwiftUI
import Charts
import SwiftData
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
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
        if authViewModel.isAuthenticated {
            TabView {
                NavigationStack {
                    HStack {
                        Text("PetalPal")
                            .scaledFont("Lato-Bold", size: 25)
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
                    .frame(maxWidth: .infinity)
                    .background(Color(.blueShade))
                    .padding(.bottom, 15)

                    ScrollView {
                        VStack(spacing: 30) {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width:325, height: 150)
                                    .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255))
                                VStack(alignment: .leading) {
                                    Text("Today's Tasks\n")
                                        .scaledFont("Lato-Bold", size: 25)
                                        .padding(.top, 16)
                                        .padding(.leading, 20)
                                }
                            }

                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 325, height: 150)
                                    .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255))
                                VStack(alignment: .leading) {
                                    Text("Last Watered \n")
                                        .scaledFont("Lato-Bold", size: 25)
                                        .padding(.top, 16)
                                        .padding(.leading, 20)
                                }
                            }

                            ZStack(alignment: .top) {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 325)
                                    .foregroundColor(Color(red: 173/255, green: 194/255, blue: 153/255))
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Watering Overview")
                                        .scaledFont("Lato-Bold", size: 25)
                                        .padding(.top, 16)
                                        .padding(.leading, 20)
                                    
                                    PieChartView(data: wateringData, selectedStatusID: $selectedStatusID, totalValue: totalWaterings)
                                        .frame(width: 200, height: 200)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
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
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }

                PlantsView()
                    .tabItem {
                        VStack {
                            Image(systemName: "leaf.fill")
                            Text("Plants")
                        }
                    }

                WifiView()
                    .tabItem {
                        VStack {
                            Image(systemName: "plus.app.fill")
                            Text("Add")
                        }
                    }

                JournalView()
                    .tabItem {
                        VStack {
                            Image(systemName: "book.fill")
                            Text("Journal")
                        }
                    }

                ProfileView(authViewModel: authViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.crop.circle.fill")
                            Text("Profile")
                        }
                        .frame(maxWidth: 325)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(red: 173/255, green: 194/255, blue: 153/255))
                        )
                    }
            }
            .environmentObject(authViewModel)
            .foregroundStyle(Color(.text))
            .font(.custom("Lato-Regular", size: 20))
            .background(Color(.backgroundShade))
        } else {
            LoginView()
                .environmentObject(authViewModel)
        }
        .foregroundStyle(Color(.text))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(.backgroundShade))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Pot.self, inMemory: true)
        .environmentObject(AuthViewModel())
}
