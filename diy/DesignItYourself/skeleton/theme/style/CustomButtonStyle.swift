//
//  CustomButtonStyle.swift
//  SKBplayer
//
//  Created by JeongCheol Kim on 2023/09/22.
//

import SwiftUI

struct RectButtonStyle: ButtonStyle {
    var color = Color.brand.primary
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

struct GrowingRectButtonStyle: ButtonStyle {
    var color = Color.brand.primary
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
