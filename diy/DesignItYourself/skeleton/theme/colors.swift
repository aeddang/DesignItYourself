//
//  colors.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
extension Color {
    static var scheme:ColorScheme = .light
    
    
    struct brand {
        public static let primary = Color.init(rgb: 0x86388C)
        public static let secondary = Color.init(rgb: 0x73D5EF)
        public static let third = Color.init(rgb: 0x8FEF73)
        
        public static var content:Color { scheme == .dark ? Color.white : Color.black }
        public static var subContent:Color { scheme == .dark ? Color.gray : Color.gray }
        public static var bg:Color { scheme == .dark ? Color.black : Color.app.darkWhite }
        public static var subBg:Color { scheme == .dark ? Color.app.darkGray : Color.app.lightGray }
        public static var transparentBg:Color { scheme == .dark ? Color.transparent.black50 : Color.transparent.white50 }
    }
    
    struct app {
        public static let white =  Color.white
        public static let darkWhite = Color.init(rgb: 0xEEEEEE)
        public static let black =  Color.black
        public static let gray =  Color.gray
        public static let darkGray =  Color.init(rgb: 0x2A2A2A)
        public static let lightGray =  Color.init(rgb: 0xCCCCCC)
        public static let blue =  Color.blue
        public static let red =  Color.red
        public static let yellow =  Color.yellow
    }
    
    struct transparent {
        public static let clear = Color.black.opacity(0.0)
        public static let clearUi = Color.black.opacity(0.0001)
       
        public static let black80 = Color.black.opacity(0.8)
        public static let black70 = Color.black.opacity(0.7)
        public static let black50 = Color.black.opacity(0.5)
        public static let black45 = Color.black.opacity(0.45)
        public static let black30 = Color.black.opacity(0.30)
        public static let black15 = Color.black.opacity(0.15)
        public static let black12 = Color.black.opacity(0.12)
        public static let black10 = Color.black.opacity(0.10)
        
        public static let white70 = Color.white.opacity(0.7)
        public static let white50 = Color.white.opacity(0.5)
        public static let white45 = Color.white.opacity(0.45)
        public static let white30 = Color.white.opacity(0.30) 
        public static let white15 = Color.white.opacity(0.15)
        public static let white10 = Color.white.opacity(0.10)
        
        public static let whiteGradient:Gradient = Gradient(colors: [
            Color.app.white.opacity(1),
            Color.app.white.opacity(0)
        ])
    }
}


