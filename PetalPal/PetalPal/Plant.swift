import Foundation
import FirebaseFirestore

struct Plant: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var type: String
    var wateringFrequency: String
    var wateringAmount: String
    var sunlightNeeds: String
    var careInstructions: String
}

enum PlantType: String, Codable, Identifiable, CaseIterable {
    case fruit = "Fruit"
    case vegetable = "Vegetable"
    case herb = "Herb"
    case flower = "Flower"
    case other = "Other"
    var id: String { self.rawValue }
}
