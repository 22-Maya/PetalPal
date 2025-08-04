//
//  TextSizeManager.swift
//  PetalPal
//
//  Created by Adishree Das on 8/03/25.
//

import SwiftUI
import Combine

class TextSizeManager: ObservableObject {
    static let shared = TextSizeManager()
    
    @Published var textSizeMultiplier: Double {
        didSet {
            UserDefaults.standard.set(textSizeMultiplier, forKey: "textSizeMultiplier")
        }
    }
    
    private init() {
        self.textSizeMultiplier = UserDefaults.standard.double(forKey: "textSizeMultiplier")
        if self.textSizeMultiplier == 0 {
            self.textSizeMultiplier = 1.0 // Default size
        }
    }
    
    func getScaledCustomFont(_ fontName: String, baseSize: CGFloat) -> Font {
        let scaledSize = baseSize * textSizeMultiplier
        return .custom(fontName, size: scaledSize)
    }
} 
