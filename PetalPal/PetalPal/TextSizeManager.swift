//
//  TextSizeManager.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import Combine
import SwiftData

class TextSizeManager: ObservableObject {
    static let shared = TextSizeManager()
    
    @Published var textSizeMultiplier: Double {
        didSet {
            // Save to UserDefaults for immediate persistence
            UserDefaults.standard.set(textSizeMultiplier, forKey: "textSizeMultiplier")
            
            // Also save to user profile if available
            saveToUserProfile()
        }
    }
    
    private var modelContext: ModelContext?
    private var currentUserId: String?
    
    private init() {
        self.textSizeMultiplier = UserDefaults.standard.double(forKey: "textSizeMultiplier")
        if self.textSizeMultiplier == 0 {
            self.textSizeMultiplier = 1.0 // Default size
        }
    }
    
    func configure(modelContext: ModelContext, userId: String) {
        self.modelContext = modelContext
        self.currentUserId = userId
        loadFromUserProfile()
    }
    
    func getScaledCustomFont(_ fontName: String, baseSize: CGFloat) -> Font {
        let scaledSize = baseSize * textSizeMultiplier
        return .custom(fontName, size: scaledSize)
    }
    
    private func saveToUserProfile() {
        guard let modelContext = modelContext,
              let userId = currentUserId else { return }
        
        // Fetch existing user profile
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate<UserProfile> { $0.userId == userId }
        )
        
        do {
            let profiles = try modelContext.fetch(descriptor)
            if let profile = profiles.first {
                // Update existing profile with text size preference
                profile.textSizeMultiplier = textSizeMultiplier
            } else {
                // Create new profile with text size preference
                let newProfile = UserProfile(name: "", bio: "", userId: userId)
                newProfile.textSizeMultiplier = textSizeMultiplier
                modelContext.insert(newProfile)
            }
            
            try modelContext.save()
        } catch {
            print("Failed to save text size to user profile: \(error)")
        }
    }
    
    private func loadFromUserProfile() {
        guard let modelContext = modelContext,
              let userId = currentUserId else { return }
        
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate<UserProfile> { $0.userId == userId }
        )
        
        do {
            let profiles = try modelContext.fetch(descriptor)
            if let profile = profiles.first,
               profile.textSizeMultiplier > 0 {
                // Load text size from user profile
                self.textSizeMultiplier = profile.textSizeMultiplier
                // Update UserDefaults to match
                UserDefaults.standard.set(textSizeMultiplier, forKey: "textSizeMultiplier")
            }
        } catch {
            print("Failed to load text size from user profile: \(error)")
        }
    }
} 
