//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
//import FirebaseAnalytics
struct TextButton: PageView{
    enum ButtonType{
        case box, blank
        var bgColor:Color{
            get{
                switch self {
                case .box : return Color.brand.subBg
                default : return Color.transparent.clearUi
                }
            }
        }
        
        var bgRadius:CGFloat
        {
            get{
                switch self {
                case .box : return Dimen.radius.regular
                default : return 0
                }
            }
        }
        var paddingVertical:CGFloat
        {
            get{
                switch self {
                case .box : return Dimen.margin.tiny
                default : return 0
                }
            }
        }
        var paddingHorizontal:CGFloat
        {
            get{
                switch self {
                case .box : return Dimen.margin.light
                default : return 0
                }
            }
        }
        var textFamily:String{
            get{
                switch self {
                default : return Font.family.regular
                }
            }
        }
        var textSize:CGFloat
        {
            get{
                switch self {
                default : return Font.size.regular
                }
            }
        }
        var textColor:Color{
            get{
                switch self {
                case .box : return Color.app.black
                default : return Color.brand.content
                }
            }
        }
        var activeColor:Color{
            get{
                switch self {
                case .box : return Color.app.white
                default : return Color.brand.primary
                }
            }
        }
    }
    var type:ButtonType = .blank
    var defaultText:String
    var activeText:String? = nil
    var isSelected: Bool = false
    var index: Int = 0
    var textModifier:TextModifier? = nil
    var isUnderLine:Bool = false
    var image:String? = nil
    var imageSize:CGFloat = Dimen.icon.tiny
    var imageMode:Image.TemplateRenderingMode = .original
    var spacing:CGFloat = Dimen.margin.tiny
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
            let parameters = [
                "buttonType": self.tag,
                "buttonText": defaultText
            ]
            //Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
        }) {
            HStack(alignment:.center, spacing: spacing){
                if self.isUnderLine {
                    Text(self.isSelected ? ( self.activeText ?? self.defaultText ) : self.defaultText)
                        .font(.custom(
                            textModifier?.family ?? self.type.textFamily,
                            size: textModifier?.size ?? self.type.textSize))
                    .underline()
                    .foregroundColor(self.isSelected
                                     ? textModifier?.activeColor ?? self.type.activeColor
                                     : textModifier?.color ?? self.type.textColor)
                    .lineLimit(1)
                } else {
                    
                    Text(self.isSelected ? ( self.activeText ?? self.defaultText ) : self.defaultText)
                        .font(.custom(
                            textModifier?.family ?? self.type.textFamily,
                            size: textModifier?.size ?? self.type.textSize))
                        .foregroundColor(self.isSelected
                                         ? textModifier?.activeColor ?? self.type.activeColor
                                         : textModifier?.color ?? self.type.textColor)
                    .lineLimit(1)
                }
                if let img = self.image {
                    Image(img)
                        .renderingMode(self.imageMode).resizable()
                        .scaledToFit()
                        .foregroundColor(
                            self.isSelected
                                 ? textModifier?.activeColor ?? self.type.activeColor
                                 : textModifier?.color ?? self.type.textColor)
                        .frame(width: self.imageSize, height: self.imageSize)
                        .padding(.bottom, 1)
                }
            }
            .padding(.vertical,  self.type.paddingVertical)
            .padding(.horizontal,  self.type.paddingHorizontal)
            .background(self.type.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: self.type.bgRadius))
        }.buttonStyle(BorderlessButtonStyle())
    }
}

#if DEBUG
struct TextButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            TextButton(
                defaultText:"test",
                isUnderLine: true,
                image: Asset.img.noImg1_1
                ){_ in
                
            }
            
            TextButton(
                type: .box,
                defaultText:"test",
                imageMode: .template
                ){_ in
                
            }
        }
    }
}
#endif
