//
//  CustomSwitch.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/26.
//

import Foundation
import SwiftUI

struct Switch : View{
    var isOn:Bool = false
    var defaultColor:Color = Color.app.white
    var activeColor:Color = Color.brand.primary
    var bgColor:Color = Color.app.gray
  
    let action: (Bool) -> Void
   
    var body: some View {
        Button(action: {
            self.action(!self.isOn)
        }){
            ZStack(alignment: .leading){
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(self.bgColor)
                        .modifier(MatchParent())
                }
                .frame(width: 37, height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                Circle()
                    .fill(self.isOn ? activeColor : defaultColor)
                    .frame(width: 20, height: 20, alignment: .leading)
                    .offset(x: self.isOn ? 17 : 0)
                
            }
            
        }
    }
}
