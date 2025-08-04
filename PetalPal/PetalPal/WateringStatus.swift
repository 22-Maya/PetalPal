import SwiftUI
import Charts

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
