import SwiftUI
import Charts
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck

struct MainView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var plantDatabase: [PlantInfo]
    
    let plant: Plant
    
    // finds the plant info from PlantModel
    private var plantInfo: PlantInfo? {
        plantDatabase.first { $0.name.lowercased() == plant.name.lowercased() }
    }
    
    // gets plant image based on type
    private func getPlantImage(for type: String) -> Image {
        switch type {
        case "Flower":
            return Image(.flower)
        case "Vegetable":
            return Image(.veggie)
        case "Herb":
            return Image(.herb)
        case "Fruit":
            return Image(.fruit)
        default:
            return Image(.flower)
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 249/255, green: 248/255, blue: 241/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // navbar
                HStack {
                    Text("PetalPal")
                        .scaledFont("Prata-Regular", size: 28)
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
                            .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 56)
                .background(Color(red: 174/255, green: 213/255, blue: 214/255))
                
                // back button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                        .scaledFont("Lato-Regular", size: 18)
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                .padding(.vertical, 10)
                
                ScrollView {
                    // Plant Display
                    VStack(spacing: 10) {
                        getPlantImage(for: plant.type)
                            .resizable()
                            .frame(width: 250, height: 350)
                        
                        Text(plant.name)
                            .scaledFont("Prata-Regular", size: 50)
                            .foregroundColor(.black)
                        
                        Text(plant.type)
                            .scaledFont("Lato-Regular", size: 25)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.top, 30)
                    
                    // user's plant info
                    VStack(alignment: .leading, spacing: 20) {
                        if !plant.wateringFrequency.isEmpty {
                            DetailSection(title: "Watering Frequency", content: plant.wateringFrequency)
                        }
                        if !plant.wateringAmount.isEmpty {
                            DetailSection(title: "Watering Amount", content: plant.wateringAmount)
                        }
                        if !plant.sunlightNeeds.isEmpty {
                            DetailSection(title: "Sunlight Needs", content: plant.sunlightNeeds)
                        }
                        if !plant.careInstructions.isEmpty {
                            DetailSection(title: "Care Instructions", content: plant.careInstructions)
                        }
                    }
                    
                    // plant care details
                    if let info = plantInfo {
                        VStack(alignment: .leading, spacing: 25) {
                            
                            // Header with icon
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                                    .font(.system(size: 24))
                                Text("Care Information")
                                    .scaledFont("Lato-Bold", size: 26)
                                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 216/255, green: 232/255, blue: 202/255))
                                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Care sections with improved styling
                            VStack(spacing: 16) {
                                CareDetailSection(
                                    title: "Watering",
                                    content: info.wateringDetails,
                                    icon: "drop.fill",
                                    color: Color(red: 67/255, green: 137/255, blue: 124/255)
                                )
                                
                                CareDetailSection(
                                    title: "Sunlight",
                                    content: info.sunlight,
                                    icon: "sun.max.fill",
                                    color: Color(red: 255/255, green: 193/255, blue: 7/255)
                                )
                                
                                CareDetailSection(
                                    title: "Soil",
                                    content: info.soil,
                                    icon: "leaf.fill",
                                    color: Color(red: 139/255, green: 69/255, blue: 19/255)
                                )
                                
                                if let notes = info.notes {
                                    CareDetailSection(
                                        title: "Additional Care Tips",
                                        content: notes,
                                        icon: "lightbulb.fill",
                                        color: Color(red: 255/255, green: 152/255, blue: 0/255)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        .onAppear {
            if plantDatabase.isEmpty {
                PlantInfo.populateDatabase(modelContext: modelContext)
            }
        }
    }
}

// consistent detail sections
struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .scaledFont("Lato-Bold", size: 22)
            Text(content)
                .scaledFont("Lato-Regular", size: 18)
        }
    }
}

// Enhanced care detail section with icons and better styling
struct CareDetailSection: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .scaledFont("Lato-Bold", size: 20)
                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                
                Spacer()
            }
            
            Text(content)
                .scaledFont("Lato-Regular", size: 16)
                .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))
                .lineSpacing(2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    NavigationStack {
        MainView(plant: Plant(name: "Basil", type: .herb))
    }
    .modelContainer(for: [Plant.self, PlantInfo.self], inMemory: true)
}
