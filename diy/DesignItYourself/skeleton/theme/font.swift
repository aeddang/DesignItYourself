//
//  font.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/05.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension Font{
    private static let isPad =  AppUtil.isPad()
    
    struct customFont {
        public static let light =  Font.custom(Font.family.light, size: Font.size.light)
        public static let regular = Font.custom(Font.family.regular, size: Font.size.regular)
        public static let medium = Font.custom(Font.family.medium, size: Font.size.medium)
        public static let bold = Font.custom(Font.family.bold, size: Font.size.bold)
        public static let semeBold = Font.custom(Font.family.semiBold, size: Font.size.semiBold)
    }
   
    
    struct family {
        
        public static let bold =  "AppleSDGothicNeo-Bold"
        public static let semiBold =  "AppleSDGothicNeo-SemiBold"
        public static let medium =  "AppleSDGothicNeo-Medium"
        public static let regular = "AppleSDGothicNeo-Regular"
        public static let light =  "AppleSDGothicNeo-Light"
        public static let thin =  "AppleSDGothicNeo-Thin"
        public static let tiny =  "AppleSDGothicNeo-Thin"
        public static let micro =  "AppleSDGothicNeo-Thin"
        
        public static let numberBold = "Arial-BoldMT"
        public static let number = "ArialMT"
        public static let numberItalic = "Arial-ItalicMT"
       
    }
    
   
    
    struct kern {
        public static let thin:CGFloat =  -0.7
        public static let medium:CGFloat =  -0.4
        public static let regular:CGFloat = 0
        public static let large:CGFloat = 0.7
    }
    
    struct spacing {
        public static let large:CGFloat = 10
        public static let regular:CGFloat = 0
        public static let thin:CGFloat = -10
        public static let micro:CGFloat = -20
    }
    
    struct size {
        public static let boldUltra: CGFloat = 36
        public static let boldUltraExtra: CGFloat = 32
        public static let bold:CGFloat = 24
        public static let semiBold:CGFloat = 20
        public static let large:CGFloat = 18
        public static let medium:CGFloat = 16
        public static let regular:CGFloat = 15
        public static let light:CGFloat =  14
        public static let thin:CGFloat = 13
        public static let tiny:CGFloat = 12
        public static let tinyExtra:CGFloat = 11
        public static let microUltra:CGFloat = 10
        public static let micro:CGFloat = 9
        public static let microExtra:CGFloat = 7
    }
    

}
