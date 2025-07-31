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
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .background(Color(red: 249/255, green: 248/255, blue: 241/255))
            }
            .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        }
        .modelContainer(for: [Plant.self, PlantInfo.self, SmartPot.self])
    }
}