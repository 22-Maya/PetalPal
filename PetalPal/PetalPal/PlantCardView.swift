import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(height: 175)
                .foregroundColor(Color(red: 173/255, green: 194/255, blue: 153/255))

            VStack(alignment: .leading) {
                Text(plant.name)
                    .font(.custom("Lato-Bold", size: 20))
                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))

                Text(plant.type.rawValue)
                    .font(.custom("Lato-Regular", size: 16))
                    .foregroundColor(Color(red: 13/255, green: 47/255, blue: 68/255))

                Spacer()

                HStack {
                    Spacer()
                    plant.type.plantImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 85)
                }
            }
            .padding()
        }
    }
}

#Preview {
    PlantCardView(plant: PlantData.samplePlants[0])
}
