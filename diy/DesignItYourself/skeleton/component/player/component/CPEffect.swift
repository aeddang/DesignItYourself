//
//  CPPipButton.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2022/01/20.
//

import Foundation
import SwiftUI
import AVKit
struct CPEffect: View{
    var icon:String = ""
    var text:String? = nil
    var isReverse:Bool = false
    var body: some View {
        ZStack{
            LinearGradient(
                gradient:Color.transparent.whiteGradient,
                startPoint:self.isReverse ? .trailing : .leading,
                endPoint:self.isReverse ? .leading : .trailing
            )
            .modifier(MatchParent())
            .opacity(0.5)
            VStack(spacing: Dimen.margin.micro){
                Image(self.icon)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 68, height: 28)
                if let text = self.text {
                    Text(text)
                        .modifier(RegularTextStyle(size: Font.size.medium,color: Color.app.white))
                }
            }
        }
    }
}

    




