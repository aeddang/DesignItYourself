import Foundation
import SwiftUI
import SceneKit
import UIKit

struct MyMaterials : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    @EnvironmentObject var storeModel:StoreModel
    @EnvironmentObject var pagePresenter:PagePresenter
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0){
            ScrollView(.horizontal, showsIndicators:false){
                LazyHStack(spacing: Dimen.margin.micro){
                    ForEach(self.datas){obj in
                        Item(data: obj)
                            .onTapGesture {
                                let add = self.viewModel.createNode(type: obj.type)
                                self.addNode(add, type: obj.type)
                            }
                    }
                }
                .padding(.top, Dimen.margin.thin)
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.add,
                sizeType: .L
            ){_ in
                let page:PageObject = PageProvider.getPageObject(.store)
                self.pagePresenter.request = .movePage(page)
            }
            .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
            .background(Color.brand.subBg)
        }
        .frame(height: Dimen.icon.heavy + Dimen.margin.thin)
        .onReceive(self.storeModel.$hasMaterials) { materials in
            self.datas = materials
        }
        
    }
    @State private var datas:[MaterialData] = []
    
    private func addNode(_ node:SCNNode, type:SceneWorldModel.NodeType){
        self.viewModel.addNode(
            node, type: type,
            objectName: type.name
        )
        node.normalY()
        self.viewModel.removeAllPickNode(exception: node)
    }
    
    struct Item: PageView {
        @EnvironmentObject var pagePresenter:PagePresenter
        @EnvironmentObject var storeModel:StoreModel
        var data:MaterialData
        var body: some View {
            ZStack(alignment: .topTrailing){
                ZStack(){
                    Image(self.data.type.skin ?? "grid")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                    Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                    Text(self.data.getFoundationDescription())
                        .modifier(LightTextStyle(color: Color.app.white))
                        .modifier(MatchParent())
                }
                .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                .clipped()
                .padding(.top, 6)
                .padding(.trailing, 6)
                VStack(spacing: 0) {
                    
                    ImageButton(
                        isSelected: false,
                        defaultImage: Asset.component.button.close,
                        sizeType: .S
                    ){_ in
                        self.storeModel.removeMaterial(self.data)
                    }
                    .background(Color.brand.subBg)
                    .clipShape(Circle())
                    if data.isPossibleFoundation {
                        ImageButton(
                            isSelected: false,
                            defaultImage: Asset.icon.crop,
                            sizeType: .S
                        ){_ in
                            
                            let page:PageObject = PageProvider.getPageObject(.storeFoundation)
                                .addParam(key: .data, value: data)
                            self.pagePresenter.request = .movePage(page)
                        }
                        .background(Color.brand.bg)
                        .clipShape(RoundRectMask(radius: 2))
                    }
                }
            }
        }
    }
}
/*
struct MyMaterialGrid: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var datas:[MaterialData]
    var selected: ((_ data:MaterialData) -> Void)
    private let columns = [GridItem(.adaptive(minimum: Dimen.icon.heavy, maximum: .infinity))]
    var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: Dimen.margin.thin) {
                ForEach(self.datas) { data in
                    Button(action: {
                        self.selected(data)
                    }) {
                        Item(data: data)
                    }
                }
                ImageButton(
                    isSelected: false,
                    defaultImage: Asset.icon.add,
                    sizeType: .L
                ){_ in
                    let page:PageObject = PageProvider.getPageObject(.store)
                    self.pagePresenter.request = .movePage(page)
                }
                .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                .background(Color.brand.subBg)
            }
        .onAppear(){
        }
    }
    
    struct Item: PageView {
        @EnvironmentObject var pagePresenter:PagePresenter
        @EnvironmentObject var storeModel:StoreModel
        let data:MaterialData
        var body: some View {
            ZStack(alignment: .topTrailing){
                ZStack(){
                    Image(self.data.type.skin ?? "grid")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                    Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                    Text(self.data.getFoundationDescription())
                        .modifier(LightTextStyle(color: Color.app.white))
                        .modifier(MatchParent())
                }
                .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                .padding(.top, 6)
                .padding(.trailing, 6)
                HStack(spacing: Dimen.margin.micro) {
                    if data.isPossibleFoundation {
                        ImageButton(
                            isSelected: false,
                            defaultImage: Asset.icon.edit,
                            sizeType: .S
                        ){_ in
                            
                            let page:PageObject = PageProvider.getPageObject(.storeFoundation)
                                .addParam(key: .data, value: data)
                            self.pagePresenter.request = .movePage(page)
                        }
                        .background(Color.brand.bg)
                        .clipShape(Circle())
                    }
                    ImageButton(
                        isSelected: false,
                        defaultImage: Asset.component.button.close,
                        sizeType: .S
                    ){_ in
                        self.storeModel.removeMaterial(self.data)
                    }
                    .background(Color.brand.bg)
                    .clipShape(Circle())
                }
            }
        }
    }
}
*/




