import Foundation
import FirebaseFirestore

// This struct represents a single to-do item.
// It's Codable so it can be easily saved to and loaded from Firestore.
struct TaskItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var isCompleted: Bool
}
