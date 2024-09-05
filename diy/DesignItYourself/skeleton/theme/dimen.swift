//
//  dimens.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct Dimen{
    private static let isPad =  AppUtil.isPad()
    
    
    struct margin {
        public static let heavy:CGFloat = 48
        public static let medium:CGFloat = 32
        public static let regular:CGFloat = 20
        public static let light:CGFloat = 14
        public static let thin:CGFloat = 12
        public static let tiny:CGFloat = 8
        public static let micro:CGFloat = 2
    }

    struct icon {
        public static let heavy:CGFloat = 60
        public static let medium:CGFloat =  42
        public static let regular:CGFloat = 36
        public static let light:CGFloat = 28
        public static let thin:CGFloat = 24
        public static let tiny:CGFloat = 20
        public static let micro:CGFloat = 12
    }
    
    struct tab {
        public static let heavy:CGFloat = 104
        public static let medium:CGFloat = 90
        public static let regular:CGFloat = 70
        public static let light:CGFloat = 56
        public static let thin:CGFloat = 44
        public static let tiny:CGFloat = 11
    }
    
    struct button {
        public static let heavy:CGFloat =  80
        public static let medium:CGFloat = 50
        public static let regular:CGFloat = 48
        public static let light:CGFloat = 40
        public static let thin:CGFloat = 22
        public static let tiny:CGFloat = 16
        
        public static let heavyRect:CGSize = CGSize(width: 90, height: 42)
        public static let mediumRect:CGSize = CGSize(width: 132, height: 40)
        public static let regularRect:CGSize = CGSize(width: 84, height: 24)
        public static let lightRect:CGSize = CGSize(width: 38, height: 20)
    }

    struct radius {
        public static let heavy:CGFloat = 20
        public static let medium:CGFloat = 12
        public static let regular:CGFloat = 10
        public static let light:CGFloat = 8
        public static let thin:CGFloat = 6
        public static let micro:CGFloat = 2
    }
    
    struct bar {
        public static let medium:CGFloat = 21
        public static let regular:CGFloat = 14
        public static let light:CGFloat = 4
        public static let tiny:CGFloat = 2
    }
    
    struct line {
        public static let heavy:CGFloat = 8
        public static let medium:CGFloat = 3
        public static let regular:CGFloat = 2
        public static let light:CGFloat = 1
    }
    
    struct stroke {
        public static let heavy:CGFloat = 7
        public static let medium:CGFloat = 3
        public static let regular:CGFloat = 2
        public static let light:CGFloat = 1
    }
    
    struct app {
        public static let horizontal:CGFloat = 16
        public static let bottom:CGFloat = 60
        public static let top:CGFloat = 80
    }
    
    struct item {
        static let character = CGSize(width: 80, height: 80)
    }
    
    
}

