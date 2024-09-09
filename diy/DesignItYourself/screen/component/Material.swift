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
    var datas:[MaterialItemData] = []
    var selected: ((_ datas:MaterialItemData) -> Void)? = nil
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns:  Array(repeating: .init(.flexible()), count:self.count), spacing: Dimen.margin.thin) {
                        ForEach(self.datas) { data in
                            MaterialItem(data: data)
                        }
                    }
            }
            .onReceive(self.pagePresenter.$screenSize){ size in
                self.updateScreenSize(size)
            }
            .onAppear(){
            }
        }
        
    }
    @State var columns: [GridItem]? = nil
    @State var count:Int = 0
    private func updateScreenSize(_ screenSize:CGSize){
        let size = screenSize.width - (Dimen.margin.regular*2)
        self.count = Int(floor(size / (Dimen.icon.heavy+Dimen.margin.micro)))
        self.columns = Array(repeating: .init(.flexible()), count:count)
    }
}

class MaterialItemData:InfinityData {
    private(set) var image:String
    private(set) var datas:[MaterialData]
    private(set) var title:String? = nil
    private(set) var text:String? = nil
    
    init(image: String, datas: [MaterialData]) {
        self.image = image
        self.datas = datas
    }
    func setup(title:String? = nil, text:String? = nil) -> MaterialItemData {
        self.title = title
        self.text = text
        return self
    }
}

class MaterialData:InfinityData {
    
    private(set) var type:SceneWorldModel.NodeType
    private(set) var title:String? = nil
    private(set) var text:String? = nil
    private(set) var price:String? = nil
  
    init(type: SceneWorldModel.NodeType) {
        self.type = type
    }
    
    func setup(title:String? = nil, text:String? = nil, price:String? = nil) -> MaterialData {
        self.title = title
        self.text = text
        self.price = price
        return self
    }
}

struct MaterialItem: PageView {
    let data:MaterialItemData
    
    var body: some View {
        HStack(){
            VStack(){
                Image(self.data.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                    .background(Color.brand.bg)
                    .onTapGesture {
                        withAnimation{
                            self.isSelect.toggle()
                        }
                    }
            }
            .frame(width: Dimen.icon.heavy)
            
            if self.isSelect {
                ForEach(self.data.datas){ material in
                    VStack(){
                        if let t = material.title {
                            Text(t)
                        }
                        if let t = material.text {
                            Text(t)
                        }
                        if let t = material.price {
                            Text(t)
                        }
                    }
                    .frame(width: Dimen.icon.heavy)
                }
            }
        }
    }
    @State var isSelect = false
}
