import Foundation
import SwiftUI
import SceneKit
import UIKit

struct MyMaterials : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    @EnvironmentObject var storeModel:StoreModel
    
    var body: some View {
        VStack{
            MyMaterialGrid(datas:  self.datas){ select in
                let add = self.viewModel.createNode(type: select.type)
                self.addNode(add, type: select.type)
            }
            ScrollView(.horizontal){
                LazyHStack{
                    ForEach(self.objects){obj in
                        NodeScreen(type: obj.type, userData: obj){ node in
                            let add = node.clone()
                            self.addNode(add, type: obj.type)
                        }
                        .modifier(MatchVertical(width: 80))
                    }
                }
            }
            .frame(height: 80)
        }
        .modifier(MatchParent())
        .onReceive(self.storeModel.$hasMaterials) { materials in
            self.datas = materials
        }
        .onReceive(self.viewModel.$objectNodeDatas) { nodes in
            self.objects = nodes.compactMap{$0.value}
        }
    }
    @State private var datas:[MaterialData] = []
    @State private var objects:[SceneWorldModel.UserData] = []
    
    private func addNode(_ node:SCNNode, type:SceneWorldModel.NodeType){
        let tx = Int.random(in: 15..<30)
        let ty = Int.random(in: 15..<30)
        self.viewModel.addNode(
            node, type: type,
            objectName: type.name
        )
        node.moveX(Float(-tx)).moveY(Float(ty)).normalY()
        self.viewModel.removeAllPickNode(exception: node)
    }
}

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





