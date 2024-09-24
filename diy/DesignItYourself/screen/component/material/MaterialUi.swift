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
    func setFoundationDatas(
        x:Range<Int>? = nil, y:Range<Int>? = nil, z:Range<Int>? = nil,
        pointX:[Int] = [], pointY:[Int] = [], pointZ:[Int] = []
    ) -> MaterialItemData {
        self.datas.forEach{
            $0.setFoundation(x:x, y:y, z:z, pointX: pointX, pointY: pointY, pointZ: pointZ)
        }
        return self
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
