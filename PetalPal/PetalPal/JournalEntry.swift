import SwiftUI
import SwiftData

//journal entry settings


@Model
final class JournalEntry {
    @Attribute(.unique) let id: UUID
    var content: String
    var date: Date
    @Relationship(deleteRule: .nullify, inverse: \Plant.journalEntries) var plant: Plant?
    
    init(content: String, plant: Plant? = nil) {
        self.id = UUID()
        self.content = content
        self.date = Date()
        self.plant = plant
    }
}
