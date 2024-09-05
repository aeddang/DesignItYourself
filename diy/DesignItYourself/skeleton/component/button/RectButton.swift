//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
///import FirebaseAnalytics
struct RectButton: PageView{
    enum SizeType{
        case tiny, medium
        var iconSize:CGFloat{
            switch self {
            case .tiny : return Dimen.icon.thin
            case .medium : return Dimen.icon.heavy
            }
        }
        
        var bgSize:CGFloat{
            switch self {
            case .tiny : return Dimen.button.regular
            case .medium : return 164
            }
        }
        
        var textSize:CGFloat{
            switch self {
            case .tiny : return Font.size.micro
            case .medium : return Font.size.light
            }
        }
        
        var spacing:CGFloat{
            switch self {
            case .tiny : return 0
            case .medium : return Dimen.margin.regular
            }
        }
        
        var radius:CGFloat{
            switch self {
            case .tiny : return Dimen.radius.thin
            case .medium : return Dimen.radius.regular
            }
        }
    }
    var sizeType:SizeType = .medium
    var icon:String? = nil
    var text:String? = nil
    var index: Int = 0
    var isSelected: Bool = false
    var color:Color = Color.brand.primary
    var defaultColor:Color = Color.app.gray
    var bgColor:Color = Color.app.white
    
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
            let parameters = [
                "buttonType": self.tag,
                "buttonText": text
            ]
            //Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
        }) {
            ZStack{
                Spacer().modifier(MatchParent())
                VStack(spacing:self.sizeType.spacing){
                    if let icon = self.icon {
                        Image(icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(!self.isSelected ? self.defaultColor : self.bgColor)
                            .frame(width: self.sizeType.iconSize, height: self.sizeType.iconSize)
                    }
                    if let text = self.text {
                        Text(text)
                            .modifier(MediumTextStyle(
                                size: self.sizeType.textSize,
                                color: !self.isSelected ? self.defaultColor : self.bgColor))
                    }
                    
                    
                }
            }
            .modifier(MatchHorizontal(height: self.sizeType.bgSize))
            .background(self.isSelected ? self.color : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius:self.sizeType.radius))
            .overlay(
                RoundedRectangle(cornerRadius:self.sizeType.radius)
                    .strokeBorder(
                        self.isSelected ? self.color : Color.app.gray,
                        lineWidth: Dimen.stroke.light
                    )
            )
        }
    }
}
#if DEBUG
struct RectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            RectButton(
                icon: Asset.component.button.close,
                text: "test",
                isSelected: false,
                color: Color.app.gray
                ){_ in
                
            }
        }
    }
}
#endif
