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
    var orientation:UIDeviceOrientation = .portrait
    var pick:(()->Void)? = nil
    var completed:(()->Void)? = nil
    var body: some View {
        GeometryReader { geometry in
            Group{
                if self.orientation.isPortrait {
                    VStack(alignment: .leading, spacing: Dimen.margin.thin){
                        self.getHeader()
                        if let type = self.foundationType {
                            NodeScreen(type: type).modifier(MatchParent())
                                .frame(height: geometry.size.width)
                        }
                        self.getSliders()
                        HStack(spacing: Dimen.margin.micro){
                            self.getButtons()
                        }
                    }
                } else {
                    HStack(alignment: .top, spacing: Dimen.margin.thin){
                        if let type = self.foundationType {
                            NodeScreen(type: type).modifier(MatchHorizontal(height: geometry.size.height))
                        }

                        VStack(alignment: .leading, spacing: Dimen.margin.thin){
                            self.getHeader()
                            self.getSliders()
                            self.getButtons()
                        }
                    }
                }
            }
            .onAppear(){
                self.foundation(
                    x: self.foundationX,
                    y: self.foundationY,
                    z: self.foundationZ
                )
            }
        }
    }
    @ViewBuilder
    func getHeader() -> some View {
        HStack(alignment: .top, spacing: Dimen.margin.thin){
            Image(self.data.type.skin ?? "grid")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
            VStack(alignment: .leading, spacing: Dimen.margin.micro){
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
    }
    @ViewBuilder
    func getSliders() -> some View {
        if let foundation = self.data.foundationX {
            MaterialFoundationSlider(
                nodeAxis: .X,
                progress: self.foundationX,
                foundation: foundation,
                foundationPoint: self.data.foundationPointX,
                foundationCurrent: self.foundationCurrentX,
                onChange: { v in
                    self.foundation(x:v)
                }
            )
            .onReceive(self.data.$foundationCurrentX){ v in
                self.foundationCurrentX = MaterialData.getFoundationDescription(v, max: foundation.upperBound)
            }
            
        }
        if let foundation = self.data.foundationY {
            MaterialFoundationSlider(
                nodeAxis: .Y,
                progress: self.foundationY,
                foundation: foundation,
                foundationPoint: self.data.foundationPointY,
                foundationCurrent: self.foundationCurrentY,
                onChange: { v in
                    self.foundation(y:v)
                }
            )
            .onReceive(self.data.$foundationCurrentY){ v in
                self.foundationCurrentY = MaterialData.getFoundationDescription(v, max: foundation.upperBound)
            }
        }
        if let foundation = self.data.foundationZ {
            MaterialFoundationSlider(
                nodeAxis: .Z,
                progress: self.foundationZ,
                foundation: foundation,
                foundationPoint: self.data.foundationPointZ,
                foundationCurrent: self.foundationCurrentZ,
                onChange: { v in
                    self.foundation(z:v)
                }
            )
            .onReceive(self.data.$foundationCurrentZ){ v in
                self.foundationCurrentZ = MaterialData.getFoundationDescription(v, max: foundation.upperBound)
            }
        }
    }
    
    @ViewBuilder
    func getButtons() -> some View {
        if let pick = self.pick {
            FillButton(
                type: .stroke,
                colorType : .primary,
                text: String.app.pick
            ){_ in
                pick()
            }
        }
        /*
        if let completed = self.completed {
            FillButton(
                type: .fill,
                colorType : .primary,
                text: String.app.confirm
            ){_ in
                completed()
            }
        }
        */
    }
    
    @State var foundationX:Float = 1
    @State var foundationY:Float = 1
    @State var foundationZ:Float = 1
    
    @State var foundationCurrentX:String? = nil
    @State var foundationCurrentY:String? = nil
    @State var foundationCurrentZ:String? = nil
    @State var foundationType:SceneWorldModel.NodeType? = nil
    
    private func foundation(x:Float? = nil, y:Float? = nil, z:Float? = nil){
        self.foundationX = x ?? self.foundationX
        self.foundationY = y ?? self.foundationY
        self.foundationZ = z ?? self.foundationZ
        self.foundationType = self.data.foundation(x: x, y:y, z:z).foundationType
    }
    
}

struct MaterialFoundationSlider: PageView {
    let nodeAxis:SceneWorldModel.NodeAxis
    var progress:Float
    var foundation:Range<Int>
    var foundationPoint:[Int]
    var foundationCurrent:String? = nil
    var onChange: ((Float) -> Void)
    var body: some View {
        HStack(spacing: Dimen.margin.tiny){
            Text(nodeAxis.name)
                .modifier(MediumTextStyle())
            VStack(alignment: .trailing, spacing: Dimen.margin.micro){
                ProgressSlider(
                    progress:  self.progress,
                    progressPoints: foundationPoint.map{ p in
                            .init(
                                pct: CGFloat(p)/CGFloat(foundation.upperBound),
                                color: Color.app.white,
                                onAction: { pct in
                                    self.onChange(Float(pct))
                                }
                            )
                    },
                    thumbSize: 20,
                    thumbColor: nodeAxis.color,
                    color: nodeAxis.color,
                    onChange: self.onChange
                )
                .frame(height: 20)
                if let current = self.foundationCurrent {
                    Text(current)
                        .modifier(RegularTextStyle())
                }
            }
        }
    }
}
