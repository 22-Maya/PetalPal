//
//  PetalPalApp.swift
//  PetalPal
//
//  Created by Adishree Das on 7/21/25.
//

import SwiftUI
import SwiftData

@main
struct PetalPalApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(
                for: Plant.self, PlantInfo.self, SmartPot.self, JournalEntry.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .background(Color(red: 249/255, green: 248/255, blue: 241/255))
            }
            .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        }
        .modelContainer(container)
    }
}