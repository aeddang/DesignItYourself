//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseAnalytics

struct FillButton: PageView{
    enum ButtonType{
        case fill, stroke, blank
        var strokeWidth:CGFloat{
            switch self {
            case .fill, .blank : return 0
            case .stroke : return Dimen.stroke.light
            }
        }
        
        func textColor(_ color:ColorType) -> Color{
            switch self {
            case .fill : return color == .gray ? color.textValue : color.value
            case .stroke, .blank : return color.textValue
            }
        }
        
        func bgColor(_ color:ColorType) -> Color{
            switch self {
            case .fill : return color == .gray ? color.value : color.textValue
            case .stroke, .blank : return Color.transparent.clearUi
            }
        }
    }
    
    enum SizeType{
        case XL, L, M , S
        var height:CGFloat{
            switch self {
            case .XL : return Dimen.button.medium
            case .L : return Dimen.button.regular
            case .M : return Dimen.button.regular
            case .S : return Dimen.button.light
            }
        }
        var radius:CGFloat{
            switch self {
            case .XL : return Dimen.radius.thin
            case .L : return Dimen.radius.thin
            case .M : return Dimen.radius.thin
            case .S : return Dimen.radius.thin
            }
        }
        
        var textSize:CGFloat{
            switch self {
            case .XL : return Font.size.semiBold
            case .L : return Font.size.regular
            case .M : return Font.size.light
            case .S : return Font.size.thin
            }
        }
    }
    
    enum ColorType{
        case primary, black, gray
        var value:Color{
            switch self {
            case .primary : return Color.app.white
            case .black : return Color.brand.bg
            case .gray : return Color.app.gray
            }
        }
        var textValue:Color{
            switch self {
            case .primary : return Color.brand.primary
            case .black : return Color.brand.content
            case .gray : return Color.brand.bg
            }
        }
    }
    
    var type:ButtonType = .fill
    var sizeType:SizeType = .XL
    var colorType:ColorType = .primary
    var icon:String? = nil
    var iconType:Image.TemplateRenderingMode? = nil
    var text:String = ""
    var textColor:Color? = nil
    var trailingIcon:String? = nil
    var trailingIconType:Image.TemplateRenderingMode? = nil
    var color:Color? = nil
    var index: Int = 0

    var isActive: Bool = true
    var action: ((_ idx:Int) -> Void)? = nil
    
    var body: some View {
        if let action = self.action {
            Button(action: {
               action(self.index)
                let parameters = [
                    "buttonType": self.tag,
                    "buttonText": text
                ]
                Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
            }) {
                ButtonBody(
                    type: type,
                    sizeType: sizeType,
                    colorType: colorType,
                    icon: icon,
                    iconType: iconType,
                    text: text,
                    textColor: textColor,
                    trailingIcon: trailingIcon,
                    trailingIconType: trailingIconType,
                    color: color,
                    isActive: isActive
                )
            }
        } else {
            ButtonBody(
                type: type,
                sizeType: sizeType,
                colorType: colorType,
                icon: icon,
                iconType: iconType,
                text: text,
                textColor: textColor,
                trailingIcon: trailingIcon,
                trailingIconType: trailingIconType,
                color: color,
                isActive: isActive
            )
            .disabled(self.isActive)
        }
    }
    
    struct ButtonBody:View {
        var type:ButtonType
        var sizeType:SizeType
        var colorType:ColorType
        var icon:String?
        var iconType:Image.TemplateRenderingMode?
        var text:String
        var textColor:Color?
        var trailingIcon:String? = nil
        var trailingIconType:Image.TemplateRenderingMode? = nil
        var color:Color?
        var isActive: Bool
        var body: some View {
            ZStack{
                HStack(spacing:Dimen.margin.tiny){
                    if let icon = icon {
                        Image(icon)
                            .renderingMode(self.iconType ?? .template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor( self.textColor ?? self.type.textColor(self.colorType))
                            .frame(width:Dimen.icon.light, height:Dimen.icon.light)
                        
                    }
                    Text(self.text)
                        .modifier(
                            SemiBoldTextStyle(
                                size: self.sizeType.textSize,
                                color: self.textColor ?? self.type.textColor(self.colorType)
                            )
                        )
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    if let icon = self.trailingIcon {
                        ZStack(alignment: .top){
                            Spacer().modifier(MatchVertical())
                            Image(icon)
                                .renderingMode(self.trailingIconType ?? .template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.brand.content)
                                .frame(width:Dimen.icon.tiny, height:Dimen.icon.tiny)
                                .padding(.top, self.showIcon ? Dimen.margin.tiny : Dimen.margin.regular)
                                .opacity(self.showIcon ? 1 : 0)
                        }
                    }
                }
            }
            .modifier( MatchHorizontal(height: self.sizeType.height) )
            .background(self.color ?? self.type.bgColor(self.colorType))
            .clipShape(RoundedRectangle(cornerRadius: self.sizeType.radius))
            .overlay(
                RoundedRectangle(cornerRadius: self.sizeType.radius)
                    .strokeBorder(
                        self.textColor ?? self.type.textColor(self.colorType),
                        lineWidth: self.type.strokeWidth
                    )
            )
            .opacity(self.isActive ? 1 : 0.5)
            .onAppear(){
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
                    withAnimation{
                        self.showIcon = true
                    }
                }
            }
            .onDisappear(){
                self.showIcon = false
            }
        }
        @State var showIcon:Bool = false
        
    }
}
#if DEBUG
struct FillButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            FillButton(
                type: .fill,
                colorType : .black,
                text: "fill buttom"
            ){_ in
                
            }
            FillButton(
                type: .stroke,
                colorType : .black,
                text: "fill buttom"
            ){_ in
                
            }
            FillButton(
                type: .stroke,
                colorType : .primary,
                text: "stroke button"
                
            ){_ in
                
            }
            FillButton(
                type: .fill,
                colorType : .gray,
                text: "gradient buttom"
            ){_ in
                
            }
            .modifier(Shadow())
        }
        .padding(.all, 10)
    }
}
#endif

