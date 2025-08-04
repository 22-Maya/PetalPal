
import Foundation
import SwiftData

//This model will store individual pot (plant) details locally using SwiftData.
@Model
final class Pot {
    var id: UUID
    var name: String
    var type: String
    var lastWatered: Date
    var notes: String

    // Initialize with default values
    init(id: UUID = UUID(), name: String, type: String, lastWatered: Date, notes: String) {
        self.id = id
        self.name = name
        self.type = type
        self.lastWatered = lastWatered
        self.notes = notes
    }
}
