import Foundation
import FirebaseFirestore

// The model has been renamed to TaskItem to avoid conflicts with Swift's concurrency Task.
struct TaskItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var isCompleted: Bool
}
