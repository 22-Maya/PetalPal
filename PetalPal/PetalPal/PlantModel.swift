//
//  PlantModel.swift
//  PetalPal
//
//  Created by Adishree Das on 7/31/25
//


//this is like the database of plants



import SwiftUI
import SwiftData

@Model
final class PlantInfo {
    var id: UUID
    var name: String
    var type: String
    var lastWatered: Date
    var wateringDetails: String
    var sunlight: String
    var soil: String
    var notes: String?
    
    init(name: String, type: String, wateringDetails: String, sunlight: String, soil: String, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.lastWatered = Date()
        self.wateringDetails = wateringDetails
        self.sunlight = sunlight
        self.soil = soil
        self.notes = notes
    }
    
// sample plants
    static func populateDatabase(modelContext: ModelContext) {
        let samplePlants = [
            PlantInfo(
                name: "Basil",
                type: "Herb",
                wateringDetails: "1-1.5 in per week, water every 2-3 days",
                sunlight: "Full sun, 6-8 hours of direct sunlight  with some afternoon shade in hotter climates",
                soil: "Rich, well-drained, moist soil",
                notes: "Prune regularly by pinching off flower buds and harvesting shoots. Harvest by snipping stems above leaf nodes and taking a few leaves from each stem. Check for pests & disease."
            ),
            PlantInfo(
                name: "Tomato",
                type: "Fruit",
                wateringDetails: "1-2 in per week, water every 2-4 days",
                sunlight: "Full sun, 6-8 hours of direct sunlight with some afternoon shade in hotter climates",
                soil: "Well draining, nitrogen-rich soil w/ compost and eggshells",
                notes: "Fertilizer and support needed, apply mulch around base and prune by removing suckers. Harvest when fully colored and slightly soft. Check for pests & disease."
            ),
            PlantInfo(
                name: "Hibiscus",
                type: "Flower",
                wateringDetails: "1 inch per week, water every day",
                sunlight: "Full sun, 6 hours of direct sunlight daily.",
                soil: "Consistently moist but not soggy soil",
                notes: "Regular fertilization with fertilizer high in potassium and low in phosphorus. Prune hibiscus plants and check for pests & disease. Bring hibiscus inside during winter/cold seasons. Remove spent blooms."
            ),
            PlantInfo(
                name: "Orchid",
                type: "Flower",
                wateringDetails: "water every week",
                sunlight: "Bright indirect sunlight",
                soil: "Requires a specialized, airy, well-draining potting mix instead of regular potting soil",
                notes: "Use lukewarm water, avoid overwatering. Water thoroughly but infrequently. Moderate to high humidity. Remove dead leaves/flowers and observe for pests/diseases."
            ),
            PlantInfo(
                name: "Cucumber",
                type: "Vegetable",
                wateringDetails: "1 in per week, 2-3 days",
                sunlight: "Full sun, 6-8 hours of direct sunlight daily",
                soil: "Fertile, well-drained soil rich in organic matter.",
                notes: "Regular feeding with a balanced, soluble fertilizer during fruiting stage. Support needed to prevent disease, circulate air, and straighter fruit. Avoid overwatering."
            ),
            PlantInfo(
                name: "Strawberry",
                type: "Fruit",
                wateringDetails: "1-1.5 in per week, water twice a week",
                sunlight: "Full sun, 6-8 hours of direct sunlight.",
                soil: "Slightly acidic, loamy, well-draining soil",
                notes: "Organic fertilizer, mulch around plants to retain moisture, pest and disease control, replant every few years to increase productivity."
            ),
            PlantInfo(
                name: "Radish",
                type: "Vegetable",
                wateringDetails: "1 in per week, water 1-2 times a week",
                sunlight: "Full sun & 6 hours of sunlight daily, but can tolerate partial shade",
                soil: "Well-drained, moist, loose soil that's slightly organic",
                notes: "Adding organic matter to soil can improve growth, but not too much. Check for pests/diseases."
            ),
            PlantInfo(
                name: "Cilantro",
                type: "Herb",
                wateringDetails: "",
                sunlight: "Full sun, but may need shade in hot climates",
                soil: "Loose, loamy, well-draining soil, slightly acidic pH",
                notes: "Thrives in cooler temperatures. Harvest by cutting stems near the base, pinch off flower stalks before they mature. Delay bolting by watering well, provide some shade, harvest frequently."
            ),
            
        ]
   
    }
}
