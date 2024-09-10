//
//  Foundation.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 9/10/24.
//

import SwiftUI
import Foundation
import UIKit



struct MaterialFoundation: PageView {
    let data:MaterialData
    var body: some View {
        VStack(spacing: Dimen.margin.thin){
            HStack(alignment: .top, spacing: Dimen.margin.thin){
                Image(self.data.type.skin ?? "grid")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                VStack(spacing: Dimen.margin.thin){
                    if let t = data.title {
                        Text(t)
                            .modifier(BoldTextStyle())
                    }
                    if let t = data.text {
                        Text(t)
                            .modifier(MediumTextStyle())
                    }
                    
                    if let t = data.price {
                        Text(t)
                            .modifier(RegularTextStyle())
                    }
                }
            }
            if let type = self.foundationType {
                NodeScreen(type: type).modifier(MatchParent())
            }
            if self.data.foundationX != nil {
                ProgressSlider(
                    progress:  self.foundationX,
                    thumbSize: 20,
                    thumbColor: SceneWorldModel.NodeAxis.X.color,
                    color: SceneWorldModel.NodeAxis.X.color,
                    onChange: { v in
                        self.foundation(x:v)
                    }
                )
            }
            if self.data.foundationY != nil {
                ProgressSlider(
                    progress:  self.foundationY,
                    thumbSize: 20,
                    thumbColor: SceneWorldModel.NodeAxis.Y.color,
                    color: SceneWorldModel.NodeAxis.Y.color,
                    onChange: { v in
                        self.foundation(y:v)
                    }
                )
            }
            if self.data.foundationZ != nil {
                ProgressSlider(
                    progress:  self.foundationZ,
                    thumbSize: 20,
                    thumbColor: SceneWorldModel.NodeAxis.Z.color,
                    color: SceneWorldModel.NodeAxis.Z.color,
                    onChange: { v in
                        self.foundation(z:v)
                    }
                )
            }
        }
        .background(Color.brand.bg)
        .onAppear(){
            self.foundation(
                x: self.foundationX,
                y: self.foundationY,
                z: self.foundationZ
            )
        }
    }
    @State var foundationX:Float = 1
    @State var foundationY:Float = 1
    @State var foundationZ:Float = 1
    @State var foundationType:SceneWorldModel.NodeType? = nil
    
    private func foundation(x:Float? = nil, y:Float? = nil, z:Float? = nil){
        self.foundationX = x ?? self.foundationX
        self.foundationY = y ?? self.foundationY
        self.foundationZ = z ?? self.foundationZ
        self.foundationType = self.data.foundation(x: x, y:y, z:z).foundationType
    }
}
