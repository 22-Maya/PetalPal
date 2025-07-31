//
//  SmartPot.swift
//  PetalPal
//
//  Created by AI Assistant
//

import SwiftUI
import SwiftData

@Model
final class SmartPot {
    var id: UUID
    var deviceAddress: String
    var plant: Plant?
    var lastReceivedData: String
    var isConnected: Bool
    
    init(deviceAddress: String) {
        self.id = UUID()
        self.deviceAddress = deviceAddress
        self.lastReceivedData = "N/A"
        self.isConnected = true
    }
}