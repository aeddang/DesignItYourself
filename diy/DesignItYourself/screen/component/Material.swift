//
//  CaptureGlobePhoto.swift
//  globe
//
//  Created by JeongCheol Kim on 10/4/23.
//

import SwiftUI
import Foundation
import UIKit

struct MaterialGrid: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var datas:[MaterialItemData]
    var selected: ((_ data:MaterialItemData) -> Void)
    private let columns = [GridItem(.adaptive(minimum: Dimen.icon.heavy, maximum: .infinity))]
    var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: Dimen.margin.thin) {
                ForEach(self.datas) { data in
                    Button(action: {
                        self.selected(data)
                    }) {
                        MaterialGridItem(data: data)
                    }
                }
            }
        .onAppear(){
        }
    }
   
}

class MaterialItemData:InfinityData {
    private(set) var image:String
    private(set) var datas:[MaterialData]
    private(set) var title:String? = nil
    private(set) var text:String? = nil
    private(set) var info:String? = nil
    
    init(image: String, datas: [MaterialData]) {
        self.image = image
        self.datas = datas
    }
    func setup(title:String? = nil, text:String? = nil, info:String? = nil) -> MaterialItemData {
        self.title = title
        self.text = text
        self.info = info
        return self
    }
    func setFoundation(x:Range<Int>? = nil, y:Range<Int>? = nil, z:Range<Int>? = nil) -> MaterialItemData {
        self.datas.forEach{
            $0.setFoundation(x:x, y:y, z:z)
        }
        return self
    }
}

class MaterialData:InfinityData {
    
    private(set) var type:SceneWorldModel.NodeType
    private(set) var title:String? = nil
    private(set) var text:String? = nil
    private(set) var price:String? = nil
    
    private(set) var foundationX:Range<Int>? = nil
    private(set) var foundationY:Range<Int>? = nil
    private(set) var foundationZ:Range<Int>? = nil
  
    private(set) var foundationType:SceneWorldModel.NodeType
    private(set) var foundationCurrentX:Int? = nil
    private(set) var foundationCurrentY:Int? = nil
    private(set) var foundationCurrentZ:Int? = nil
    
    init(type: SceneWorldModel.NodeType) {
        self.type = type
        self.foundationType = type
    }
    
    func setup(title:String? = nil, text:String? = nil, price:String? = nil) -> MaterialData {
        self.title = title
        self.text = text
        self.price = price
        return self
    }
    
    @discardableResult
    func setFoundation(x:Range<Int>? = nil, y:Range<Int>? = nil, z:Range<Int>? = nil) -> MaterialData {
        self.foundationX = x
        self.foundationY = y
        self.foundationZ = z
        return self
    }
    
    // 변경 pct
    func foundation(x:Float? = nil, y:Float? = nil, z:Float? = nil) -> MaterialData {
        
        if let x = x , let foundationX = self.foundationX {
            self.foundationCurrentX = self.getFoundationValue(range: foundationX, v: x)
        }
        if let y = y , let foundationY = self.foundationY {
            self.foundationCurrentY = self.getFoundationValue(range: foundationY, v: y)
        }
        if let z = z , let foundationZ = self.foundationZ {
            self.foundationCurrentZ = self.getFoundationValue(range: foundationZ, v: z)
        }
        switch self.type {
        case .box(let ox, let oy, let oz, let skin):
            self.foundationType = .box(
                x: Float(self.foundationCurrentX ?? Int(ox)),
                y: Float(self.foundationCurrentY ?? Int(oy)),
                z: Float(self.foundationCurrentZ ?? Int(oz)), skin: skin)
            
            
        case .cylinder(let r, let h, let skin):
            self.foundationType = .cylinder(
                r: r,
                h: Float(self.foundationCurrentZ ?? Int(h)), skin: skin)
        case .cone(let r, let br, let h, let skin):
            self.foundationType = .cone(
                r: r, br: br,
                h: Float(self.foundationCurrentZ ?? Int(h)), skin: skin)
        default : break
        }
        return self
    }
    
    // 변경가능한 int로 변환
    private func getFoundationValue(range:Range<Int>, v:Float) -> Int {
        let l = range.lowerBound
        let r = range.upperBound
        let value = Int(round(Float(r - l) * v)) + l
        return value
    }
        
    func createFoundationData() -> MaterialData {
        let data:MaterialData = MaterialData(type: self.foundationType)
            .setup(title: self.title)
            .setFoundation(
                x: self.foundationX == nil ? nil
                : (self.foundationX?.lowerBound ?? 1)..<(self.foundationCurrentX ?? self.foundationX?.upperBound ?? 10),
                y: self.foundationY == nil ? nil
                : (self.foundationY?.lowerBound ?? 1)..<(self.foundationCurrentY ?? self.foundationY?.upperBound ?? 10),
                z: self.foundationZ == nil ? nil
                : (self.foundationZ?.lowerBound ?? 1)..<(self.foundationCurrentZ ?? self.foundationZ?.upperBound ?? 10)
            )
            
        
        
        return data
        
    }
}

struct MaterialGridItem: PageView {
    let data:MaterialItemData
    var body: some View {
        ZStack(){
            Image(self.data.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .modifier(MatchParent())
            Spacer().modifier(MatchParent()).background(Color.transparent.black30)
            VStack(alignment: .leading, spacing: Dimen.margin.micro){
                if let t = data.title {
                    Text(t)
                        .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white ))
                }
                if let t = data.text {
                    Text(t)
                        .modifier(RegularTextStyle(size: Font.size.micro, color: Color.app.white ))
                }
            }
            .padding(.all, Dimen.margin.micro)
        }
        .background(Color.brand.bg)
        .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
    }
}

struct MaterialItem: PageView {
    let data:MaterialItemData
    var body: some View {
        HStack(alignment: .top, spacing: Dimen.margin.thin){
            Image(self.data.image)
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
                
                if let t = data.info {
                    Text(t)
                        .modifier(RegularTextStyle())
                }
            }
        }
        .background(Color.brand.bg)
 
    }
}

struct Material: PageView {
    let data:MaterialData
    var body: some View {
        HStack(alignment: .top, spacing: Dimen.margin.thin){
            Image(self.data.type.skin ?? "grid")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
            VStack(alignment: .leading, spacing: Dimen.margin.micro){
                if let t = data.title {
                    Text(t)
                        .modifier(MediumTextStyle())
                }
                if let t = data.text {
                    Text(t)
                        .modifier(RegularTextStyle())
                }
                
                if let t = data.price {
                    Text(t)
                        .modifier(RegularTextStyle(color: Color.app.red))
                }
            }
        }
        .background(Color.brand.bg)
    }
}
