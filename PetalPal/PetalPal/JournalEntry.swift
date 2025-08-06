import Foundation
import FirebaseFirestore

struct JournalEntry: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var content: String
    var date: Timestamp
    var plantName: String?
}

