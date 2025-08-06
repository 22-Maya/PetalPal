import SwiftUI
import FirebaseAuth

// main view
struct MainView: View {
    @Environment(\.dismiss) private var dismiss
    let plant: Plant
    
    @State private var isCareInfoExpanded: Bool = false
    
    private var plantInfo: PlantInfo? {
        PlantInfoDatabase.find(for: plant.name)
    }
    
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
            Color(.backgroundShade)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                    // navbar
                HStack {
                    Text("PetalPal")
                        .scaledFont("Prata-Regular", size: 28)
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
                            .foregroundColor(Color(.greenShade))
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 56)
                .background(Color(.blueShade))
                
                    // back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(.tealShade))
                        .scaledFont("Lato-Regular", size: 18)
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                .padding(.vertical, 10)
                
                ScrollView {
                    // plant display
                    VStack(spacing: 10) {
                        getPlantImage(for: plant.type)
                            .resizable()
                            .frame(width: 250, height: 350)
                        
                        Text(plant.name)
                            .scaledFont("Prata-Regular", size: 50)
                            .foregroundColor(.text)
                        
                        Text(plant.type)
                            .scaledFont("Lato-Regular", size: 25)
                            .foregroundColor(.text.opacity(0.7))
                    }
                    .padding(.top, 30)
                    
                    // user's plant info
                    if !plant.wateringFrequency.isEmpty || !plant.wateringAmount.isEmpty || !plant.sunlightNeeds.isEmpty || !plant.careInstructions.isEmpty {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                                    .font(.system(size: 24))
                                Text("Your Care Notes")
                                    .scaledFont("Lato-Bold", size: 26)
                                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.info))
                                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            VStack(spacing: 16) {
                                if !plant.wateringFrequency.isEmpty {
                                    CareDetailSection(
                                        title: "Watering Frequency",
                                        content: plant.wateringFrequency,
                                        icon: "drop.fill",
                                        color: Color(red: 67/255, green: 137/255, blue: 124/255)
                                    )
                                }
                                if !plant.wateringAmount.isEmpty {
                                    CareDetailSection(
                                        title: "Watering Amount",
                                        content: plant.wateringAmount,
                                        icon: "drop.fill",
                                        color: Color(red: 67/255, green: 137/255, blue: 124/255)
                                    )
                                }
                                if !plant.sunlightNeeds.isEmpty {
                                    CareDetailSection(
                                        title: "Sunlight Needs",
                                        content: plant.sunlightNeeds,
                                        icon: "sun.max.fill",
                                        color: Color(red: 255/255, green: 193/255, blue: 7/255)
                                    )
                                }
                                if !plant.careInstructions.isEmpty {
                                    CareDetailSection(
                                        title: "Care Instructions",
                                        content: plant.careInstructions,
                                        icon: "lightbulb.fill",
                                        color: Color(red: 255/255, green: 152/255, blue: 0/255)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // general plant care details (dropdown section)
                    VStack(alignment: .leading, spacing: 0) {
                        // header: tappable area with a rotating chevron
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Color(.text))
                                .font(.system(size: 24))
                            
                            Text("Care Information")
                                .scaledFont("Lato-Bold", size: 26)
                                .foregroundColor(Color(.text))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(.text))
                                .rotationEffect(.degrees(isCareInfoExpanded ? 180 : 0))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.info))
                                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isCareInfoExpanded.toggle()
                            }
                        }
                        
                        // content: conditionally displayed based on state
                        if isCareInfoExpanded {
                            if let info = plantInfo {
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
                                .padding(.top, 16)
                            } else {
                                // Fallback message
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(Color.orange)
                                            .font(.system(size: 20, weight: .medium))
                                            .frame(width: 24, height: 24)
                                        
                                        Text("No Detailed Care Information Available")
                                            .scaledFont("Lato-Bold", size: 18)
                                            .foregroundColor(Color.orange)
                                        
                                        Spacer()
                                    }
                                    
                                    Text("We don't have detailed care information for \(plant.name) in our database yet. \nPlease refer to your plant's care instructions or consult a gardening resource for specific care requirements.")
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
                                .padding(.top, 16)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(.backgroundShade))
    }
}

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

struct CareDetailSection: View {
    let title: String
    let content: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(.pinkShade))
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .scaledFont("Lato-Bold", size: 20)
                    .foregroundColor(Color(.tealShade))
                
                Spacer()
            }
            
            Text(content)
                .scaledFont("Lato-Regular", size: 16)
                .foregroundColor(Color(.text))
                .lineSpacing(2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.care))
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MainView(plant: Plant(name: "Basil", type: "Herb", wateringFrequency: "Daily", wateringAmount: "1 cup", sunlightNeeds: "Full Sun", careInstructions: "Prune often"))
    }
}
