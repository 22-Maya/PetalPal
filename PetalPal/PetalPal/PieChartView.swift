import SwiftUI
import Charts // Crucial for using the Charts framework

struct WateringStatus: Identifiable, Hashable {
    let id = UUID()
    let status: String
    let count: Double
    let color: Color
}

extension UUID: @retroactive Plottable {
    public var primitivePlottable: String {
        self.uuidString
    }

    public init?(primitivePlottable: String) {
        self.init(uuidString: primitivePlottable)
    }
}


struct PieChartView: View {
    let data: [WateringStatus]
    @Binding var selectedStatusID: UUID?

    let totalValue: Double

    var body: some View {
        Chart(data) { dataPoint in
            SectorMark(
                angle: .value("Count", dataPoint.count),
                innerRadius: 30,
                outerRadius: selectedStatusID == dataPoint.id ? 100 : 80,
                angularInset: 1.0
            )
            .foregroundStyle(dataPoint.color)
            .annotation(position: .overlay) {
                if selectedStatusID == nil || dataPoint.id == selectedStatusID {
                    Text(String(format: "%.0f%%", (dataPoint.count / totalValue) * 100))
                        .font(.custom("Lato-Bold", size: 12))
                        .foregroundColor(Color(red: 26/255, green: 26/255, blue: 26/255))
                        .shadow(color: .white.opacity(0.5), radius: 1)
                }
            }
        }
        .chartAngleSelection(value: $selectedStatusID)
        .aspectRatio(1, contentMode: .fit)
    }
}

/*struct PieChartView_Previews: PreviewProvider {
    @State static var previewSelectedStatusID: UUID? = nil
    static var previewData: [WateringStatus] = [
        .init(status: "Watered on time", count: 70, color: Color(red: 174/255, green: 213/255, blue: 214/255)),
        .init(status: "Skipped/Late", count: 15, color: Color(red: 234/255, green: 194/255, blue: 209/255)),
        .init(status: "Due soon", count: 15, color: Color(red: 255/255, green: 215/255, blue: 0/255))
    ]
    static var previews: some View {
        PieChartView(data: previewData, selectedStatusID: $previewSelectedStatusID, totalValue: previewData.reduce(0) { $0 + $1.count })
            .frame(width: 250, height: 250)
            .padding()
            .background(Color(red: 43/255, green: 43/255, blue: 43/255))
            .cornerRadius(20)
            .shadow(radius: 10)
    }
}*/
