//
//  TextStyle.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/07.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct TextModifier {
    var family:String = Font.family.regular
    var size:CGFloat = Font.size.regular
    var color: Color = Color.brand.content
    var activeColor: Color = Color.brand.content
    var sizeScale: CGFloat = 1.1
    
    func getTextWidth(_ text:String) -> CGFloat{
        return text.textSizeFrom(fontSize: size * sizeScale).width
    }
}




struct BoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.bold,size:Font.size.bold)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}

struct SemiBoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.semiBold, size:Font.size.semiBold, color: Color.app.white)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular) 
    }
}

struct MediumTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.medium,size:Font.size.medium)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}

struct RegularTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.regular,size:Font.size.regular)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}

struct LightTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.light,size:Font.size.light)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}

struct NumberItalicBoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.numberItalic,size:Font.size.boldUltra)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}


struct NumberBoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.numberBold,size:Font.size.bold)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}

struct NumberRegularTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.number,size:Font.size.medium)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
            
    }
}

struct NumberLightTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.number,size:Font.size.light)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
           
    }
}



struct CustomTextStyle: ViewModifier {
    var textModifier:TextModifier
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    func body(content: Content) -> some View {
        return content
            .truncationMode(.tail)
            .font(.custom(textModifier.family, size: textModifier.size))
            .foregroundColor(textModifier.color)
            .lineSpacing(Font.spacing.regular)
    }
}


