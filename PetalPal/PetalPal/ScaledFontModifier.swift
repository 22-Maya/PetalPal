//
//  ScaledFontModifier.swift
//  PetalPal
//
//  Created by Adishree Das on 8/03/25.
//

import SwiftUI

struct ScaledFontModifier: ViewModifier {
    @EnvironmentObject var textSizeManager: TextSizeManager
    let fontName: String
    let baseSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(textSizeManager.getScaledCustomFont(fontName, baseSize: baseSize))
    }
}

extension View {
    func scaledFont(_ fontName: String, size: CGFloat) -> some View {
        self.modifier(ScaledFontModifier(fontName: fontName, baseSize: size))
    }
} 
