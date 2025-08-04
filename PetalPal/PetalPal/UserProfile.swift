import Foundation
import SwiftUI
import SwiftData

@Model
final class UserProfile {
    var name: String = ""
    var bio: String = ""
    var userId: String = "" // Added to link the profile to a specific user.
    var textSizeMultiplier: Double = 1.0 // Added to store user's text size preference
    
    init(name: String, bio: String, userId: String) {
        self.name = name
        self.bio = bio
        self.userId = userId
        self.textSizeMultiplier = 1.0
    }
}
