import Foundation
import FirebaseFirestore

struct TaskItem: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var isCompleted: Bool
}
