//
//  ImageButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI
import FirebaseAnalytics
struct ImageButton: PageView{
    enum SizeType{
        case L,S
        var size:CGFloat{
            switch self {
            case .L : return Dimen.icon.light
            case .S : return Dimen.icon.thin
            }
        }
    }
    
    var isSelected: Bool = false
    var index: Int = -1
    var defaultImage:String = Asset.component.button.close
    var activeImage:String? = nil
    var type:Image.TemplateRenderingMode = .template
    var sizeType:SizeType = .L
    var size:CGSize? = nil //CGSize(width: Dimen.icon.light, height: Dimen.icon.light)
    var iconText:String? = nil
    var iconImage:String? = nil
    var text:String? = nil
    
    var defaultColor:Color = Color.brand.content
    var activeColor:Color = Color.brand.primary
    var padding:CGFloat = 0
    var action: ((_ idx:Int) -> Void)? = nil
   
    var body: some View {
        if let action = self.action {
            Button(action: {
                action(self.index)
                let parameters = [
                    "buttonType": self.tag,
                    "buttonText": text ?? self.defaultImage
                ]
                Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
            }) {
                ButtonBody(
                    isSelected: isSelected,
                    defaultImage: defaultImage,
                    activeImage: activeImage,
                    type: type,
                    size: size ?? .init(width: sizeType.size, height: sizeType.size),
                    iconText:iconText,
                    iconImage: iconImage,
                    text:text,
                    defaultColor: defaultColor,
                    activeColor: activeColor,
                    padding: padding)
            }
            .buttonStyle(BorderlessButtonStyle())
        } else {
            ButtonBody(
                isSelected: isSelected,
                defaultImage: defaultImage,
                activeImage: activeImage,
                type: type,
                size: size ?? .init(width: sizeType.size, height: sizeType.size),
                iconText:iconText,
                iconImage: iconImage,
                text:text,
                defaultColor: defaultColor,
                activeColor: activeColor,
                padding: padding)
        }
    }
    
    struct ButtonBody:View {
        var isSelected: Bool
        var defaultImage:String
        var activeImage:String?
        var type:Image.TemplateRenderingMode
        var size:CGSize
        var iconText:String?
        var iconImage:String?
        var text:String?
        
        var defaultColor:Color
        var activeColor:Color
        var padding:CGFloat
        
        var body: some View {
            ZStack(alignment: .topTrailing){
                VStack(spacing:Dimen.margin.micro){
                    Image(self.isSelected
                          ? (self.activeImage ?? self.defaultImage)
                          : self.defaultImage)
                    .renderingMode(self.type)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.isSelected ?  self.activeColor : self.defaultColor)
                    .frame(width: size.width, height: size.height)
                    
                    if let text = self.text {
                        Text(text)
                            .modifier(RegularTextStyle(
                                size: Font.size.tiny,
                                color: self.isSelected ?  self.activeColor : self.defaultColor
                            ))
                    }
                }
                .padding(self.iconText == nil ? 0 : Dimen.margin.micro)
                if self.iconText?.isEmpty == false, let text = self.iconText {
                    Text(text)
                        .modifier(MediumTextStyle(
                            size: Font.size.micro,
                            color: Color.app.white
                        ))
                        .frame(width:Dimen.icon.tiny, height: Dimen.icon.tiny)
                        .background(Color.brand.primary)
                        .clipShape(
                            Circle()
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color.app.white, lineWidth: Dimen.stroke.light)
                        )
                        .offset(x:Dimen.margin.tiny, y:-Dimen.margin.tiny)
                }
                
                if self.iconImage?.isEmpty == false, let img = self.iconImage {
                    ZStack{
                        Image(img)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(Color.app.white)
                            .frame(width:Dimen.icon.micro, height: Dimen.icon.micro)
                    }
                    .frame(width:Dimen.icon.tiny, height: Dimen.icon.tiny)
                    .background(Color.brand.primary)
                    .clipShape(
                        Circle()
                    )
                    .offset(x:Dimen.margin.tiny, y:-Dimen.margin.tiny)
                }
            }
            .padding(.all, self.padding)
            .background(Color.transparent.clearUi)
            
        }
    }
}

#if DEBUG
struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ImageButton(
                isSelected: false,
                iconText: "N",
                text: "Chat"
            ){_ in
                
            }
            .frame( alignment: .center)
            
            ImageButton(
                isSelected: false,
                iconImage: Asset.component.button.close ,
                text: "Chat"
            ){_ in
                
            }
            .frame( alignment: .center)
            
            ImageButton(
                isSelected: false, 
                defaultImage: Asset.component.button.close,
                sizeType: .S
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
