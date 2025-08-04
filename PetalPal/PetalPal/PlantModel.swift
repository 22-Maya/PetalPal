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
                wateringDetails: "Keep soil consistently moist, water when top inch feels dry",
                sunlight: "Full sun, but may need shade in hot climates",
                soil: "Loose, loamy, well-draining soil, slightly acidic pH",
                notes: "Thrives in cooler temperatures. Harvest by cutting stems near the base, pinch off flower stalks before they mature. Delay bolting by watering well, provide some shade, harvest frequently."
            ),
            PlantInfo(
                name: "Lavender",
                type: "Flower",
                wateringDetails: "Water sparingly, allow soil to dry between waterings",
                sunlight: "Full sun, 6-8 hours of direct sunlight daily",
                soil: "Well-draining, sandy or gravelly soil with alkaline pH",
                notes: "Prune after flowering to maintain shape. Avoid overwatering as it's drought-tolerant. Plant in raised beds or containers for better drainage."
            ),
            PlantInfo(
                name: "Mint",
                type: "Herb",
                wateringDetails: "Keep soil consistently moist, water when top feels dry",
                sunlight: "Partial shade to full sun, 4-6 hours of sunlight",
                soil: "Rich, moist, well-draining soil",
                notes: "Plant in containers to prevent spreading. Harvest regularly to promote bushier growth. Cut back before flowering for best flavor."
            ),
            PlantInfo(
                name: "Bell Pepper",
                type: "Vegetable",
                wateringDetails: "1-2 inches per week, water when soil feels dry",
                sunlight: "Full sun, 6-8 hours of direct sunlight",
                soil: "Rich, well-draining soil with organic matter",
                notes: "Support plants with stakes or cages. Fertilize regularly during growing season. Harvest when firm and fully colored."
            ),
            PlantInfo(
                name: "Lemon Tree",
                type: "Fruit",
                wateringDetails: "Water deeply but infrequently, allow soil to dry between waterings",
                sunlight: "Full sun, 8-12 hours of direct sunlight",
                soil: "Well-draining, slightly acidic soil",
                notes: "Protect from frost. Prune to maintain shape and remove dead wood. Fertilize with citrus-specific fertilizer."
            )
        ]
        
        // Add all sample plants to the database
        for plant in samplePlants {
            modelContext.insert(plant)
        }
        
        // Save the context
        do {
            try modelContext.save()
            print("Successfully populated plant database with \(samplePlants.count) plants")
        } catch {
            print("Failed to save plant database: \(error)")
        }
    }
}
