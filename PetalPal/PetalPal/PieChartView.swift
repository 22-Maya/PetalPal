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
                outerRadius: selectedStatusID == dataPoint.id ? 130 : 110,
                angularInset: 1.0
            )
            .foregroundStyle(dataPoint.color)
            .annotation(position: .overlay) {
                if selectedStatusID == nil || dataPoint.id == selectedStatusID {
                    Text(String(format: "%.0f%%", (dataPoint.count / totalValue) * 100))
                        .font(.custom("Lato-Bold", size: 15))
                        .foregroundColor(Color(red: 26/255, green: 26/255, blue: 26/255))
                        .shadow(color: .white.opacity(0.5), radius: 1)
                }
            }
        }
        .chartAngleSelection(value: $selectedStatusID)
        .aspectRatio(1, contentMode: .fit)
    }
}
