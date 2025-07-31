//
//  Plant.swift
//  PetalPal
//
//  Created by Adishree Das on 7/31/25
//

import SwiftUI
import SwiftData

@Model
final class Plant {
    var id: UUID
    var name: String
    var type: String 
    var wateringFrequency: String
    var wateringAmount: String
    var sunlightNeeds: String
    var careInstructions: String
    
    init(name: String, type: PlantType) {
        self.id = UUID()
        self.name = name
        self.type = type.rawValue 
        self.wateringFrequency = ""
        self.wateringAmount = ""
        self.sunlightNeeds = ""
        self.careInstructions = ""
    }
    
    var plantType: PlantType {
        PlantType(rawValue: type) ?? .flower 
    }
}

// Keep PlantType enum separate for UI
enum PlantType: String, Codable, Identifiable, CaseIterable {
    case fruit = "Fruit"
    case vegetable = "Vegetable"
    case herb = "Herb"
    case flower = "Flower"
    
    var id: String { self.rawValue }
}