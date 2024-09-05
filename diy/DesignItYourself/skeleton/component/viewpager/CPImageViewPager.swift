//
//  ImageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

enum IndicatorLocation {
    case bottomTrailing, bottomInner, bottomOutter
}

struct CPImageViewPager: PageView {
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var pages: [any PageView]
    var width: CGFloat? = nil
    var cornerRadius:CGFloat = 0
    var spacing:CGFloat = 0
    var useButton:Bool = false
    var useLoop: Bool = false
    var alignment: Alignment = .bottom
    var buttonLocation: IndicatorLocation = .bottomOutter
    @State var index: Int = 0
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        ZStack(alignment: self.alignment) {
            Spacer().modifier(MatchHorizontal(height: 0))
            if useLoop {
                LoopSwipperView(
                    viewModel: self.viewModel,
                    pages: self.pages
                ) {_ in 
                    guard let action = self.action else {return}
                    action(self.index)
                }
            } else {
                SwipperView(
                    viewModel:self.viewModel,
                    pages: self.pages,
                    spacing: self.spacing
                ) {
                   
                    guard let action = self.action else {return}
                    action(self.index)
                }
                .frame(width: self.width)
            }
            
        
            if self.useButton && self.pages.count > 1 {
                HStack(spacing: Dimen.margin.tiny) {
                    ForEach(0..<self.pages.count, id: \.self) { index in
                        CircleButton(
                            isSelected: self.index == index ,
                            index:index )
                        { idx in
                            withAnimation{ self.index = idx }
                        }
                    }
                }
                .padding(self.buttonEdgeLocation, self.buttonEdgeLength)
                .offset(x: self.buttonLocation == .bottomTrailing ? -8 : 0,
                        y: self.buttonLocation == .bottomTrailing ? -8 : 0)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
        .onReceive( self.viewModel.$index ){ idx in
            self.index = idx
        }
        
        .onAppear() {
            self.setIndicatorLocation()
        }
    }
    
    @State var buttonEdgeLocation: Edge.Set = .all
    @State var buttonEdgeLength: CGFloat = 0
    
    private func setIndicatorLocation() {
        switch self.buttonLocation {
        case .bottomOutter:
            self.buttonEdgeLocation = .vertical
            self.buttonEdgeLength = Dimen.margin.medium
        case .bottomInner:
            self.buttonEdgeLocation = .all
            self.buttonEdgeLength = 0
        case .bottomTrailing:
            self.buttonEdgeLocation = .all
            self.buttonEdgeLength = 0
        }
        
    }
}

#if DEBUG
struct ImageViewPager_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            CPImageViewPager(
                pages:
                   [
                     //ImageItem(imagePath: ""),
                    // ImageItem(imagePath: ""),
                     //ImageItem(imagePath: "")
                   ]
            )
            .frame(width:375, height: 170, alignment: .center)
        }
    }
}
#endif
